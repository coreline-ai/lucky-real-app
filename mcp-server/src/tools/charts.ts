// E그룹: 명반형 차트 툴 4종 — 자미두수·기문둔갑·대육임·구성기학 (dev-plan 툴 카탈로그 E)
//
// P3 실측(이슈 기록): interpretResult와 학파 분석 함수들은 각 네임스페이스 index에서
// 재수출되지 않는다 → exports 맵("./engine/*")을 통한 서브패스 import를 사용한다 (D4).
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { Daeyukim, Guseong, Qimen, Ziwei } from 'manseryeok-engine';
import { interpretResult as interpretDaeyukim } from 'manseryeok-engine/engine/daeyukim/interpret';
import { analyzeHongyeonQimen } from 'manseryeok-engine/engine/qimen/schools/hongyeon';
import { analyzeSiguk } from 'manseryeok-engine/engine/qimen/schools/siguk';
import { analyzeWolguk } from 'manseryeok-engine/engine/qimen/schools/wolguk';
import { analyzeYeonguk } from 'manseryeok-engine/engine/qimen/schools/yeonguk';
import { interpretResult as interpretQimen } from 'manseryeok-engine/engine/qimen/interpret';
import { interpretResult as interpretZiwei } from 'manseryeok-engine/engine/ziwei/interpret';
import { analyzeJungju } from 'manseryeok-engine/engine/ziwei/schools/jungju';
import { analyzeSahwa } from 'manseryeok-engine/engine/ziwei/schools/sahwa';
import { analyzeSamhap } from 'manseryeok-engine/engine/ziwei/schools/samhap';
import { z } from 'zod';

import { invalidInput, withErrorMapping } from '../errors.js';
import { formatDateDashed, formatDateLoose, todayKst } from '../lib/format.js';
import { ENGINE_META } from '../meta.js';
import {
  summarizeDaeyukim,
  summarizeGuseong,
  summarizeQimen,
  summarizeZiwei,
} from '../render/summary.js';
import { BirthInputSchema } from '../schemas/birth.js';
import type { BirthInput } from '../schemas/birth.js';
import {
  QIMEN_SCHOOLS,
  ZIWEI_SCHOOLS,
  daeyukimChartOutput,
  guseongChartOutput,
  qimenChartOutput,
  ziweiChartOutput,
} from '../schemas/output.js';
import { PaljaInputSchema, resolvePalja, validateBirthOrPalja } from '../schemas/palja.js';
import type { PaljaInput } from '../schemas/palja.js';

const READ_ONLY = { readOnlyHint: true, openWorldHint: false } as const;

const dateFields = {
  year: z.number().int().describe('양력 연도'),
  month: z.number().int().min(1).max(12).describe('양력 월'),
  day: z.number().int().min(1).max(31).describe('양력 일'),
  hour: z.number().int().min(0).max(23).describe('시각 (0~23, 필수 — 시국 계산의 핵심 입력)'),
};

export function registerChartTools(server: McpServer): void {
  server.registerTool(
    'ziwei_chart',
    {
      title: '자미두수 명반',
      description:
        '자미두수 명반(12궁 성요 배치)을 계산합니다. 출생 시각이 필수입니다(hour=null 거부). ' +
        'interpret=true면 궁별 해석·사화 분석을, school 지정 시 학파 분석(samhap 삼합파/sahwa 사화파/jungju 중주파)을 추가합니다.',
      inputSchema: {
        birth: BirthInputSchema,
        school: z.enum(ZIWEI_SCHOOLS).optional().describe('학파 분석 선택 (미지정 시 명반만)'),
        interpret: z.boolean().default(false).describe('true면 전체 명반 해석 포함'),
      },
      outputSchema: ziweiChartOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(
      async ({
        birth,
        school,
        interpret,
      }: {
        birth: BirthInput;
        school?: (typeof ZIWEI_SCHOOLS)[number];
        interpret: boolean;
      }) => {
        if (birth.hour === null) {
          return invalidInput('ziwei_chart는 출생 시각(hour)이 필수입니다 — 자미두수는 시주 없이 계산할 수 없습니다.');
        }
        // ziwei는 "YYYY-M-D" 제로패딩 없는 포맷 (D13)
        const dateString = formatDateLoose(birth.year, birth.month, birth.day);
        const chart =
          birth.calendarType === 'lunar'
            ? Ziwei.calculateZiweiByLunar(dateString, birth.hour, birth.gender, birth.isLeapMonth)
            : Ziwei.calculateZiwei(dateString, birth.hour, birth.gender);
        const interpretation = interpret ? interpretZiwei(chart) : undefined;
        const schoolAnalysis =
          school === 'samhap'
            ? analyzeSamhap(chart)
            : school === 'sahwa'
              ? analyzeSahwa(chart)
              : school === 'jungju'
                ? analyzeJungju(chart)
                : undefined;
        return {
          content: [{ type: 'text' as const, text: summarizeZiwei(chart, school) }],
          structuredContent: {
            meta: { ...ENGINE_META },
            ...(school ? { school } : {}),
            chart,
            ...(interpretation ? { interpretation } : {}),
            ...(schoolAnalysis ? { schoolAnalysis } : {}),
          },
        };
      },
    ),
  );

  server.registerTool(
    'qimen_chart',
    {
      title: '기문둔갑 포국',
      description:
        '기문둔갑 시국 포국(양둔/음둔·국수·9궁 문/성/신 배치·격국·직부/직사)을 계산합니다. 점단 시각(양력 날짜+시) 기준. ' +
        'interpret=true면 궁별 해석을, school 지정 시 학파 분석을 추가합니다(siguk 시국/yeonguk 연국/wolguk 월국/hongyeon 홍연기문 — hongyeon은 birth 또는 palja 추가 필수).',
      inputSchema: {
        ...dateFields,
        school: z.enum(QIMEN_SCHOOLS).optional().describe('학파 분석 선택 (기본 포국은 시국 기준)'),
        interpret: z.boolean().default(false).describe('true면 궁별 해석·용신 추천 포함'),
        birth: BirthInputSchema.optional().describe('school=hongyeon일 때 팔자 계산용 출생 정보'),
        palja: PaljaInputSchema.optional().describe('school=hongyeon일 때 직접 제공하는 팔자 (birth 대신)'),
      },
      outputSchema: qimenChartOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(
      async ({
        year,
        month,
        day,
        hour,
        school,
        interpret,
        birth,
        palja,
      }: {
        year: number;
        month: number;
        day: number;
        hour: number;
        school?: (typeof QIMEN_SCHOOLS)[number];
        interpret: boolean;
        birth?: BirthInput;
        palja?: PaljaInput;
      }) => {
        // qimen은 "YYYY-MM-DD" 제로패딩 포맷 (D13)
        const dateString = formatDateDashed(year, month, day);
        if (school !== 'hongyeon' && (birth !== undefined || palja !== undefined)) {
          return invalidInput('birth/palja는 school=hongyeon에서만 사용합니다.', { school });
        }
        let schoolAnalysis: object | undefined;
        if (school === 'hongyeon') {
          const validationError = validateBirthOrPalja({ birth, palja });
          if (validationError) {
            return invalidInput(`school=hongyeon은 팔자가 필요합니다 — ${validationError}`);
          }
          schoolAnalysis = analyzeHongyeonQimen(dateString, hour, resolvePalja({ birth, palja }));
        } else if (school === 'siguk') {
          schoolAnalysis = analyzeSiguk(dateString, hour);
        } else if (school === 'yeonguk') {
          schoolAnalysis = analyzeYeonguk(dateString, hour);
        } else if (school === 'wolguk') {
          schoolAnalysis = analyzeWolguk(dateString, hour);
        }
        const chart = Qimen.calculateQimen(dateString, hour);
        const interpretation = interpret ? interpretQimen(chart) : undefined;
        return {
          content: [{ type: 'text' as const, text: summarizeQimen(chart, hour, school) }],
          structuredContent: {
            meta: { ...ENGINE_META },
            ...(school ? { school } : {}),
            chart,
            ...(interpretation ? { interpretation } : {}),
            ...(schoolAnalysis ? { schoolAnalysis } : {}),
          },
        };
      },
    ),
  );

  server.registerTool(
    'daeyukim_chart',
    {
      title: '대육임 과식',
      description:
        '대육임 과식(천지반 12궁·사과·삼전·12천장·과명)을 계산합니다. 점단 시각(양력 날짜+시) 기준. interpret=true면 사과/삼전 해석을 추가합니다.',
      inputSchema: {
        ...dateFields,
        interpret: z.boolean().default(false).describe('true면 사과·삼전·과명 해석 포함'),
      },
      outputSchema: daeyukimChartOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(
      async ({ year, month, day, hour, interpret }: { year: number; month: number; day: number; hour: number; interpret: boolean }) => {
        const dateString = formatDateDashed(year, month, day);
        const chart = Daeyukim.calculateDaeyukim(dateString, hour);
        const interpretation = interpret ? interpretDaeyukim(chart) : undefined;
        return {
          content: [{ type: 'text' as const, text: summarizeDaeyukim(chart, hour) }],
          structuredContent: {
            meta: { ...ENGINE_META },
            chart,
            ...(interpretation ? { interpretation } : {}),
          },
        };
      },
    ),
  );

  server.registerTool(
    'guseong_chart',
    {
      title: '구성기학 포국',
      description:
        '구성기학의 본명성과 연반/월반/일반 구궁 배치를 계산합니다. 대상일(targetYear/Month/Day)은 셋 다 지정하거나 모두 생략합니다(생략 시 KST 오늘).',
      inputSchema: {
        birthYear: z.number().int().describe('출생 연도 (양력)'),
        gender: z.enum(['male', 'female']),
        targetYear: z.number().int().optional().describe('대상 연도 — targetMonth/targetDay와 함께 지정'),
        targetMonth: z.number().int().min(1).max(12).optional(),
        targetDay: z.number().int().min(1).max(31).optional(),
      },
      outputSchema: guseongChartOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(
      async ({
        birthYear,
        gender,
        targetYear,
        targetMonth,
        targetDay,
      }: {
        birthYear: number;
        gender: 'male' | 'female';
        targetYear?: number;
        targetMonth?: number;
        targetDay?: number;
      }) => {
        const specified = [targetYear, targetMonth, targetDay].filter((v) => v !== undefined).length;
        if (specified !== 0 && specified !== 3) {
          return invalidInput('targetYear/targetMonth/targetDay는 셋 다 지정하거나 모두 생략해야 합니다.', {
            targetYear,
            targetMonth,
            targetDay,
          });
        }
        // 생략 시 KST 기준 오늘 — 서버 프로세스 타임존에 의존하지 않는다 (검토 F7)
        const target =
          specified === 3
            ? { year: targetYear!, month: targetMonth!, day: targetDay! }
            : todayKst();
        const result = Guseong.calculateGuseong(birthYear, gender, target.year, target.month, target.day);
        return {
          content: [{ type: 'text' as const, text: summarizeGuseong(result.bonmyeongseong, target) }],
          structuredContent: { meta: { ...ENGINE_META }, target, result },
        };
      },
    ),
  );
}

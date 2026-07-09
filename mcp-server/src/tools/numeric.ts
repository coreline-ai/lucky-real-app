// F그룹: 수리형 툴 4종 — 하락이수·대정수·홍연·매화역수 (dev-plan 툴 카탈로그 F)
// daejeong/hongyeon은 birth|palja 유니온 입력 (D5), 시주 미상('') 허용 (D11 — 3주 기준 계산).
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { Daejeong, Harak, Hongyeon, Maehwa } from 'manseryeok-engine';
import { z } from 'zod';

import { invalidInput, withErrorMapping } from '../errors.js';
import { ENGINE_META } from '../meta.js';
import {
  summarizeDaejeongReading,
  summarizeHarak,
  summarizeHongyeonReading,
  summarizeMaehwa,
} from '../render/summary.js';
import { BirthInputSchema } from '../schemas/birth.js';
import type { BirthInput } from '../schemas/birth.js';
import {
  daejeongReadingOutput,
  harakReadingOutput,
  hongyeonReadingOutput,
  maehwaDivinationOutput,
} from '../schemas/output.js';
import { PaljaInputSchema, resolvePalja, validateBirthOrPalja } from '../schemas/palja.js';
import type { PaljaInput } from '../schemas/palja.js';

const READ_ONLY = { readOnlyHint: true, openWorldHint: false } as const;

/** birth|palja 유니온 입력 필드 (daejeong·hongyeon 공용) */
const birthOrPaljaFields = {
  birth: BirthInputSchema.optional().describe('출생 정보 — 서버가 팔자를 선계산 (palja와 택1)'),
  palja: PaljaInputSchema.optional().describe(
    'saju_palja 결과 등 이미 계산된 팔자 재사용 (birth와 택1). 시주 미상은 hourGan/hourJi 빈 문자열',
  ),
};

interface BirthOrPaljaArgs {
  birth?: BirthInput;
  palja?: PaljaInput;
}

export function registerNumericTools(server: McpServer): void {
  server.registerTool(
    'harak_reading',
    {
      title: '하락이수',
      description:
        '하락이수(河洛理數)로 생년월일의 하도수·낙서수와 64괘를 계산합니다. 연·월·일 숫자를 그대로 수리 계산에 사용합니다(시각 불필요).',
      inputSchema: {
        year: z.number().int().describe('생년'),
        month: z.number().int().min(1).max(12).describe('생월'),
        day: z.number().int().min(1).max(31).describe('생일'),
      },
      outputSchema: harakReadingOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ year, month, day }: { year: number; month: number; day: number }) => {
      const result = Harak.calculateHarak(year, month, day);
      return {
        content: [{ type: 'text' as const, text: summarizeHarak(result) }],
        structuredContent: { meta: { ...ENGINE_META }, result },
      };
    }),
  );

  server.registerTool(
    'daejeong_reading',
    {
      title: '대정수 작괘',
      description:
        '사주 팔자의 선천수·후천수 합으로 64괘와 변효를 작괘합니다(대정수작괘). birth 또는 palja 중 하나로 팔자를 지정합니다. ' +
        '시주 미상이면 3주(년월일) 기준으로 계산되며 결과가 달라집니다.',
      inputSchema: birthOrPaljaFields,
      outputSchema: daejeongReadingOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ birth, palja }: BirthOrPaljaArgs) => {
      const validationError = validateBirthOrPalja({ birth, palja });
      if (validationError) return invalidInput(validationError);
      const resolved = resolvePalja({ birth, palja });
      const hourKnown = resolved.hourGan !== '';
      const result = Daejeong.calculateDaejeong(resolved);
      return {
        content: [{ type: 'text' as const, text: summarizeDaejeongReading(result, hourKnown) }],
        structuredContent: {
          meta: { ...ENGINE_META },
          paljaSource: palja ? ('palja' as const) : ('birth' as const),
          hourKnown,
          palja: resolved,
          result,
        },
      };
    }),
  );

  server.registerTool(
    'hongyeon_reading',
    {
      title: '홍연 분석',
      description:
        '홍연(홍국수) 분석: 팔자의 하도수 합산으로 홍국수·본명성·구궁 배치·통기도를 계산합니다. birth 또는 palja 중 하나로 팔자를 지정합니다. ' +
        '시주 미상이면 3주의 하도수만 합산합니다(엔진 정본 동작).',
      inputSchema: birthOrPaljaFields,
      outputSchema: hongyeonReadingOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ birth, palja }: BirthOrPaljaArgs) => {
      const validationError = validateBirthOrPalja({ birth, palja });
      if (validationError) return invalidInput(validationError);
      const resolved = resolvePalja({ birth, palja });
      const hourKnown = resolved.hourGan !== '';
      const result = Hongyeon.analyzeHongyeon(resolved);
      return {
        content: [{ type: 'text' as const, text: summarizeHongyeonReading(result, hourKnown) }],
        structuredContent: {
          meta: { ...ENGINE_META },
          paljaSource: palja ? ('palja' as const) : ('birth' as const),
          hourKnown,
          palja: resolved,
          result,
        },
      };
    }),
  );

  server.registerTool(
    'maehwa_divination',
    {
      title: '매화역수 점단',
      description:
        '매화역수(梅花易數)로 점괘를 냅니다. 세 가지 작괘 방식: time(날짜+시각), number(두 수), name(성/이름 획수). ' +
        '본괘·변효·체용 관계와 해석을 반환합니다. 질문 내용은 입력하지 않습니다 — 해석 적용은 호출 측 책임입니다.',
      inputSchema: {
        cast: z
          .discriminatedUnion('method', [
            z.object({
              method: z.literal('time'),
              year: z.number().int().describe('점단 연도'),
              month: z.number().int().min(1).max(12),
              day: z.number().int().min(1).max(31),
              hour: z.number().int().min(0).max(23),
            }),
            z.object({
              method: z.literal('number'),
              num1: z.number().int().positive().describe('첫 번째 수 (양의 정수)'),
              num2: z.number().int().positive().describe('두 번째 수 (양의 정수)'),
            }),
            z.object({
              method: z.literal('name'),
              surnameStrokes: z.number().int().positive().describe('성 획수 (양의 정수)'),
              givenNameStrokes: z.number().int().positive().describe('이름 획수 (양의 정수)'),
            }),
          ])
          .describe('작괘 방식과 입력'),
      },
      outputSchema: maehwaDivinationOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(
      async ({
        cast,
      }: {
        cast:
          | { method: 'time'; year: number; month: number; day: number; hour: number }
          | { method: 'number'; num1: number; num2: number }
          | { method: 'name'; surnameStrokes: number; givenNameStrokes: number };
      }) => {
        const result =
          cast.method === 'time'
            ? Maehwa.divineByTime(cast.year, cast.month, cast.day, cast.hour)
            : cast.method === 'number'
              ? Maehwa.divineByNumber(cast.num1, cast.num2)
              : Maehwa.divineByName(cast.surnameStrokes, cast.givenNameStrokes);
        return {
          content: [{ type: 'text' as const, text: summarizeMaehwa(cast.method, result) }],
          structuredContent: { meta: { ...ENGINE_META }, cast, result },
        };
      },
    ),
  );
}

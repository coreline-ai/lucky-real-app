// D그룹: 토정비결 (dev-plan 툴 카탈로그 D)
// D6: analyzeTojeong은 "음력" 생년월일 숫자를 받는다. 양력 입력은 서버가 solarToLunar로
// 자동 변환한다 (양력 1월생 → 음력 전년도 케이스 포함, QA 항목).
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { Tojeong, solarToLunar } from 'manseryeok-engine';
import { z } from 'zod';

import { withErrorMapping } from '../errors.js';
import { ENGINE_META } from '../meta.js';
import { summarizeTojeong } from '../render/summary.js';
import { BirthInputSchema } from '../schemas/birth.js';
import type { BirthInput } from '../schemas/birth.js';
import { tojeongYearlyOutput } from '../schemas/output.js';

const READ_ONLY = { readOnlyHint: true, openWorldHint: false } as const;

export function registerTojeongTools(server: McpServer): void {
  server.registerTool(
    'tojeong_yearly',
    {
      title: '토정비결 신수',
      description:
        '토정비결로 대상 연도(targetYear)의 신수를 봅니다: 144괘 중 괘 번호·시구·총운·월별 12운. ' +
        '출생 시각은 사용하지 않으며, 양력 생일은 서버가 음력으로 자동 변환합니다(응답의 lunarBirth가 실제 사용된 음력 생일).',
      inputSchema: {
        birth: BirthInputSchema,
        targetYear: z.number().int().describe('신수를 볼 대상 연도 (예: 2026)'),
      },
      outputSchema: tojeongYearlyOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ birth, targetYear }: { birth: BirthInput; targetYear: number }) => {
      // 음력 입력은 그대로, 양력 입력은 변환 (D6)
      const lunarBirth =
        birth.calendarType === 'lunar'
          ? { year: birth.year, month: birth.month, day: birth.day, isLeapMonth: birth.isLeapMonth }
          : (() => {
              const converted = solarToLunar({ year: birth.year, month: birth.month, day: birth.day });
              return {
                year: converted.year,
                month: converted.month,
                day: converted.day,
                isLeapMonth: converted.isLeapMonth,
              };
            })();
      const result = Tojeong.analyzeTojeong(lunarBirth.year, lunarBirth.month, lunarBirth.day, targetYear);
      return {
        content: [
          {
            type: 'text' as const,
            text: summarizeTojeong(lunarBirth, targetYear, result.gwae, result.interpretation.title),
          },
        ],
        structuredContent: { meta: { ...ENGINE_META }, lunarBirth, targetYear, result },
      };
    }),
  );
}

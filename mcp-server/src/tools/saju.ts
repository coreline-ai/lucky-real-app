// B그룹: 사주 툴 3종 (dev-plan 툴 카탈로그 B)
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { buildSajuResult, calculateDaeun, calculatePalja } from 'manseryeok-engine';
import type { SajuResult } from 'manseryeok-engine';
import { z } from 'zod';

import { withErrorMapping } from '../errors.js';
import { ENGINE_META } from '../meta.js';
import { summarizeDaeun, summarizePalja, summarizeSajuReading } from '../render/summary.js';
import { isBirthTimeKnown, toBirthInputData, toCalculateOptions } from '../schemas/birth.js';
import type { BirthInput } from '../schemas/birth.js';
import { BirthInputSchema } from '../schemas/birth.js';
import {
  SAJU_SECTIONS,
  SAJU_SUB_SCHOOLS,
  sajuDaeunOutput,
  sajuFullReadingOutput,
  sajuPaljaOutput,
} from '../schemas/output.js';

const READ_ONLY = { readOnlyHint: true, openWorldHint: false } as const;

type SajuSection = (typeof SAJU_SECTIONS)[number];

/** include 섹션 → SajuResult 필드 매핑 (palja는 항상 포함) */
const SECTION_FIELDS: Record<SajuSection, Array<keyof SajuResult>> = {
  sipsin: ['sipsin', 'jijangganSipsin'],
  jijanggan: ['jijanggan'],
  unsung: ['unsung'],
  daeun: ['daeun'],
  un: ['seun', 'wolun'],
  sinsal: ['sinsal'],
  relations: ['jijiRelations', 'gongmang', 'naeum', 'wonjin'],
  gyeokguk: ['gyeokguk'],
  yongsin: ['yongsin'],
};

function pickSections(result: SajuResult, sections: readonly SajuSection[]): Record<string, unknown> {
  const reading: Record<string, unknown> = { palja: result.palja };
  for (const section of sections) {
    for (const field of SECTION_FIELDS[section]) {
      if (result[field] !== undefined) {
        reading[field] = result[field];
      }
    }
  }
  return reading;
}

export function registerSajuTools(server: McpServer): void {
  server.registerTool(
    'saju_full_reading',
    {
      title: '사주 전체 분석',
      description:
        'Calculate a full Korean saju reading from birth data: palja, sipsin, hidden stems, unsung, luck cycles, sinsal, relations, gyeokguk, and yongsin. ' +
        'Use include to reduce response size. 사주 전체 계산 전용이며 해석 문구 작성은 호출 측 책임입니다.',
      inputSchema: {
        birth: BirthInputSchema,
        subSchool: z.enum(SAJU_SUB_SCHOOLS).default('gyeokguk').describe('용신 판단 학파 (기본 격국용신)'),
        include: z
          .array(z.enum(SAJU_SECTIONS))
          .optional()
          .describe('반환할 섹션 선택. 생략하면 전체 섹션 반환. palja는 항상 포함'),
      },
      outputSchema: sajuFullReadingOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(
      async ({
        birth,
        subSchool,
        include,
      }: {
        birth: BirthInput;
        subSchool: (typeof SAJU_SUB_SCHOOLS)[number];
        include?: SajuSection[];
      }) => {
        const result = buildSajuResult(toBirthInputData(birth), {
          subSchool,
          calculateOptions: toCalculateOptions(birth),
        });
        const sections: readonly SajuSection[] = include ?? SAJU_SECTIONS;
        const reading = pickSections(result, sections);
        const birthTimeKnown = isBirthTimeKnown(birth);
        return {
          content: [
            {
              type: 'text' as const,
              text: summarizeSajuReading(
                result.palja,
                birthTimeKnown,
                sections.includes('gyeokguk') ? result.gyeokguk : undefined,
                sections.includes('yongsin') ? result.yongsin : undefined,
              ),
            },
          ],
          structuredContent: {
            meta: { ...ENGINE_META },
            birthTimeKnown,
            subSchool,
            sections: [...sections],
            reading,
          },
        };
      },
    ),
  );

  server.registerTool(
    'saju_palja',
    {
      title: '사주팔자 계산 (경량)',
      description:
        'Calculate only the four-pillar palja from birth data. Unknown birth time returns empty hourGan/hourJi. ' +
        '팔자 결과는 daejeong_reading, hongyeon_reading, qimen_chart(hongyeon) 등에 재사용할 수 있습니다.',
      inputSchema: { birth: BirthInputSchema },
      outputSchema: sajuPaljaOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ birth }: { birth: BirthInput }) => {
      const palja = calculatePalja(toBirthInputData(birth), toCalculateOptions(birth));
      const birthTimeKnown = isBirthTimeKnown(birth);
      return {
        content: [{ type: 'text' as const, text: summarizePalja(palja, birthTimeKnown) }],
        structuredContent: { meta: { ...ENGINE_META }, birthTimeKnown, palja },
      };
    }),
  );

  server.registerTool(
    'saju_daeun',
    {
      title: '대운 계산',
      description:
        'Calculate daeun major luck cycles from birth data and gender. Direction depends on gender rules, and the current cycle is marked with isCurrent. 대운 목록 계산.',
      inputSchema: {
        birth: BirthInputSchema,
        count: z.number().int().min(1).max(12).default(8).describe('반환할 대운 개수 (기본 8, 최대 12)'),
      },
      outputSchema: sajuDaeunOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ birth, count }: { birth: BirthInput; count: number }) => {
      const data = toBirthInputData(birth);
      const options = toCalculateOptions(birth);
      const palja = calculatePalja(data, options);
      const daeun = calculateDaeun(palja, data, count, options);
      return {
        content: [{ type: 'text' as const, text: summarizeDaeun(daeun) }],
        structuredContent: { meta: { ...ENGINE_META }, count: daeun.length, daeun },
      };
    }),
  );
}

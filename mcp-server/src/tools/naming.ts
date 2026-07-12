// G그룹: 작명·유틸 툴 2종 (dev-plan 툴 카탈로그 G)
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import {
  CHEONGAN,
  JIJI,
  Naming,
  getKoreanForGan,
  getKoreanForJi,
  getOhaengForGan,
  getOhaengForJi,
} from 'manseryeok-engine';
import { z } from 'zod';

import { withErrorMapping } from '../errors.js';
import { ENGINE_META } from '../meta.js';
import { summarizeGanjiInfo, summarizeNaming } from '../render/summary.js';
import { ganjiInfoOutput, namingAnalyzeOutput } from '../schemas/output.js';

const READ_ONLY = { readOnlyHint: true, openWorldHint: false } as const;

const NAMING_SCHOOLS = ['kangxi', 'modern'] as const;

export function registerNamingTools(server: McpServer): void {
  server.registerTool(
    'naming_analyze',
    {
      title: '작명(성명학) 분석',
      description:
        'Analyze 1-6 Korean name candidates with naming numerology: four grids, 81-number luck, stroke/pronunciation elements, and 0-100 score. ' +
        'Provide hanjaChars to add source-element comparison. 성명학 후보 분석이며 오락·자기성찰용입니다.',
      inputSchema: {
        surname: z.string().min(1).max(2).describe('성씨 (한글, 예: 김)'),
        candidates: z
          .array(
            z.object({
              givenName: z.string().min(1).max(4).describe('이름 (한글, 성 제외)'),
              hanjaChars: z
                .array(z.string().min(1).max(1))
                .nullable()
                .optional()
                .describe("한자 배열 — 성 포함 전체 (예: ['金','民','俊']). 없으면 생략"),
            }),
          )
          .min(1)
          .max(6)
          .describe('이름 후보 목록 (1~6개)'),
        school: z.enum(NAMING_SCHOOLS).default('kangxi').describe('한자 획수 학파 (기본 강희자전)'),
      },
      outputSchema: namingAnalyzeOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(
      async ({
        surname,
        candidates,
        school,
      }: {
        surname: string;
        candidates: Array<{ givenName: string; hanjaChars?: string[] | null }>;
        school: (typeof NAMING_SCHOOLS)[number];
      }) => {
        const result = Naming.analyzeNamesExtended(surname, candidates, school);
        return {
          content: [{ type: 'text' as const, text: summarizeNaming(surname, school, result.candidates) }],
          structuredContent: { meta: { ...ENGINE_META }, result },
        };
      },
    ),
  );

  server.registerTool(
    'ganji_info',
    {
      title: '간지 한자 정보',
      description:
        'Explain each ganji hanja character in a string: Korean reading, stem/branch kind, and five-element value. Unknown characters are marked unknown. 간지 한자 정보 조회.',
      inputSchema: {
        ganji: z.string().min(1).max(60).describe('간지 한자 문자열 (공백 없이, 예: 庚午己卯)'),
      },
      outputSchema: ganjiInfoOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ ganji }: { ganji: string }) => {
      const items = [...ganji].map((hanja) => {
        if (CHEONGAN.includes(hanja)) {
          return { hanja, kind: 'gan' as const, korean: getKoreanForGan(hanja), ohaeng: getOhaengForGan(hanja) };
        }
        if (JIJI.includes(hanja)) {
          return { hanja, kind: 'ji' as const, korean: getKoreanForJi(hanja), ohaeng: getOhaengForJi(hanja) };
        }
        return { hanja, kind: 'unknown' as const, korean: null, ohaeng: null };
      });
      return {
        content: [{ type: 'text' as const, text: summarizeGanjiInfo(items) }],
        structuredContent: { meta: { ...ENGINE_META }, items },
      };
    }),
  );
}

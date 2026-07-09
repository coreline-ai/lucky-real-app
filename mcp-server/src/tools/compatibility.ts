// C그룹: 궁합 툴 (dev-plan 툴 카탈로그 C)
// 점수 산식(TS 정본): 일간 30 + 일지 25 + 오행 보완 25 + 구성(본명성) 20 = 100
// 등급 경계: S≥85, A≥70, B≥55, C≥40, D<40
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { Compatibility } from 'manseryeok-engine';

import { withErrorMapping } from '../errors.js';
import { ENGINE_META } from '../meta.js';
import { summarizeCompatibility } from '../render/summary.js';
import { toBirthInputData, toCalculateOptions } from '../schemas/birth.js';
import type { BirthInput } from '../schemas/birth.js';
import { BirthInputSchema } from '../schemas/birth.js';
import { compatibilityScoreOutput } from '../schemas/output.js';

const READ_ONLY = { readOnlyHint: true, openWorldHint: false } as const;

export function registerCompatibilityTools(server: McpServer): void {
  server.registerTool(
    'compatibility_score',
    {
      title: '궁합(케미) 점수',
      description:
        '두 사람의 생년월일시로 궁합을 계산합니다. 총점(100점: 일간 30·일지 25·오행 보완 25·구성 20)과 등급(S≥85/A≥70/B≥55/C≥40/D), ' +
        '카테고리별 점수, 일간·일지 관계, 조언, 양쪽 팔자를 반환합니다. 오락·자기성찰 목적의 계산값입니다.',
      inputSchema: {
        person1: BirthInputSchema.describe('첫 번째 사람의 출생 정보'),
        person2: BirthInputSchema.describe('두 번째 사람의 출생 정보'),
      },
      outputSchema: compatibilityScoreOutput,
      annotations: READ_ONLY,
    },
    withErrorMapping(async ({ person1, person2 }: { person1: BirthInput; person2: BirthInput }) => {
      const result = Compatibility.calculateCompatibility({
        person1: { ...toBirthInputData(person1), calculateOptions: toCalculateOptions(person1) },
        person2: { ...toBirthInputData(person2), calculateOptions: toCalculateOptions(person2) },
      });
      return {
        content: [
          {
            type: 'text' as const,
            text: summarizeCompatibility(
              result.totalScore,
              result.grade,
              result.dayGanRelation.type,
              result.dayJiRelation.type,
            ),
          },
        ],
        structuredContent: { meta: { ...ENGINE_META }, result },
      };
    }),
  );
}

// MCP 프롬프트 3종: 툴 체인 사용을 안내하는 템플릿 (dev-plan P4)
// 계산은 툴이, 해석 문구는 클라이언트 LLM이 담당한다는 역할 분리를 프롬프트에 명시한다.
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';

const SAFETY_NOTE =
  '결과는 오락·자기성찰용 콘텐츠로 전달하고, 의료·투자·법률·재무 판단으로 이어질 표현(단정적 예언, 공포 조장)은 피하세요.';

function userMessage(text: string) {
  return { messages: [{ role: 'user' as const, content: { type: 'text' as const, text } }] };
}

export function registerPrompts(server: McpServer): void {
  server.registerPrompt(
    'daily-briefing',
    {
      title: '오늘 하루 브리핑',
      description: '일진·절기와 (출생 정보가 있으면) 사주 흐름을 묶어 하루 브리핑을 만드는 툴 체인 안내',
      argsSchema: {
        date: z.string().optional().describe('조회할 날짜 YYYY-MM-DD (생략 시 오늘, KST)'),
        birth: z.string().optional().describe('출생 정보 자유 서술 (예: 1990-03-15 14:30 남성 양력)'),
      },
    },
    ({ date, birth }) =>
      userMessage(
        [
          `${date ?? '오늘(KST)'}의 하루 브리핑을 만들어 주세요.`,
          '',
          '진행 순서:',
          `1. calendar_day_info로 ${date ?? '오늘'}의 일진(간지)·음력·12신살·길흉·택일 정보를 조회하세요. 절기가 걸린 날이면 solar_terms로 정확한 입절 시각을 확인하세요.`,
          birth
            ? `2. 사용자 출생 정보(${birth})로 saju_full_reading을 호출해(필요한 섹션만 include로 선택) 오늘 일진과 원국의 관계(십신·용신 관점)를 함께 읽어 주세요.`
            : '2. 사용자가 출생 정보를 제공하면 saju_full_reading으로 원국을 계산해 오늘 일진과의 관계까지 확장하세요.',
          '3. 결과를 바탕으로 오늘의 흐름 요약 → 활동 제안 → 유의점 순서로 짧고 다정한 브리핑을 작성하세요.',
          '',
          SAFETY_NOTE,
        ].join('\n'),
      ),
  );

  server.registerPrompt(
    'couple-reading',
    {
      title: '커플·관계 궁합 리딩',
      description: '두 사람의 팔자와 궁합 점수를 계산해 관계 리딩을 만드는 툴 체인 안내',
      argsSchema: {
        person1: z.string().describe('첫 번째 사람 출생 정보 자유 서술 (예: 1990-03-15 14:30 남성)'),
        person2: z.string().describe('두 번째 사람 출생 정보 자유 서술'),
      },
    },
    ({ person1, person2 }) =>
      userMessage(
        [
          `두 사람의 궁합 리딩을 만들어 주세요. 첫 번째: ${person1} / 두 번째: ${person2}`,
          '',
          '진행 순서:',
          '1. compatibility_score로 총점(100점: 일간 30·일지 25·오행 보완 25·구성 20)과 등급(S~D), 카테고리별 점수, 일간·일지 관계를 계산하세요. 응답에 양쪽 팔자가 포함됩니다.',
          '2. 더 깊은 해석이 필요하면 각자 saju_palja/saju_full_reading으로 개별 원국을 살펴보세요.',
          '3. 점수·관계 유형을 근거로 "잘 맞는 지점 → 조심할 소통 방식 → 함께 하면 좋은 것" 순서로 균형 있게 서술하세요. 낮은 등급도 결함이 아니라 서로 다른 리듬으로 표현하세요.',
          '',
          SAFETY_NOTE,
        ].join('\n'),
      ),
  );

  server.registerPrompt(
    'naming-consult',
    {
      title: '작명 상담',
      description: '사주의 오행 분포를 참고해 이름 후보를 성명학으로 분석하는 툴 체인 안내',
      argsSchema: {
        surname: z.string().describe('성씨 (한글, 예: 김)'),
        birth: z.string().optional().describe('아이(또는 본인) 출생 정보 자유 서술 — 있으면 오행 보완 관점 추가'),
        candidates: z.string().optional().describe('이름 후보들 (쉼표 구분, 예: 민준, 서연)'),
      },
    },
    ({ surname, birth, candidates }) =>
      userMessage(
        [
          `${surname}씨 성의 작명 상담을 진행해 주세요.${candidates ? ` 후보: ${candidates}` : ''}`,
          '',
          '진행 순서:',
          birth
            ? `1. 출생 정보(${birth})로 saju_full_reading을 호출해 원국의 오행 분포와 용신을 파악하세요 — 보완이 필요한 오행이 작명의 기준점입니다.`
            : '1. 출생 정보가 제공되면 saju_full_reading으로 오행 분포·용신을 먼저 파악하세요(생략 가능).',
          '2. naming_analyze로 이름 후보(최대 6개)를 분석하세요: 원형이정 사격, 81수리 길흉, 수리·발음 오행, 종합 점수. 한자가 정해진 후보는 hanjaChars(성 포함)를 함께 넘겨 자원오행까지 확인하세요.',
          '3. 점수만 나열하지 말고, 사주 보완 오행과의 조화 → 수리 길흉 → 발음 흐름 순서로 후보별 특징을 비교해 주세요.',
          '',
          SAFETY_NOTE,
        ].join('\n'),
      ),
  );
}

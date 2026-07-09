export const DISCLAIMER =
  '오락·자기성찰용입니다. 의료·투자·법률·재무 판단을 대체하지 않습니다.';

export const MODE_IDS = [
  'iljin',
  'chemi',
  'naming',
  'solar-terms',
  'tojeong',
] as const;

export type ModeId = (typeof MODE_IDS)[number];

export function isModeId(value: string | null | undefined): value is ModeId {
  return (
    value != null && (MODE_IDS as readonly string[]).includes(value)
  );
}

export type ModeMeta = {
  id: ModeId;
  title: string;
  emoji: string;
  blurb: string;
};

export const MODE_CATALOG: ModeMeta[] = [
  {
    id: 'iljin',
    title: '오늘의 일진',
    emoji: '📅',
    blurb: '날짜 하나로 일진·음력·길흉·절기를 봅니다.',
  },
  {
    id: 'chemi',
    title: '우리 케미',
    emoji: '💞',
    blurb: '두 사람 생일로 점수·등급·조언을 봅니다.',
  },
  {
    id: 'naming',
    title: '이름 후보 체커',
    emoji: '✍️',
    blurb: '성 + 이름 후보를 점수·오행으로 비교합니다.',
  },
  {
    id: 'solar-terms',
    title: '절기 타임라인',
    emoji: '🌿',
    blurb: '한 해 24절기와 다음 입절을 봅니다.',
  },
  {
    id: 'tojeong',
    title: '토정 한 해 요약',
    emoji: '📜',
    blurb: '대상 연도 총운과 월별 12칸 신수입니다.',
  },
];

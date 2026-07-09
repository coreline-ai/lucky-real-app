import { Compatibility } from 'manseryeok-engine';
import type { Gender } from 'manseryeok-engine';

export type ChemiPersonInput = {
  year: number;
  month: number;
  day: number;
  gender: Gender;
  isLunar: boolean;
  isLeapMonth?: boolean;
  hour: number | null;
  minute: number | null;
};

export type ChemiResult = ReturnType<typeof Compatibility.calculateCompatibility>;

export type ChemiOk = {
  ok: true;
  result: ChemiResult;
};

export type ChemiErr = { ok: false; message: string };

export type ChemiOutcome = ChemiOk | ChemiErr;

function validatePerson(p: ChemiPersonInput, label: string): string | null {
  if (!Number.isInteger(p.year) || p.year < 1900 || p.year > 2101) {
    return `${label} 연도를 확인해 주세요.`;
  }
  if (!Number.isInteger(p.month) || p.month < 1 || p.month > 12) {
    return `${label} 월이 올바르지 않습니다.`;
  }
  if (!Number.isInteger(p.day) || p.day < 1 || p.day > 31) {
    return `${label} 일이 올바르지 않습니다.`;
  }
  if (p.gender !== 'male' && p.gender !== 'female') {
    return `${label} 성별을 선택해 주세요.`;
  }
  if (!p.isLunar && p.isLeapMonth) {
    return `${label}: 윤달은 음력에서만 선택할 수 있습니다.`;
  }
  return null;
}

export function runChemi(
  person1: ChemiPersonInput,
  person2: ChemiPersonInput,
): ChemiOutcome {
  const e1 = validatePerson(person1, '첫 번째 사람');
  if (e1) return { ok: false, message: e1 };
  const e2 = validatePerson(person2, '두 번째 사람');
  if (e2) return { ok: false, message: e2 };

  try {
    const result = Compatibility.calculateCompatibility({
      person1: {
        year: person1.year,
        month: person1.month,
        day: person1.day,
        hour: person1.hour,
        minute: person1.minute,
        gender: person1.gender,
        isLunar: person1.isLunar,
        isLeapMonth: person1.isLunar ? Boolean(person1.isLeapMonth) : false,
      },
      person2: {
        year: person2.year,
        month: person2.month,
        day: person2.day,
        hour: person2.hour,
        minute: person2.minute,
        gender: person2.gender,
        isLunar: person2.isLunar,
        isLeapMonth: person2.isLunar ? Boolean(person2.isLeapMonth) : false,
      },
    });
    if (
      typeof result.totalScore !== 'number' ||
      result.totalScore < 0 ||
      result.totalScore > 100
    ) {
      return { ok: false, message: '궁합 점수 형식이 올바르지 않습니다.' };
    }
    return { ok: true, result };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    return {
      ok: false,
      message: `케미 계산에 실패했습니다. (${msg})`,
    };
  }
}

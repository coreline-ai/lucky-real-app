// PaljaInput + birth|palja 유니온 해석 (D5·D11).
// 엔진 정본 표현: 시주 미상 = hourGan/hourJi 빈 문자열('') — 8자 필수가 아니다.
import { calculatePalja } from 'manseryeok-engine';
import type { Palja } from 'manseryeok-engine';
import { z } from 'zod';

import { toBirthInputData, toCalculateOptions } from './birth.js';
import type { BirthInput } from './birth.js';

export const PaljaInputSchema = z
  .object({
    yearGan: z.string().min(1).describe('연간 (한자, 예: 庚)'),
    yearJi: z.string().min(1).describe('연지 (한자, 예: 午)'),
    monthGan: z.string().min(1),
    monthJi: z.string().min(1),
    dayGan: z.string().min(1),
    dayJi: z.string().min(1),
    hourGan: z.string().default('').describe("시간(時干). 빈 문자열('') = 시주 미상 (D11)"),
    hourJi: z.string().default('').describe("시지(時支). 빈 문자열('') = 시주 미상"),
  })
  .refine((palja) => (palja.hourGan === '') === (palja.hourJi === ''), {
    message: "hourGan과 hourJi는 함께 지정하거나 함께 비워야 합니다 ('' = 시주 미상).",
    path: ['hourJi'],
  });

export type PaljaInput = z.infer<typeof PaljaInputSchema>;

export interface BirthOrPalja {
  birth?: BirthInput;
  palja?: PaljaInput;
}

/**
 * birth 또는 palja 중 하나에서 Palja를 얻는다 (정확히 하나 — 사전 검증은 핸들러 책임).
 * palja 입력은 재사용 체인에 쓰고, birth 입력은 calculatePalja로 선계산한다.
 */
export function resolvePalja(input: BirthOrPalja): Palja {
  if (input.palja) {
    return input.palja;
  }
  if (input.birth) {
    return calculatePalja(toBirthInputData(input.birth), toCalculateOptions(input.birth));
  }
  throw new Error('birth 또는 palja 중 하나는 필수입니다.');
}

/** birth/palja 정확히 하나인지 검사 — 위반 시 오류 메시지 반환, 정상이면 null */
export function validateBirthOrPalja(input: BirthOrPalja): string | null {
  const hasBirth = input.birth !== undefined;
  const hasPalja = input.palja !== undefined;
  if (hasBirth === hasPalja) {
    return 'birth 또는 palja 중 정확히 하나만 지정해야 합니다.';
  }
  return null;
}

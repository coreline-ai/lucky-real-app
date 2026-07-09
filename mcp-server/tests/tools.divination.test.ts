// D~G그룹 역술 확장 11툴 — 스냅샷(고정 입력→핵심값) + 엔진 직접 호출 대조 + 경계 케이스.
// 골든값은 P3 사전 프로브에서 엔진 직접 호출로 확정한 실측치다.
import type { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { Daejeong, Daeyukim, Guseong, Harak, Hongyeon, Tojeong } from 'manseryeok-engine';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { callTool, connectClient, expectErrorPayload, expectSuccess } from './helpers.js';

let client: Client;
/** saju_palja 재사용 체인 (D5): 1990-03-15 14:30 male의 팔자 */
let palja90: Record<string, string>;

const BIRTH_1990 = { year: 1990, month: 3, day: 15, hour: 14, minute: 30, gender: 'male' };

beforeAll(async () => {
  client = await connectClient();
  const paljaResult = await callTool(client, 'saju_palja', { birth: BIRTH_1990 });
  palja90 = (paljaResult.structuredContent as { palja: Record<string, string> }).palja;
});

afterAll(async () => {
  await client.close();
});

describe('전체 툴 카탈로그', () => {
  it('20툴이 모두 등록된다 (엔진 풀 커버리지)', async () => {
    const { tools } = await client.listTools();
    expect(tools).toHaveLength(20);
    expect(tools.map((t) => t.name)).toEqual(
      expect.arrayContaining([
        'tojeong_yearly',
        'ziwei_chart',
        'qimen_chart',
        'daeyukim_chart',
        'guseong_chart',
        'harak_reading',
        'daejeong_reading',
        'hongyeon_reading',
        'maehwa_divination',
        'naming_analyze',
        'ganji_info',
      ]),
    );
  });
});

describe('tojeong_yearly (D6 음력 자동 변환)', () => {
  it('양력 1990-03-15 → 음력 1990-2-19 자동 변환, 2026년 7괘(1-2-3)·월별 12운', async () => {
    const result = await callTool(client, 'tojeong_yearly', { birth: BIRTH_1990, targetYear: 2026 });
    const structured = expectSuccess<{
      lunarBirth: { year: number; month: number; day: number };
      result: { gwae: { gwaeNumber: number; gwaeCode: string }; interpretation: { monthly: string[] } };
    }>(result);
    expect(structured.lunarBirth).toMatchObject({ year: 1990, month: 2, day: 19 });
    expect(structured.result.gwae.gwaeNumber).toBe(7);
    expect(structured.result.gwae.gwaeCode).toBe('1-2-3');
    expect(structured.result.interpretation.monthly).toHaveLength(12);
    expect(structured.result).toEqual({ ...Tojeong.analyzeTojeong(1990, 2, 19, 2026) });
  });

  it('음력 직접 입력(1990-02-19)과 양력 입력의 결과가 일치한다', async () => {
    const viaSolar = await callTool(client, 'tojeong_yearly', { birth: BIRTH_1990, targetYear: 2026 });
    const viaLunar = await callTool(client, 'tojeong_yearly', {
      birth: { year: 1990, month: 2, day: 19, hour: null, minute: null, gender: 'male', calendarType: 'lunar' },
      targetYear: 2026,
    });
    const solarStructured = expectSuccess<{ result: unknown }>(viaSolar);
    const lunarStructured = expectSuccess<{ result: unknown }>(viaLunar);
    expect(lunarStructured.result).toEqual(solarStructured.result);
  });

  it('양력 1월생은 음력 전년도 생일로 변환해 토정비결에 전달한다', async () => {
    const result = await callTool(client, 'tojeong_yearly', {
      birth: { year: 1990, month: 1, day: 20, hour: null, minute: null, gender: 'female' },
      targetYear: 2026,
    });
    const structured = expectSuccess<{
      lunarBirth: { year: number; month: number; day: number; isLeapMonth: boolean };
      result: { gwae: { gwaeNumber: number; gwaeCode: string } };
    }>(result);
    expect(structured.lunarBirth).toEqual({ year: 1989, month: 12, day: 24, isLeapMonth: false });
    expect(structured.result.gwae.gwaeNumber).toBe(16);
    expect(structured.result.gwae.gwaeCode).toBe('1-4-8');
  });
});

describe('ziwei_chart', () => {
  it('1990-3-15 14시 male: 토오국 · 명궁 신 · 신궁 술 · 12궁 (학파+해석 포함)', async () => {
    const result = await callTool(client, 'ziwei_chart', {
      birth: BIRTH_1990,
      school: 'samhap',
      interpret: true,
    });
    const structured = expectSuccess<{
      school: string;
      chart: { fiveElementsClass: string; soulPalaceBranch: string; bodyPalaceBranch: string; palaces: unknown[] };
      interpretation: { palaceInterpretations: unknown[] };
      schoolAnalysis: { soulTriangle: { fortune: string } };
    }>(result);
    expect(structured.chart.fiveElementsClass).toBe('토오국');
    expect(structured.chart.soulPalaceBranch).toBe('신');
    expect(structured.chart.bodyPalaceBranch).toBe('술');
    expect(structured.chart.palaces).toHaveLength(12);
    expect(structured.interpretation.palaceInterpretations).toHaveLength(12);
    expect(structured.schoolAnalysis.soulTriangle.fortune).toBe('길');
    expect((result.content as Array<{ text: string }>)[0].text).toContain('토오국');
  });

  it('hour=null은 INVALID_INPUT으로 거부된다 (D9)', async () => {
    const result = await callTool(client, 'ziwei_chart', {
      birth: { ...BIRTH_1990, hour: null, minute: null },
    });
    const payload = expectErrorPayload(result);
    expect(payload.code).toBe('INVALID_INPUT');
    expect(payload.message).toContain('시각');
  });
});

describe('qimen_chart', () => {
  const CAST = { year: 2026, month: 7, day: 9, hour: 12 };

  it('2026-07-09 12시: 음둔 8국 (소서 상원) · 9궁', async () => {
    const result = await callTool(client, 'qimen_chart', { ...CAST, interpret: true });
    const structured = expectSuccess<{
      chart: { dunType: string; bureauNumber: number; solarTerm: string; yuan: string; palaces: unknown[] };
      interpretation: { summary: string };
    }>(result);
    expect(structured.chart.dunType).toBe('음둔');
    expect(structured.chart.bureauNumber).toBe(8);
    expect(structured.chart.solarTerm).toBe('소서');
    expect(structured.chart.yuan).toBe('상원');
    expect(structured.chart.palaces).toHaveLength(9);
    expect(structured.interpretation.summary.length).toBeGreaterThan(0);
  });

  it('school=hongyeon: palja 재사용 체인으로 성공 (D5)', async () => {
    const result = await callTool(client, 'qimen_chart', { ...CAST, school: 'hongyeon', palja: palja90 });
    const structured = expectSuccess<{
      school: string;
      schoolAnalysis: { hongyeonResult: { hongguksu: number }; combinedInterpretation: string };
    }>(result);
    expect(structured.school).toBe('hongyeon');
    expect(structured.schoolAnalysis.hongyeonResult.hongguksu).toBe(7);
    expect(structured.schoolAnalysis.combinedInterpretation.length).toBeGreaterThan(0);
  });

  it('school=hongyeon에서 birth/palja 둘 다 누락하면 거부된다', async () => {
    const result = await callTool(client, 'qimen_chart', { ...CAST, school: 'hongyeon' });
    const payload = expectErrorPayload(result);
    expect(payload.code).toBe('INVALID_INPUT');
    expect(payload.message).toContain('팔자');
  });

  it('school=hongyeon에서 birth/palja를 동시에 주면 정확히 하나 규칙으로 거부된다', async () => {
    const result = await callTool(client, 'qimen_chart', {
      ...CAST,
      school: 'hongyeon',
      birth: BIRTH_1990,
      palja: palja90,
    });
    const payload = expectErrorPayload(result);
    expect(payload.code).toBe('INVALID_INPUT');
    expect(payload.message).toContain('정확히 하나');
  });

  it('school 미지정인데 palja를 주면 거부된다', async () => {
    const result = await callTool(client, 'qimen_chart', { ...CAST, palja: palja90 });
    expect(expectErrorPayload(result).code).toBe('INVALID_INPUT');
  });

  it('hour=null은 스키마 검증에서 거부된다', async () => {
    const result = await callTool(client, 'qimen_chart', { ...CAST, hour: null });
    expect(result.isError).toBe(true);
    expect((result.content as Array<{ text: string }>)[0].text).toContain('Input validation error');
  });

  it('school=siguk: 학파 분석이 추가된다', async () => {
    const result = await callTool(client, 'qimen_chart', { ...CAST, school: 'siguk' });
    const structured = expectSuccess<{ schoolAnalysis: { summary: string } }>(result);
    expect(structured.schoolAnalysis.summary.length).toBeGreaterThan(0);
  });
});

describe('daeyukim_chart', () => {
  it('2026-07-09 12시: 사과 4·삼전 3·천지반 12 (엔진 대조)', async () => {
    const result = await callTool(client, 'daeyukim_chart', { year: 2026, month: 7, day: 9, hour: 12, interpret: true });
    const structured = expectSuccess<{
      chart: { gwaMyeong: string; saGwa: unknown[]; samJeon: unknown[]; cheonJiBan: unknown[] };
      interpretation: { summary: string };
    }>(result);
    const direct = Daeyukim.calculateDaeyukim('2026-07-09', 12);
    expect(structured.chart).toEqual({ ...direct });
    expect(structured.chart.saGwa).toHaveLength(4);
    expect(structured.chart.samJeon).toHaveLength(3);
    expect(structured.chart.cheonJiBan).toHaveLength(12);
    expect(structured.chart.gwaMyeong.length).toBeGreaterThan(0);
    expect(structured.interpretation.summary.length).toBeGreaterThan(0);
  });

  it('hour=null은 스키마 검증에서 거부된다', async () => {
    const result = await callTool(client, 'daeyukim_chart', { year: 2026, month: 7, day: 9, hour: null });
    expect(result.isError).toBe(true);
    expect((result.content as Array<{ text: string }>)[0].text).toContain('Input validation error');
  });
});

describe('guseong_chart', () => {
  it('1990 male, 기준일 2026-07-09: 본명성 일백수성(1) (엔진 대조)', async () => {
    const result = await callTool(client, 'guseong_chart', {
      birthYear: 1990,
      gender: 'male',
      targetYear: 2026,
      targetMonth: 7,
      targetDay: 9,
    });
    const structured = expectSuccess<{
      target: { year: number };
      result: { bonmyeongseong: { name: string; number: number } };
    }>(result);
    expect(structured.result.bonmyeongseong.name).toBe('일백수성');
    expect(structured.result.bonmyeongseong.number).toBe(1);
    expect(structured.result).toEqual({ ...Guseong.calculateGuseong(1990, 'male', 2026, 7, 9) });
  });

  it('target 일부만 지정하면 거부된다 (전부-또는-전무 정책)', async () => {
    const result = await callTool(client, 'guseong_chart', { birthYear: 1990, gender: 'male', targetYear: 2026 });
    expect(expectErrorPayload(result).code).toBe('INVALID_INPUT');
  });

  it('target 생략 시 KST 오늘 기준으로 계산된다 (구조 검증)', async () => {
    const result = await callTool(client, 'guseong_chart', { birthYear: 1990, gender: 'male' });
    const structured = expectSuccess<{ target: { year: number; month: number; day: number } }>(result);
    expect(structured.target.year).toBeGreaterThanOrEqual(2026);
  });
});

describe('harak_reading', () => {
  it('1990-3-15: 36괘 지화명이 (하도수 2 · 낙서수 5)', async () => {
    const result = await callTool(client, 'harak_reading', { year: 1990, month: 3, day: 15 });
    const structured = expectSuccess<{
      result: { hexagramNumber: number; hexagramName: string; hadosu: number; nakseosu: number };
    }>(result);
    expect(structured.result.hexagramNumber).toBe(36);
    expect(structured.result.hexagramName).toContain('지화명이');
    expect(structured.result.hadosu).toBe(2);
    expect(structured.result.nakseosu).toBe(5);
    expect(structured.result).toEqual({ ...Harak.calculateHarak(1990, 3, 15) });
  });
});

describe('daejeong_reading (birth|palja 유니온, D5·D11)', () => {
  it('palja 재사용: 9괘 풍천소축 · 변효 2', async () => {
    const result = await callTool(client, 'daejeong_reading', { palja: palja90 });
    const structured = expectSuccess<{
      paljaSource: string;
      hourKnown: boolean;
      result: { hexagramNumber: number; hexagramName: string; changingLine: number };
    }>(result);
    expect(structured.paljaSource).toBe('palja');
    expect(structured.hourKnown).toBe(true);
    expect(structured.result.hexagramNumber).toBe(9);
    expect(structured.result.hexagramName).toBe('풍천소축');
    expect(structured.result.changingLine).toBe(2);
  });

  it('birth 입력도 동일한 결과를 낸다 (선계산 경로)', async () => {
    const result = await callTool(client, 'daejeong_reading', { birth: BIRTH_1990 });
    const structured = expectSuccess<{ paljaSource: string; result: { hexagramNumber: number } }>(result);
    expect(structured.paljaSource).toBe('birth');
    expect(structured.result.hexagramNumber).toBe(9);
  });

  it('시주 미상이면 3주 기준 61괘로 달라지고 요약에 표기된다 (D11)', async () => {
    const result = await callTool(client, 'daejeong_reading', {
      birth: { ...BIRTH_1990, hour: null, minute: null },
    });
    const structured = expectSuccess<{ hourKnown: boolean; result: { hexagramNumber: number } }>(result);
    expect(structured.hourKnown).toBe(false);
    expect(structured.result.hexagramNumber).toBe(61);
    expect((result.content as Array<{ text: string }>)[0].text).toContain('시주 미상(3주) 기준');
  });

  it('birth와 palja를 동시에 주면 거부된다', async () => {
    const result = await callTool(client, 'daejeong_reading', { birth: BIRTH_1990, palja: palja90 });
    expect(expectErrorPayload(result).code).toBe('INVALID_INPUT');
  });

  it('둘 다 없으면 거부된다', async () => {
    const result = await callTool(client, 'daejeong_reading', {});
    expect(expectErrorPayload(result).code).toBe('INVALID_INPUT');
  });
});

describe('hongyeon_reading', () => {
  it('palja 재사용: 홍국수 7 · 본명성 칠적금성(금) (엔진 대조)', async () => {
    const result = await callTool(client, 'hongyeon_reading', { palja: palja90 });
    const structured = expectSuccess<{
      hourKnown: boolean;
      result: { hongguksu: number; bonmyeongseong: string; bonmyeongOhaeng: string; gugung: unknown[] };
    }>(result);
    expect(structured.hourKnown).toBe(true);
    expect(structured.result.hongguksu).toBe(7);
    expect(structured.result.bonmyeongseong).toContain('칠적금성');
    expect(structured.result.bonmyeongOhaeng).toBe('금');
    const direct = Hongyeon.analyzeHongyeon(palja90 as Parameters<typeof Hongyeon.analyzeHongyeon>[0]);
    expect(structured.result).toEqual({ ...direct });
  });

  it('시주 미상 palja(빈 시주)도 3주 합산으로 성공한다 (D11)', async () => {
    const noHourPalja = { ...palja90, hourGan: '', hourJi: '' };
    const result = await callTool(client, 'hongyeon_reading', { palja: noHourPalja });
    const structured = expectSuccess<{ hourKnown: boolean; result: { hongguksu: number } }>(result);
    expect(structured.hourKnown).toBe(false);
    expect(structured.result.hongguksu).toBeGreaterThan(0);
    expect((result.content as Array<{ text: string }>)[0].text).toContain('시주 미상(3주) 기준');
  });
});

describe('maehwa_divination (3가지 작괘 방식)', () => {
  it('time(2026-07-09 12시): 산수몽 · 변효 6 · 상극', async () => {
    const result = await callTool(client, 'maehwa_divination', {
      cast: { method: 'time', year: 2026, month: 7, day: 9, hour: 12 },
    });
    const structured = expectSuccess<{
      cast: { method: string };
      result: { hexagramName: string; changingLine: number; cheYongRelation: string };
    }>(result);
    expect(structured.result.hexagramName).toBe('산수몽');
    expect(structured.result.changingLine).toBe(6);
    expect(structured.result.cheYongRelation).toBe('상극');
  });

  it('number(7, 21): 산풍고 / name(획수 7, 11): 산화비', async () => {
    const byNumber = await callTool(client, 'maehwa_divination', {
      cast: { method: 'number', num1: 7, num2: 21 },
    });
    expect(expectSuccess<{ result: { hexagramName: string } }>(byNumber).result.hexagramName).toBe('산풍고');
    const byName = await callTool(client, 'maehwa_divination', {
      cast: { method: 'name', surnameStrokes: 7, givenNameStrokes: 11 },
    });
    expect(expectSuccess<{ result: { hexagramName: string } }>(byName).result.hexagramName).toBe('산화비');
  });

  it('0·음수는 zod에서 거부된다 (엔진은 무검증 — 서버가 차단)', async () => {
    for (const cast of [
      { method: 'number', num1: 0, num2: 5 },
      { method: 'number', num1: -3, num2: 5 },
      { method: 'name', surnameStrokes: 0, givenNameStrokes: 11 },
    ]) {
      const result = await callTool(client, 'maehwa_divination', { cast });
      expect(result.isError, JSON.stringify(cast)).toBe(true);
      const text = (result.content as Array<{ text: string }>)[0].text;
      expect(text).toContain('-32602');
    }
  });

  it('time 방식에서 hour 누락은 스키마 검증에서 거부된다', async () => {
    const result = await callTool(client, 'maehwa_divination', {
      cast: { method: 'time', year: 2026, month: 7, day: 9 },
    });
    expect(result.isError).toBe(true);
    expect((result.content as Array<{ text: string }>)[0].text).toContain('Input validation error');
  });
});

describe('naming_analyze', () => {
  it('김민준(金民俊): 70점 · 자원오행 [금,수,금] / 김서연(한자 없음): 자원 null', async () => {
    const result = await callTool(client, 'naming_analyze', {
      surname: '김',
      candidates: [
        { givenName: '민준', hanjaChars: ['金', '民', '俊'] },
        { givenName: '서연' },
      ],
    });
    const structured = expectSuccess<{
      result: {
        school: string;
        candidates: Array<{
          name: string;
          totalScore: number;
          jawonOhaeng: { ohaengs: Array<string | null> } | null;
        }>;
      };
    }>(result);
    expect(structured.result.school).toBe('kangxi');
    const [minjun, seoyeon] = structured.result.candidates;
    expect(minjun.name).toBe('민준');
    expect(minjun.totalScore).toBe(70);
    expect(minjun.jawonOhaeng?.ohaengs).toEqual(['금', '수', '금']);
    expect(seoyeon.jawonOhaeng).toBeNull();
    expect((result.content as Array<{ text: string }>)[0].text).toContain('70점');
  });

  it('DB 미등재 한자는 자원오행이 null로 표시된다', async () => {
    const result = await callTool(client, 'naming_analyze', {
      surname: '김',
      candidates: [{ givenName: '하늘', hanjaChars: ['金', '僾', '燚'] }],
    });
    const structured = expectSuccess<{
      result: { candidates: Array<{ jawonOhaeng: { ohaengs: Array<string | null> } | null }> };
    }>(result);
    expect(structured.result.candidates[0].jawonOhaeng?.ohaengs).toEqual(['금', null, null]);
  });

  it('후보 7개는 zod에서 거부된다 (최대 6)', async () => {
    const result = await callTool(client, 'naming_analyze', {
      surname: '김',
      candidates: Array.from({ length: 7 }, (_, i) => ({ givenName: `후보${i}` })),
    });
    expect(result.isError).toBe(true);
  });
});

describe('ganji_info', () => {
  it('庚午己卯 + 무효 문자: 독음·오행·unknown 분류', async () => {
    const result = await callTool(client, 'ganji_info', { ganji: '庚午X' });
    const structured = expectSuccess<{
      items: Array<{ hanja: string; kind: string; korean: string | null; ohaeng: string | null }>;
    }>(result);
    expect(structured.items).toEqual([
      { hanja: '庚', kind: 'gan', korean: '경', ohaeng: '금' },
      { hanja: '午', kind: 'ji', korean: '오', ohaeng: '화' },
      { hanja: 'X', kind: 'unknown', korean: null, ohaeng: null },
    ]);
    expect((result.content as Array<{ text: string }>)[0].text).toContain('庚(경·금)');
  });
});

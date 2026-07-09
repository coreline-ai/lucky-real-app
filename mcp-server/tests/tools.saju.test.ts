// B그룹 사주 툴 동작 검증 — 시주 미상(D11), 야자시/조자시 분기, include 필터, 대운 경계.
// 골든값은 P2 사전 프로브에서 엔진 직접 호출로 확정한 실측치다.
import type { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { callTool, connectClient, expectSuccess } from './helpers.js';

let client: Client;

beforeAll(async () => {
  client = await connectClient();
});

afterAll(async () => {
  await client.close();
});

const BIRTH_1990 = { year: 1990, month: 3, day: 15, hour: 14, minute: 30, gender: 'male' };

describe('saju_palja — 시주 미상 (D11)', () => {
  it('hour=null이면 hourGan/hourJi가 빈 문자열이고 요약에 "시주 미상"이 표기된다', async () => {
    const result = await callTool(client, 'saju_palja', {
      birth: { year: 1990, month: 3, day: 15, hour: null, minute: null, gender: 'male' },
    });
    const structured = expectSuccess<{ birthTimeKnown: boolean; palja: Record<string, string> }>(result);
    expect(structured.birthTimeKnown).toBe(false);
    expect(structured.palja.hourGan).toBe('');
    expect(structured.palja.hourJi).toBe('');
    expect(structured.palja.yearGan + structured.palja.yearJi).toBe('庚午');
    expect((result.content as Array<{ text: string }>)[0].text).toContain('시주 미상');
  });
});

describe('saju_palja — 야자시/조자시 분기 (23시대 출생)', () => {
  const lateNight = { year: 1995, month: 6, day: 15, hour: 23, minute: 30, gender: 'male' };

  it('야자시(기본): 일주 丁丑 유지, 시주 壬子', async () => {
    const result = await callTool(client, 'saju_palja', { birth: lateNight });
    const { palja } = expectSuccess<{ palja: Record<string, string> }>(result);
    expect(palja.dayGan + palja.dayJi).toBe('丁丑');
    expect(palja.hourGan + palja.hourJi).toBe('壬子');
  });

  it('조자시: 일주가 다음날 戊寅으로 전환, 시주 壬子 동일', async () => {
    const result = await callTool(client, 'saju_palja', {
      birth: { ...lateNight, midnightMode: 'joja' },
    });
    const { palja } = expectSuccess<{ palja: Record<string, string> }>(result);
    expect(palja.dayGan + palja.dayJi).toBe('戊寅');
    expect(palja.hourGan + palja.hourJi).toBe('壬子');
  });
});

describe('saju_full_reading — include 섹션 필터', () => {
  it('include 생략 시 전체 섹션이 반환된다', async () => {
    const result = await callTool(client, 'saju_full_reading', { birth: BIRTH_1990 });
    const structured = expectSuccess<{
      sections: string[];
      reading: Record<string, unknown>;
      subSchool: string;
    }>(result);
    expect(structured.subSchool).toBe('gyeokguk');
    expect(structured.sections).toHaveLength(9);
    for (const field of ['palja', 'sipsin', 'jijanggan', 'unsung', 'daeun', 'seun', 'sinsal', 'gyeokguk', 'yongsin']) {
      expect(structured.reading[field], `reading.${field}`).toBeDefined();
    }
  });

  it('include=[gyeokguk,yongsin]이면 palja+격국+용신만 반환된다', async () => {
    const result = await callTool(client, 'saju_full_reading', {
      birth: BIRTH_1990,
      include: ['gyeokguk', 'yongsin'],
    });
    const structured = expectSuccess<{ sections: string[]; reading: Record<string, unknown> }>(result);
    expect(structured.sections).toEqual(['gyeokguk', 'yongsin']);
    expect(Object.keys(structured.reading).sort()).toEqual(['gyeokguk', 'palja', 'yongsin']);
    const text = (result.content as Array<{ text: string }>)[0].text;
    expect(text).toContain('격국');
    expect(text).toContain('용신');
  });

  it('subSchool 4종이 모두 유효한 용신 결과를 낸다', async () => {
    for (const subSchool of ['gyeokguk', 'johu', 'gangyak', 'mulsang']) {
      const result = await callTool(client, 'saju_full_reading', {
        birth: BIRTH_1990,
        subSchool,
        include: ['yongsin'],
      });
      const structured = expectSuccess<{ reading: { yongsin?: { yongsin: string } } }>(result);
      expect(structured.reading.yongsin?.yongsin, `subSchool=${subSchool}`).toBeTruthy();
    }
  });
});

describe('saju_daeun — count 경계와 남녀 방향', () => {
  it('count 1/8/12 각각 정확한 개수를 반환한다', async () => {
    for (const count of [1, 8, 12]) {
      const result = await callTool(client, 'saju_daeun', { birth: BIRTH_1990, count });
      const structured = expectSuccess<{ count: number; daeun: unknown[] }>(result);
      expect(structured.count, `count=${count}`).toBe(count);
      expect(structured.daeun).toHaveLength(count);
    }
  });

  it('남성(1990-03-15): 6세 庚辰 시작, 현재 대운 isCurrent 존재', async () => {
    const result = await callTool(client, 'saju_daeun', { birth: BIRTH_1990, count: 12 });
    const structured = expectSuccess<{
      daeun: Array<{ age: number; gan: string; ji: string; isCurrent: boolean }>;
    }>(result);
    expect(structured.daeun[0].age).toBe(6);
    expect(structured.daeun[0].gan + structured.daeun[0].ji).toBe('庚辰');
    expect(structured.daeun.some((d) => d.isCurrent)).toBe(true);
  });

  it('여성(동일 사주): 3세 戊寅 시작 — 남성과 방향이 다르다', async () => {
    const result = await callTool(client, 'saju_daeun', {
      birth: { ...BIRTH_1990, gender: 'female' },
      count: 8,
    });
    const structured = expectSuccess<{ daeun: Array<{ age: number; gan: string; ji: string }> }>(result);
    expect(structured.daeun[0].age).toBe(3);
    expect(structured.daeun[0].gan + structured.daeun[0].ji).toBe('戊寅');
  });
});

// SDK 1.29 실측: registerTool의 입력 zod 검증 실패는 프로토콜 rejection이 아니라
// in-band isError 툴 결과로 반환된다 (text: "MCP error -32602: Input validation error: ...").
describe('BirthInput 교차 필드 검증 (SDK in-band 검증 오류)', () => {
  async function expectSdkValidationError(args: Record<string, unknown>, messagePart: string): Promise<void> {
    const result = await callTool(client, 'saju_palja', args);
    expect(result.isError).toBe(true);
    const text = (result.content as Array<{ text: string }>)[0].text;
    expect(text).toContain('-32602');
    expect(text).toContain('Input validation error');
    expect(text).toContain(messagePart);
  }

  it('calendarType=solar + isLeapMonth=true는 거부된다', async () => {
    await expectSdkValidationError(
      { birth: { ...BIRTH_1990, calendarType: 'solar', isLeapMonth: true } },
      'isLeapMonth=true는 calendarType=lunar에서만',
    );
  });

  it('hour=null + minute 지정은 거부된다', async () => {
    await expectSdkValidationError(
      { birth: { ...BIRTH_1990, hour: null, minute: 30 } },
      'minute은 hour와 함께',
    );
  });

  it('trueSolarTime=false + longitude 지정은 거부된다', async () => {
    await expectSdkValidationError(
      { birth: { ...BIRTH_1990, trueSolarTime: false, longitude: 127.0 } },
      'longitude는 trueSolarTime=true일 때만',
    );
  });
});

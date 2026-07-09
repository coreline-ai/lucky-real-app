// 오류 계약 검증 — 엔진 오류 코드 3종 이상 + INVALID_INPUT 전달 확인.
// (P1 프로브 실측: 지원 밖 날짜는 엔진이 plain Error를 던지므로
//  errors.ts가 MANSERYEOK_DATA_ERROR로 정규화한다 — P1 이슈 3 참조)
import type { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { callTool, connectClient, expectErrorPayload } from './helpers.js';

let client: Client;

beforeAll(async () => {
  client = await connectClient();
});

afterAll(async () => {
  await client.close();
});

describe('지원 범위 밖 날짜 → MANSERYEOK_DATA_ERROR (정규화)', () => {
  it('1898-01-01 (하한 밖)', async () => {
    const result = await callTool(client, 'calendar_day_info', { year: 1898, month: 1, day: 1 });
    const payload = expectErrorPayload(result);
    expect(payload.code).toBe('MANSERYEOK_DATA_ERROR');
    expect(payload.message).toContain('1898');
  });

  it('2102-01-01 (상한 밖)', async () => {
    const result = await callTool(client, 'calendar_day_info', { year: 2102, month: 1, day: 1 });
    expect(expectErrorPayload(result).code).toBe('MANSERYEOK_DATA_ERROR');
  });

  it('존재하지 않는 음력 날짜 (2026년 윤1월)', async () => {
    const result = await callTool(client, 'date_convert', {
      direction: 'lunar_to_solar',
      year: 2026,
      month: 1,
      day: 1,
      isLeapMonth: true,
    });
    expect(expectErrorPayload(result).code).toBe('MANSERYEOK_DATA_ERROR');
  });
});

describe('DST 전환 구간 → 법정시 오류 코드', () => {
  it('1988-05-08 02:30 → NONEXISTENT_CIVIL_TIME (봄 전환으로 사라진 시각)', async () => {
    const result = await callTool(client, 'korean_legal_time', {
      year: 1988,
      month: 5,
      day: 8,
      hour: 2,
      minute: 30,
    });
    const payload = expectErrorPayload(result);
    expect(payload.code).toBe('NONEXISTENT_CIVIL_TIME');
    expect(payload.details).toBeDefined();
  });

  it('1988-10-09 02:30 → AMBIGUOUS_CIVIL_TIME (가을 전환으로 중복된 시각)', async () => {
    const result = await callTool(client, 'korean_legal_time', {
      year: 1988,
      month: 10,
      day: 9,
      hour: 2,
      minute: 30,
    });
    const payload = expectErrorPayload(result);
    expect(payload.code).toBe('AMBIGUOUS_CIVIL_TIME');
    expect(payload.details).toBeDefined();
  });
});

describe('교차 필드 검증 → INVALID_INPUT', () => {
  it('solar_terms에 month만 지정하면 거부된다', async () => {
    const result = await callTool(client, 'solar_terms', { year: 2026, month: 2 });
    const payload = expectErrorPayload(result);
    expect(payload.code).toBe('INVALID_INPUT');
  });
});

describe('스키마 검증 → SDK in-band 입력 오류', () => {
  async function expectSdkValidationError(args: Record<string, unknown>, field: string): Promise<void> {
    const result = await callTool(client, 'korean_legal_time', args);
    expect(result.isError, `${field} 범위 오류는 성공 응답이면 안 됨`).toBe(true);
    const text = (result.content as Array<{ text: string }>)[0].text;
    expect(text).toContain('-32602');
    expect(text).toContain('Input validation error');
    expect(text).toContain(field);
  }

  it('korean_legal_time hour는 0~23 범위만 허용한다', async () => {
    await expectSdkValidationError({ year: 2026, month: 1, day: 1, hour: 99, minute: 0 }, 'hour');
  });

  it('korean_legal_time minute은 0~59 범위만 허용한다', async () => {
    await expectSdkValidationError({ year: 2026, month: 1, day: 1, hour: 1, minute: 99 }, 'minute');
  });

  it('korean_legal_time second는 0~59 범위만 허용한다', async () => {
    await expectSdkValidationError({ year: 2026, month: 1, day: 1, hour: 1, minute: 0, second: 99 }, 'second');
  });
});

// P5: 배포 형태 그대로 node dist/index.js를 띄워 stdio MCP 연결을 검증한다.
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { callTool, expectSuccess } from './helpers.js';

let client: Client;
let transport: StdioClientTransport;
let stderrText = '';

const BIRTH_1990 = { year: 1990, month: 3, day: 15, hour: 14, minute: 30, gender: 'male' };

beforeAll(async () => {
  transport = new StdioClientTransport({
    command: process.execPath,
    args: ['dist/index.js'],
    cwd: process.cwd(),
    stderr: 'pipe',
  });
  transport.stderr?.on('data', (chunk) => {
    stderrText += String(chunk);
  });
  client = new Client({ name: 'vitest-stdio', version: '0.0.0' });
  await client.connect(transport);
});

afterAll(async () => {
  await client.close();
  expect(transport.pid).toBeNull();
});

describe('stdio 실프로세스 통합', () => {
  it('dist/index.js 프로세스가 tools 20개를 노출한다', async () => {
    expect(transport.pid).toEqual(expect.any(Number));
    const { tools } = await client.listTools();
    expect(tools).toHaveLength(20);
    expect(stderrText).toContain('stdio 연결됨');
  });

  it('calendar_day_info — 2026-07-09 갑신일', async () => {
    const result = await callTool(client, 'calendar_day_info', { year: 2026, month: 7, day: 9 });
    const structured = expectSuccess<{ day: { dayGanJi: string } }>(result);
    expect(structured.day.dayGanJi).toBe('갑신');
  });

  it('saju_palja — 1990-03-15 14:30 남성 골든 팔자', async () => {
    const result = await callTool(client, 'saju_palja', { birth: BIRTH_1990 });
    const structured = expectSuccess<{ palja: Record<string, string> }>(result);
    expect(structured.palja.yearGan + structured.palja.yearJi).toBe('庚午');
    expect(structured.palja.monthGan + structured.palja.monthJi).toBe('己卯');
    expect(structured.palja.dayGan + structured.palja.dayJi).toBe('己卯');
    expect(structured.palja.hourGan + structured.palja.hourJi).toBe('辛未');
  });

  it('compatibility_score — fixture 쌍 78점 A등급', async () => {
    const result = await callTool(client, 'compatibility_score', {
      person1: BIRTH_1990,
      person2: { year: 1992, month: 7, day: 21, hour: 9, minute: 0, gender: 'female' },
    });
    const structured = expectSuccess<{ result: { totalScore: number; grade: string } }>(result);
    expect(structured.result.totalScore).toBe(78);
    expect(structured.result.grade).toBe('A');
  });

  it('tojeong_yearly — 2026년 7괘', async () => {
    const result = await callTool(client, 'tojeong_yearly', { birth: BIRTH_1990, targetYear: 2026 });
    const structured = expectSuccess<{ result: { gwae: { gwaeNumber: number; gwaeCode: string } } }>(result);
    expect(structured.result.gwae.gwaeNumber).toBe(7);
    expect(structured.result.gwae.gwaeCode).toBe('1-2-3');
  });

  it('qimen_chart — 2026-07-09 12시 음둔 8국', async () => {
    const result = await callTool(client, 'qimen_chart', { year: 2026, month: 7, day: 9, hour: 12 });
    const structured = expectSuccess<{ chart: { dunType: string; bureauNumber: number; palaces: unknown[] } }>(result);
    expect(structured.chart.dunType).toBe('음둔');
    expect(structured.chart.bureauNumber).toBe(8);
    expect(structured.chart.palaces).toHaveLength(9);
  });

  it('naming_analyze — 김민준 70점', async () => {
    const result = await callTool(client, 'naming_analyze', {
      surname: '김',
      candidates: [{ givenName: '민준', hanjaChars: ['金', '民', '俊'] }],
    });
    const structured = expectSuccess<{ result: { candidates: Array<{ name: string; totalScore: number }> } }>(result);
    expect(structured.result.candidates[0]).toMatchObject({ name: '민준', totalScore: 70 });
  });
});

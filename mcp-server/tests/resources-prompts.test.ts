// P4: 리소스 8종(meta+docs 7)·프롬프트 3종·instructions 검증.
// meta 리소스의 툴 카탈로그와 tools/list의 드리프트를 여기서 감시한다.
import type { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';

import { connectClient } from './helpers.js';

let client: Client;

beforeAll(async () => {
  client = await connectClient();
});

afterAll(async () => {
  await client.close();
});

const DOC_SLUGS = [
  'expert-reference-fixtures',
  'expert-reference-intake',
  'external-provider-intake',
  'korean-legal-time-policy',
  'professional-readiness',
  'reference-provider-register',
  'solar-terms',
];

describe('resources', () => {
  it('meta + 문서 7종 = 8개 리소스가 노출된다', async () => {
    const { resources } = await client.listResources();
    const uris = resources.map((r) => r.uri).sort();
    expect(uris).toEqual(
      ['manseryeok://meta', ...DOC_SLUGS.map((slug) => `manseryeok://docs/${slug}`)].sort(),
    );
    for (const resource of resources) {
      expect(resource.title ?? resource.name, `${resource.uri} title`).toBeTruthy();
      expect(resource.mimeType, `${resource.uri} mimeType`).toBeTruthy();
    }
  });

  it('manseryeok://meta — 버전·지원 범위·학파·오류 코드·툴 카탈로그(JSON)', async () => {
    const { contents } = await client.readResource({ uri: 'manseryeok://meta' });
    expect(contents).toHaveLength(1);
    expect(contents[0].mimeType).toBe('application/json');
    const meta = JSON.parse(contents[0].text as string) as {
      server: { name: string };
      engine: { engineVersion: string; ruleVersion: string };
      supportedRange: Record<string, string>;
      schools: Record<string, string[]>;
      errorCodes: string[];
      tools: Record<string, string[]>;
      notice: string;
    };
    expect(meta.server.name).toBe('manseryeok');
    expect(meta.engine.ruleVersion).toBe('krlt-yaja-2026.07');
    expect(meta.supportedRange.palja).toContain('1908-04-01');
    expect(meta.schools.sajuYongsin).toHaveLength(4);
    expect(meta.schools.qimen).toHaveLength(4);
    expect(meta.errorCodes).toContain('AMBIGUOUS_CIVIL_TIME');
    expect(meta.notice).toContain('오락');
  });

  it('meta의 툴 카탈로그가 tools/list와 드리프트 없이 일치한다', async () => {
    const { contents } = await client.readResource({ uri: 'manseryeok://meta' });
    const meta = JSON.parse(contents[0].text as string) as { tools: Record<string, string[]> };
    const catalogNames = Object.values(meta.tools).flat().sort();
    const { tools } = await client.listTools();
    const registeredNames = tools.map((t) => t.name).sort();
    expect(catalogNames).toEqual(registeredNames);
  });

  it('문서 7종이 모두 읽히고 markdown 본문을 반환한다', async () => {
    for (const slug of DOC_SLUGS) {
      const { contents } = await client.readResource({ uri: `manseryeok://docs/${slug}` });
      expect(contents[0].mimeType, slug).toBe('text/markdown');
      expect((contents[0].text as string).length, slug).toBeGreaterThan(100);
    }
  });

  it('korean-legal-time-policy 본문에 법정시 정책 내용이 담겨 있다', async () => {
    const { contents } = await client.readResource({ uri: 'manseryeok://docs/korean-legal-time-policy' });
    expect(contents[0].text as string).toMatch(/법정시|표준시|서머타임|DST/);
  });
});

describe('prompts', () => {
  it('3종 프롬프트가 노출된다', async () => {
    const { prompts } = await client.listPrompts();
    expect(prompts.map((p) => p.name).sort()).toEqual(['couple-reading', 'daily-briefing', 'naming-consult']);
  });

  it('daily-briefing — calendar_day_info→saju_full_reading 체인과 안전 고지를 안내한다', async () => {
    const result = await client.getPrompt({
      name: 'daily-briefing',
      arguments: { date: '2026-07-09', birth: '1990-03-15 14:30 남성 양력' },
    });
    expect(result.messages).toHaveLength(1);
    expect(result.messages[0].role).toBe('user');
    const text = (result.messages[0].content as { text: string }).text;
    expect(text).toContain('2026-07-09');
    expect(text).toContain('calendar_day_info');
    expect(text).toContain('saju_full_reading');
    expect(text).toContain('1990-03-15 14:30');
    expect(text).toContain('오락');
  });

  it('couple-reading — compatibility_score 체인을 안내한다', async () => {
    const result = await client.getPrompt({
      name: 'couple-reading',
      arguments: { person1: '1990-03-15 14:30 남성', person2: '1992-07-21 09:00 여성' },
    });
    const text = (result.messages[0].content as { text: string }).text;
    expect(text).toContain('compatibility_score');
    expect(text).toContain('saju_palja');
    expect(text).toContain('1992-07-21');
  });

  it('naming-consult — saju_full_reading→naming_analyze 체인을 안내한다', async () => {
    const result = await client.getPrompt({
      name: 'naming-consult',
      arguments: { surname: '김', candidates: '민준, 서연' },
    });
    const text = (result.messages[0].content as { text: string }).text;
    expect(text).toContain('김');
    expect(text).toContain('naming_analyze');
    expect(text).toContain('hanjaChars');
    expect(text).toContain('민준');
  });
});

describe('instructions (안전 고지 확정본)', () => {
  it('오락·자기성찰 목적, 판단 불가 영역, KST, 지원 범위, palja 재사용 팁이 명시된다', () => {
    const instructions = client.getInstructions();
    expect(instructions).toBeDefined();
    for (const required of ['오락', '의료', '투자', '법률', 'KST', '1908-04-01', 'saju_palja', 'manseryeok://meta']) {
      expect(instructions, `instructions에 "${required}" 포함`).toContain(required);
    }
  });
});

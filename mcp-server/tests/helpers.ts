// 테스트 공용: InMemoryTransport로 서버·클라이언트 페어를 연결한다.
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { InMemoryTransport } from '@modelcontextprotocol/sdk/inMemory.js';
import type { CallToolResult } from '@modelcontextprotocol/sdk/types.js';
import { expect } from 'vitest';

import { createServer } from '../src/server.js';

export async function connectClient(): Promise<Client> {
  const server = createServer();
  const [clientTransport, serverTransport] = InMemoryTransport.createLinkedPair();
  const client = new Client({ name: 'vitest', version: '0.0.0' });
  await Promise.all([server.connect(serverTransport), client.connect(clientTransport)]);
  return client;
}

export async function callTool(
  client: Client,
  name: string,
  args: Record<string, unknown>,
): Promise<CallToolResult> {
  return (await client.callTool({ name, arguments: args })) as CallToolResult;
}

/** 오류 계약: isError + content[0].text가 { code, message } JSON */
export function expectErrorPayload(result: CallToolResult): { code: string; message: string; details?: unknown } {
  expect(result.isError, `오류 응답이어야 하는데 성공 응답임: ${JSON.stringify(result.structuredContent ?? result.content)}`).toBe(true);
  const first = (result.content as Array<{ type: string; text: string }>)[0];
  expect(first?.type).toBe('text');
  const payload = JSON.parse(first.text) as { code: string; message: string; details?: unknown };
  expect(typeof payload.code).toBe('string');
  expect(typeof payload.message).toBe('string');
  return payload;
}

/** 성공 계약: structuredContent 존재 + meta 포함 + content 한 줄 텍스트 */
export function expectSuccess<T = Record<string, unknown>>(result: CallToolResult): T {
  expect(result.isError ?? false, `성공 응답이어야 하는데 오류임: ${JSON.stringify(result.content)}`).toBe(false);
  const structured = result.structuredContent as Record<string, unknown> | undefined;
  expect(structured, 'structuredContent 누락').toBeDefined();
  const meta = (structured as { meta?: { engineVersion?: unknown; ruleVersion?: unknown } }).meta;
  expect(meta?.engineVersion).toBeTypeOf('string');
  expect(meta?.ruleVersion).toBe('krlt-yaja-2026.07');
  const first = (result.content as Array<{ type: string; text: string }>)[0];
  expect(first?.type).toBe('text');
  expect(first.text.length).toBeGreaterThan(0);
  return structured as T;
}

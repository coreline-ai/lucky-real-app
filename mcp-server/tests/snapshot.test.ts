// P5: MCP 외부 표면(tools/resources/prompts)을 스냅샷으로 고정한다.
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

function requiredFields(schema: unknown): string[] {
  if (!schema || typeof schema !== 'object') return [];
  const required = (schema as { required?: unknown }).required;
  return Array.isArray(required) ? required.map(String).sort() : [];
}

describe('MCP 표면 스냅샷', () => {
  it('tools/list — 이름·제목·설명·필수 입력·annotations·outputSchema 유무', async () => {
    const { tools } = await client.listTools();
    const summary = tools
      .map((tool) => ({
        name: tool.name,
        title: tool.title ?? null,
        description: tool.description ?? null,
        required: requiredFields(tool.inputSchema),
        annotations: {
          readOnlyHint: tool.annotations?.readOnlyHint ?? null,
          openWorldHint: tool.annotations?.openWorldHint ?? null,
        },
        hasOutputSchema: tool.outputSchema !== undefined,
      }))
      .sort((a, b) => a.name.localeCompare(b.name));

    expect(summary).toMatchSnapshot();
  });

  it('resources/list — uri·title·mimeType', async () => {
    const { resources } = await client.listResources();
    const summary = resources
      .map((resource) => ({
        uri: resource.uri,
        title: resource.title ?? resource.name ?? null,
        mimeType: resource.mimeType ?? null,
      }))
      .sort((a, b) => a.uri.localeCompare(b.uri));

    expect(summary).toMatchSnapshot();
  });

  it('prompts/list — 이름·인자명·필수 여부', async () => {
    const { prompts } = await client.listPrompts();
    const summary = prompts
      .map((prompt) => ({
        name: prompt.name,
        arguments: (prompt.arguments ?? [])
          .map((argument) => ({
            name: argument.name,
            required: argument.required ?? false,
          }))
          .sort((a, b) => a.name.localeCompare(b.name)),
      }))
      .sort((a, b) => a.name.localeCompare(b.name));

    expect(summary).toMatchSnapshot();
  });
});

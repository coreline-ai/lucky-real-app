#!/usr/bin/env node
// stdio 엔트리. stdout은 JSON-RPC 채널이므로 로그는 stderr(console.error)만 사용한다.
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

import { SERVER_NAME, SERVER_VERSION } from './meta.js';
import { createServer } from './server.js';

async function main(): Promise<void> {
  const server = createServer();
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error(`${SERVER_NAME}-mcp v${SERVER_VERSION} — stdio 연결됨`);
}

main().catch((error: unknown) => {
  console.error('치명적 오류로 서버를 시작하지 못했습니다:', error);
  process.exit(1);
});

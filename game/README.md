# 일진 수호신 카드 배틀 MCP Demo

`game/`은 브라우저 미니게임이 실제 `manseryeok-mcp` Streamable HTTP 서버를 호출해 플레이어 일주와 KST 오늘 일진 보스를 계산하는 데모입니다.

## 요구사항

- Node.js 18+
- repo 루트에서 `engine/`, `mcp-server/`, `game/` 의존성 설치 완료
- MCP HTTP 서버는 기본 `127.0.0.1:3100` 에서 실행

## 환경 변수

`.env.example` 기본값:

```bash
VITE_USE_MCP=true
VITE_MCP_URL=/mcp
VITE_MCP_STRICT=false
```

| 변수 | 의미 |
|---|---|
| `VITE_USE_MCP` | `true`면 MCP 우선, `false`면 local engine only |
| `VITE_MCP_URL` | 기본 `/mcp`; Vite proxy가 `http://127.0.0.1:3100/mcp`로 전달 |
| `VITE_MCP_STRICT` | `true`면 MCP 실패 시 local fallback 금지 |

## 5분 실행 절차

터미널 1:

```bash
cd mcp-server
npm run build
npm run start:http
```

터미널 2:

```bash
cd game
npm run dev
```

브라우저에서 `http://localhost:5173` 접속 후 기본 입력값으로 실행합니다.

## 데모 시나리오

1. `http://127.0.0.1:3100/health` 가 `ok: true`인지 확인합니다.
2. 게임에서 `홍길동 / 1990-03-15 / 14:30 / 남성`으로 수호신을 소환합니다.
3. 로비 상단의 `via manseryeok-mcp` 배지, `tools: saju_palja, calendar_day_info`, `engine/rule` 메타를 확인합니다.
4. DevTools Network에서 `/mcp` 요청의 JSON-RPC `initialize`, `notifications/initialized`, `tools/call`을 확인합니다.
5. 배틀 3라운드를 완주해 결과 모달을 확인합니다.
6. `VITE_MCP_STRICT=false`에서 MCP 서버를 끄고 다시 제출하면 `via local-engine` 폴백 배너가 표시되어야 합니다.
7. `VITE_MCP_STRICT=true`에서 서버를 끄면 폴백 없이 명확한 에러가 표시되어야 합니다.

## MCP 증명 포인트

- 브라우저에는 `@modelcontextprotocol/sdk` full client를 번들하지 않습니다.
- `McpClientProvider`는 최소 JSON-RPC helper로 `initializePromise`를 공유하고, 모든 `tools/call` 전에 초기화를 보장합니다.
- 성공 응답은 `structuredContent`만 파싱합니다.
- `calendar_day_info.day.dayGanJi`는 현재 서버가 한글 간지(`갑신`)를 반환할 수 있어 게임 내부에서 한자 간지(`甲申`)로 정규화합니다.
- MCP 실패 시 local fallback은 배지와 배너로 명시합니다. fallback 상태를 MCP 성공으로 홍보하지 않습니다.

## 안전 고지

이 게임은 오락·자기성찰용 계산 데모입니다. 의료·투자·법률·재무 판단의 근거로 사용할 수 없습니다.

# PlayMCP Registration Runbook

이 문서는 `manseryeok-mcp`를 카카오 PlayMCP 콘솔에서 임시 HTTPS endpoint로 검증하기 위한 절차다. 정식 운영 배포가 아니라, PlayMCP의 "정보 불러오기"와 대표 tool call이 현재 서버 표면과 호환되는지 확인하는 목적이다.

## Scope

- 포함: 로컬 HTTP 서버 실행, 임시 HTTPS 터널 생성, PlayMCP endpoint/auth 입력, 정보 불러오기 결과 확인, 실패 원인 분류.
- 제외: PlayMCP 계정 로그인 자동화, 정식 심사 요청, 도메인/DNS/TLS 운영 배포, 장기 호스팅.
- 보안: 임시 HTTPS URL과 token은 외부에 공유하지 않는다. 테스트가 끝나면 터널과 서버를 종료한다.

## Prerequisites

- Node.js 18 이상.
- `mcp-server` 의존성 설치 완료.
- PlayMCP 콘솔 접근 권한.
- 임시 HTTPS 터널 도구. 권장: `cloudflared`.

```bash
cloudflared --version
```

`cloudflared`가 없다면 설치 후 다시 진행한다.

## 1. Build and Local Gate

먼저 로컬에서 build/test/smoke/size report를 통과시킨다.

```bash
npm --prefix mcp-server run build
npm --prefix mcp-server test
```

토큰을 하나 정한다. 이 값은 콘솔과 로컬 서버에 동일하게 넣는다.

```bash
export MCP_AUTH_TOKEN='<secret-token>'
```

로컬 서버를 실행한다.

```bash
MCP_AUTH_TOKEN="$MCP_AUTH_TOKEN" ENABLE_DASHBOARD=false npm --prefix mcp-server run start:http
```

다른 터미널에서 smoke와 응답 크기를 확인한다.

```bash
MCP_SMOKE_AUTH_TOKEN="$MCP_AUTH_TOKEN" MCP_SMOKE_EXPECT_DASHBOARD_DISABLED=true npm --prefix mcp-server run smoke:prod
MCP_SIZE_AUTH_TOKEN="$MCP_AUTH_TOKEN" npm --prefix mcp-server run report:sizes
```

성공 기준:

- `/health` 200.
- 누락/오류 token 401.
- `X-MCP-Auth-Token` 정상 token 200.
- `tools/list` 20개.
- 20개 fixture 기반 `tools/call` 전체 통과.
- 개별 `tools/call` 응답 크기 `OK`.

## 2. Temporary HTTPS Tunnel

서버 터미널은 켜둔 상태에서 새 터미널을 열고 임시 HTTPS URL을 만든다.

```bash
cloudflared tunnel --url http://127.0.0.1:3100
```

출력되는 `https://<random>.trycloudflare.com` 형태의 URL을 복사한다. PlayMCP endpoint에는 반드시 `/mcp`를 붙인다.

```text
https://<random>.trycloudflare.com/mcp
```

## 3. PlayMCP Console Values

권장 입력값:

| Field | Value |
|---|---|
| Endpoint URL | `https://<random>.trycloudflare.com/mcp` |
| Auth type | Key/Token 또는 custom header |
| Header name | `X-MCP-Auth-Token` |
| Header value | `<secret-token>` |

대체 입력값:

| Field | Value |
|---|---|
| Header name | `Authorization` |
| Header value | `Bearer <secret-token>` |

## 4. "정보 불러오기" Success Criteria

PlayMCP 콘솔에서 "정보 불러오기"를 실행한 뒤 다음을 확인한다.

- 서버 name/version이 표시된다.
- `tools/list` 결과가 20개 tool을 포함한다.
- tool description이 영어 우선 + 한국어 보조 형태로 표시된다.
- 대표 tool call이 성공한다.
  - 권장 대표 tool: `calendar_day_info`
  - 입력 예시: `year=2026`, `month=7`, `day=10`
- 콘솔이 긴 응답을 표시하지 못하는 경우 `npm --prefix mcp-server run report:sizes` 결과와 비교한다.

현재 fixture 기준으로 개별 `tools/call` 20개는 모두 `OK`이고, `tools/list`는 약 53KB `WATCH`다. 따라서 콘솔에서 문제가 난다면 우선 `tools/list` 표시/파싱 경로를 확인한다.

## 5. Failure Diagnosis

| Symptom | Likely cause | Check |
|---|---|---|
| 401 Unauthorized | token 누락 또는 header 불일치 | `X-MCP-Auth-Token` 값이 서버의 `MCP_AUTH_TOKEN`과 같은지 확인 |
| 403 CORS | 허용되지 않은 Origin preflight | PlayMCP 요청 Origin을 확인하고 운영 `CORS_ORIGIN` 정책 검토 |
| 404 Not Found | endpoint path 누락 | URL 끝이 `/mcp`인지 확인 |
| 405 Method Not Allowed | GET/SSE 경로 호출 | PlayMCP가 Streamable HTTP POST를 쓰는지 확인 |
| 413 Payload Too Large | 요청 body 제한 초과 | `MCP_MAX_BODY_BYTES`와 요청 크기 확인 |
| Timeout | 로컬 서버/터널 중단 | `curl http://127.0.0.1:3100/health`와 cloudflared 터미널 확인 |
| tools count mismatch | build 산출물 불일치 | `npm --prefix mcp-server run build` 후 서버 재시작 |
| tool call error | fixture 또는 입력 schema 불일치 | `npm --prefix mcp-server run smoke:prod` 결과 확인 |

## 6. Result Template

수동 테스트 후 아래 내용을 이슈나 개발 문서에 기록한다.

```text
Date:
PlayMCP endpoint:
Auth header used: X-MCP-Auth-Token / Authorization
정보 불러오기: PASS / FAIL
tools/list count:
대표 tool call:
size report largest:
Failure classification:
Notes:
```

## 7. Shutdown

검증이 끝나면 다음 순서로 종료한다.

1. PlayMCP 콘솔에서 임시 endpoint/token 값을 제거하거나 비활성화한다.
2. `cloudflared tunnel` 터미널에서 `Ctrl-C`.
3. `start:http` 서버 터미널에서 `Ctrl-C`.
4. 테스트용 token을 shell history, 문서, 스크린샷에 남기지 않았는지 확인한다.

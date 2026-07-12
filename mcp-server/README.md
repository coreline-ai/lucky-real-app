# manseryeok-mcp

`manseryeok-mcp`는 repo 루트의 TypeScript 계산 엔진 `manseryeok-engine@0.1.0`을 MCP(Model Context Protocol) stdio 서버로 노출합니다. Claude Code, Claude Desktop, MCP Inspector 같은 클라이언트가 로컬 프로세스 연결만으로 만세력·사주·궁합·토정비결·명반형 차트·작명 계산을 호출할 수 있습니다.

계산 규칙은 `krlt-yaja-2026.07`이며, 모든 응답은 오락·자기성찰 목적의 계산값입니다. 의료, 투자, 법률, 재무 판단의 근거로 사용할 수 없습니다.

## Requirements

- Node.js 18 이상
- repo 루트의 `engine/` 패키지
- 네트워크 런타임 호출 없음: 모든 툴은 로컬 결정론적 계산입니다.

## Install, Build, Test

```bash
cd mcp-server
npm install
npm run build
npm test
```

`npm test`는 `pretest`에서 `npm run build`를 먼저 실행합니다. `build`는 `prebuild`를 통해 `../engine`도 함께 빌드합니다.

## Run

```bash
cd mcp-server
node dist/index.js
```

stdio의 stdout은 JSON-RPC 채널입니다. 서버 진단 로그는 stderr만 사용합니다.


## Streamable HTTP for Browser Demo

기존 stdio 엔트리는 유지하며, 브라우저 데모용 HTTP 엔트리는 별도 프로세스로 실행합니다.

```bash
cd mcp-server
npm run build
npm run start:http
```

| Endpoint | Purpose | Notes |
|---|---|---|
| `GET /health` | 운영 확인 | 서버/엔진 메타와 `startedAt`, `uptimeMs`, `pid`, `requestsTotal`, `mcpRequestsTotal`, `errorsTotal` 메트릭 JSON |
| `POST /mcp` | MCP Streamable HTTP | stateless + `enableJsonResponse: true`; JSON-RPC `initialize` / `tools/call` |
| `GET /mcp` | SSE stream path | 이 로컬 JSON 데모에서는 405 반환 |
| `GET /dashboard` | MCP 툴 상태 대시보드 | 로컬 smoke UI: 그룹 필터·카드 뷰·한 줄 요약·Run All 진행률 |
| `GET /dashboard/fixtures` | 대시보드 fixture JSON | 각 툴별 smoke 입력 확인용 |

기본 bind는 `127.0.0.1:3100`입니다. CORS 기본 allowlist는 `http://localhost:5173,http://127.0.0.1:5173`입니다.
각 HTTP 요청은 stderr에 `method path status durationMs` 형식으로 기록하며, 민감한 request body는 로그에 남기지 않습니다.

### HTTP runtime environment

| Env | Default | Description |
|---|---:|---|
| `HOST` | `127.0.0.1` | HTTP bind host. `0.0.0.0` 등 외부 bind에서는 대시보드가 기본 비활성화됩니다. |
| `PORT` | `3100` | HTTP port |
| `CORS_ORIGIN` | `http://localhost:5173,http://127.0.0.1:5173` | 쉼표 구분 allowlist. 같은 origin 대시보드는 자동 허용됩니다. |
| `MCP_AUTH_TOKEN` | unset | 로컬 bind에서는 선택 사항입니다. `HOST=0.0.0.0` 등 외부 bind에서는 필수이며, 없으면 서버 시작이 실패합니다. 설정 시 `POST /mcp`는 `Authorization: Bearer <token>` 또는 `X-MCP-Auth-Token: <token>`이 필요합니다. `/health`와 CORS preflight는 토큰 없이 동작합니다. |
| `MCP_MAX_BODY_BYTES` | `1048576` | `Content-Length` 기준 `/mcp` 최대 요청 크기. 초과 시 413 JSON-RPC 오류를 반환합니다. chunked body는 SDK stream 소비와 충돌하지 않도록 별도 카운팅하지 않습니다. |
| `MCP_REQUEST_TIMEOUT_MS` | `30000` | Node HTTP `requestTimeout` |
| `MCP_HEADERS_TIMEOUT_MS` | `35000` | Node HTTP `headersTimeout` |
| `MCP_RATE_LIMIT_WINDOW_MS` | `60000` | `/mcp` POST in-memory rate limit window. 단일 프로세스 보호용입니다. |
| `MCP_RATE_LIMIT_MAX` | `120` | window당 remote address별 `/mcp` POST 허용 횟수. 초과 시 429 JSON-RPC 오류와 `Retry-After`를 반환합니다. |
| `ENABLE_DASHBOARD` | local bind only | `true/false`. 로컬 bind(`127.0.0.1`, `localhost`, `::1`)에서는 기본 활성화, 외부 bind에서는 `true`일 때만 `/dashboard`와 `/dashboard/fixtures`를 노출합니다. |

프로세스는 `SIGINT`/`SIGTERM`을 받으면 stderr에 종료 로그를 남기고 `server.close()`로 graceful shutdown을 시도합니다. 5초 이상 active connection이 남으면 가능한 경우 `closeAllConnections()`로 강제 종료합니다.

브라우저 점검 대시보드:

```bash
cd mcp-server
npm run dashboard
# 터미널에 출력되는 URL 확인 후 브라우저에서 열기:
#   http://127.0.0.1:3100/dashboard
```

> ⚠️ `npm start` 는 **stdio** MCP용입니다. 브라우저 대시보드는 **`npm run dashboard`** 또는 **`npm run start:http`** 로 HTTP 서버를 켠 뒤에만 동작합니다.
> 페이지가 안 열리면 `curl -s -o /dev/null -w "%{http_code}\\n" http://127.0.0.1:3100/health` 가 `200`인지 확인하세요 (서버 미기동·포트 충돌).

- **목적:** 로컬에서 PlayMCP 등록 전 preflight와 20개 툴 fixture smoke를 한눈에 확인 (제품 랜딩 아님).
- **등록 검증:** Auth mode(`none` / `X-MCP-Auth-Token` / `Authorization Bearer`)와 token을 입력해 `initialize` → `tools/list` 흐름을 재현합니다. token은 브라우저 메모리에만 사용하고 저장하지 않습니다.
- **응답 크기:** `tools/list`와 각 `tools/call`의 response byte size를 `OK` / `WATCH` / `LARGE`로 표시합니다.
- **오류 분류:** HTTP/JSON-RPC 실패를 `auth`, `cors`, `endpoint`, `protocol`, `size`, `server`, `tool`, `unknown` 범주로 표시합니다. `413 테스트`로 body limit이 `size`로 분류되는지 확인할 수 있습니다.
- **스캔 UI:** 기본 **Cards** 뷰(그룹 섹션) + **Table** 토글. 설명·payload·응답 JSON은 기본 접힘, **한 줄 요약** 우선.
- **필터:** 그룹 칩 / Failed only / 이름 검색. Run All 시 진행률 표시.
- **성공 기준:** HTTP 200 + JSON-RPC result + `isError !== true` + `structuredContent` 존재.
- 구현: `src/dashboard.ts` + `src/dashboard/*` (fixtures / styles / client / summary).

게임 데모는 [`../game/README.md`](../game/README.md)를 참고하세요. DevTools Network에서 `/mcp` 요청의 `initialize`와 `tools/call`을 확인할 수 있습니다.

### Production-style local smoke

빌드 후 실행 중인 HTTP 서버를 대상으로 운영 전 로컬 smoke를 실행합니다.

```bash
cd mcp-server
npm run build
npm run smoke:prod
```

토큰을 켠 서버를 검증할 때:

```bash
MCP_SMOKE_AUTH_TOKEN="$MCP_AUTH_TOKEN" npm run smoke:prod
```

PlayMCP Key/Token 등록에서는 커스텀 헤더 방식으로 다음 값을 우선 사용합니다.

| Field | Value |
|---|---|
| Header name | `X-MCP-Auth-Token` |
| Header value | `<MCP_AUTH_TOKEN 값>` |

`Authorization: Bearer <MCP_AUTH_TOKEN>`도 호환됩니다.

PlayMCP 콘솔의 임시 HTTPS "정보 불러오기" 검증 절차는 [`docs/playmcp-registration-runbook.md`](docs/playmcp-registration-runbook.md)를 따릅니다.

대시보드 비활성 운영 설정을 검증할 때:

```bash
MCP_SMOKE_EXPECT_DASHBOARD_DISABLED=true npm run smoke:prod
```

Smoke는 `/health`, CORS 차단, body limit `413`, `tools/list`, 20개 fixture 기반 `tools/call`, 선택적 auth negative path, 선택적 dashboard disabled gate를 확인합니다.

### Tool response size report

PlayMCP 등록 전에는 smoke fixture 기준 HTTP 응답 크기를 함께 확인합니다.

```bash
cd mcp-server
npm run build
MCP_SIZE_AUTH_TOKEN="$MCP_AUTH_TOKEN" npm run report:sizes
```

`report:sizes`는 기본적으로 PlayMCP 등록과 같은 커스텀 헤더 방식(`X-MCP-Auth-Token`)으로 `/mcp`를 호출합니다. Bearer 방식으로 확인하려면 `MCP_SIZE_AUTH_MODE=bearer`를 추가합니다.

| Status | 기준 | 처리 |
|---|---:|---|
| `OK` | `<= 32KB` | 기본 fixture 기준 문제 없음 |
| `WATCH` | `32KB ~ 100KB` | PlayMCP 콘솔 테스트에서 응답 지연/표시 상태를 확인 |
| `LARGE` | `> 100KB` | compact/include/count 제한 또는 후속 schema 정책 검토 필요 |

현재 smoke fixture 기준 측정 결과는 20개 `tools/call`이 모두 `OK`이고, `tools/list`만 tool schema/description 전체 전송 때문에 약 53KB `WATCH`입니다. `tools/list`는 compact 대상이 아니므로 PlayMCP 콘솔의 "정보 불러오기"에서 목록 표시 여부를 수동 확인합니다.

큰 응답은 계산 결과를 삭제하기보다 기존 옵션을 우선 사용합니다.

- `calendar_month`: 등록 예시와 데모 기본 호출은 `compact=true`를 우선 사용합니다.
- `saju_full_reading`: 전체 판독이 필요하지 않으면 `include`로 필요한 섹션만 요청합니다.
- `saju_daeun`: 장기 대운이 필요하지 않으면 `count`를 작게 유지합니다.
- `ziwei_chart`, `daeyukim_chart`: 해석문이 필요할 때만 `interpret=true`를 사용합니다.
- `qimen_chart`: 전체 학파 분석이 필요하지 않으면 기본 chart 결과부터 확인합니다.

### Production checklist

- [ ] `npm --prefix mcp-server test`
- [ ] `npm --prefix mcp-server audit --omit=dev`
- [ ] `npm --prefix mcp-server run smoke:prod`
- [ ] `npm --prefix mcp-server run report:sizes`
- [ ] 외부 bind(`HOST=0.0.0.0`)에서는 `MCP_AUTH_TOKEN`을 secret manager/process manager에서 주입한다. 토큰이 없으면 서버가 시작되지 않는다.
- [ ] 외부 bind에서는 `ENABLE_DASHBOARD=false` 또는 미설정 상태를 유지한다.
- [ ] Internet-facing 배포는 in-memory limit 외에도 reverse proxy/gateway rate limit을 적용한다.
- [ ] 운영 `CORS_ORIGIN`은 실제 frontend origin만 허용한다.
- [ ] DNS/HTTPS/TLS, 방화벽, process manager restart, 로그 수집/알림은 배포 인프라에서 별도 검증한다.

### PlayMCP readiness status

| Area | Status | Evidence |
|---|---|---|
| HTTP MCP endpoint | Ready for local/temporary HTTPS validation | `POST /mcp`, stateless Streamable HTTP, JSON response mode |
| Auth compatibility | Ready | `Authorization: Bearer <token>` and `X-MCP-Auth-Token: <token>` |
| Tool surface | Ready | 20 tools, stable names/schemas, English-first/Korean helper descriptions |
| Response size | Ready with watch item | 20 `tools/call` fixtures `OK`; `tools/list` about 53KB `WATCH` |
| Temporary HTTPS test | Ready | [`docs/playmcp-registration-runbook.md`](docs/playmcp-registration-runbook.md) |
| PlayMCP console click-through | Manual | 사용자 계정으로 "정보 불러오기"와 대표 tool call 확인 필요 |
| Production hosting | Manual | 정식 domain/DNS/TLS/process manager/secret rotation 필요 |

## Tool Catalog

| Group | Tool | Key Input | Output |
|---|---|---|---|
| Calendar | `calendar_day_info` | solar `year/month/day` | Daily ganji, lunar date, elements, sinsal, auspicious notes, solar terms / 하루 일진 |
| Calendar | `calendar_month` | solar `year/month`, `compact?` | Monthly ganji and daily rows; `compact=true` for smaller output / 월간 역학달력 |
| Calendar | `date_convert` | `solar_to_lunar` 또는 `lunar_to_solar` | Solar/lunar date conversion / 양력·음력 변환 |
| Calendar | `solar_terms` | `year` 또는 `year/month/day` | 24 solar terms with KST transition times / 24절기 |
| Calendar | `korean_legal_time` | 날짜+시각 | Korean legal time, standard time, DST ambiguity / 한국 법정시 |
| Saju | `saju_full_reading` | `birth`, `subSchool?`, `include?` | Full saju reading; use `include` to reduce size / 사주 전체 분석 |
| Saju | `saju_palja` | `birth` | Lightweight four-pillar palja / 사주팔자 경량 계산 |
| Saju | `saju_daeun` | `birth`, `count?` | Daeun major luck cycles / 대운 |
| Compatibility | `compatibility_score` | `person1`, `person2` | Saju compatibility score and category details / 궁합 점수 |
| Tojeong | `tojeong_yearly` | `birth`, `targetYear` | Tojeong yearly fortune and 12 monthly readings / 토정비결 |
| Charts | `ziwei_chart` | `birth`, `school?`, `interpret?` | Ziwei Dou Shu 12-palace chart / 자미두수 명반 |
| Charts | `qimen_chart` | 날짜+시각, `school?`, `birth` 또는 `palja` | Qimen Dunjia chart and optional school analysis / 기문둔갑 |
| Charts | `daeyukim_chart` | 날짜+시각, `interpret?` | Daeyukim chart and optional interpretation / 대육임 |
| Charts | `guseong_chart` | `birthYear`, `gender`, `target?` | Guseong personal star and nine-palace layouts / 구성기학 |
| Numeric | `harak_reading` | 생년월일 | Harak numerology and 64-hexagram result / 하락이수 |
| Numeric | `daejeong_reading` | `birth` 또는 `palja` | Daejeong 64-hexagram from birth or palja / 대정수 |
| Numeric | `hongyeon_reading` | `birth` 또는 `palja` | Hongyeon number, star, palace layout / 홍연 |
| Numeric | `maehwa_divination` | `time`, `number`, `name` 방식 | Meihua Yishu divination by time, numbers, or strokes / 매화역수 |
| Naming | `naming_analyze` | 성, 후보 이름, 한자, 학파 | Korean name numerology scoring / 작명 분석 |
| Naming | `ganji_info` | 간지 한자 문자열 | Ganji hanja reading, kind, and element / 간지 한자 정보 |

## Resources

| URI | Description |
|---|---|
| `manseryeok://meta` | 서버/엔진 버전, 지원 범위, 학파, 오류 코드, 툴 카탈로그 |
| `manseryeok://docs/expert-reference-fixtures` | 전문가 대조 fixture |
| `manseryeok://docs/expert-reference-intake` | 전문가 검수 입력 |
| `manseryeok://docs/external-provider-intake` | 외부 provider 비교 입력 |
| `manseryeok://docs/korean-legal-time-policy` | 한국 법정시, DST 정책 |
| `manseryeok://docs/professional-readiness` | 전문 검증 준비 상태 |
| `manseryeok://docs/reference-provider-register` | 참조 provider 등록 |
| `manseryeok://docs/solar-terms` | 절기 데이터 정책 |

## Prompts

| Prompt | Purpose |
|---|---|
| `daily-briefing` | `calendar_day_info`와 `saju_full_reading` 체인 안내 |
| `couple-reading` | `compatibility_score`와 `saju_palja` 체인 안내 |
| `naming-consult` | 사주 오행 기반 작명 후보 분석 체인 안내 |

## Error Codes

| Code | Meaning |
|---|---|
| `MANSERYEOK_RANGE_ERROR` | 엔진 지원 범위 밖 |
| `MANSERYEOK_DATA_ERROR` | 데이터 조회 실패, 존재하지 않는 날짜 |
| `AMBIGUOUS_CIVIL_TIME` | DST 전환으로 중복된 법정시 |
| `NONEXISTENT_CIVIL_TIME` | DST 전환으로 존재하지 않는 법정시 |
| `MANSERYEOK_POLICY_ERROR` | 법정시/정책상 계산 불가 |
| `INVALID_INPUT` | MCP 입력 검증 실패 또는 서버 교차 필드 검증 실패 |
| `INTERNAL_ERROR` | 예상하지 못한 내부 오류 |

오류 응답은 `isError: true`와 `content[0].text`의 JSON 문자열로 반환합니다. 성공 응답만 `structuredContent`와 `outputSchema`를 사용합니다.

## Client Setup

### Claude Code

```bash
claude mcp add manseryeok -- node /ABSOLUTE/PATH/TO/lucky_manseryeok/mcp-server/dist/index.js
```

등록 후 Claude Code에서 `/mcp`로 연결 상태와 instructions를 확인하고, `calendar_day_info` 또는 `saju_full_reading`을 호출해 검증합니다.

### Claude Desktop

```json
{
  "mcpServers": {
    "manseryeok": {
      "command": "node",
      "args": ["/ABSOLUTE/PATH/TO/lucky_manseryeok/mcp-server/dist/index.js"]
    }
  }
}
```

### MCP Inspector

```bash
cd mcp-server
npx @modelcontextprotocol/inspector node dist/index.js
```

## Usage Tips

- 모든 날짜와 시각은 KST 기준입니다.
- 출생시 미상은 `hour: null`, `minute: null`로 입력합니다. 이때 팔자의 `hourGan/hourJi`는 빈 문자열입니다.
- `daejeong_reading`, `hongyeon_reading`, `qimen_chart(school=hongyeon)`은 `birth` 또는 `palja` 중 정확히 하나만 받습니다.
- `saju_palja` 결과의 `palja`를 재사용하면 후속 툴에서 재계산을 줄일 수 있습니다.
- `calendar_month.compact`와 `saju_full_reading.include`로 대형 응답을 줄일 수 있습니다.
- `longitude`는 `trueSolarTime=true`일 때만 지정합니다. 생략 시 엔진 기본값을 사용합니다.

## Development Plan

구현 범위와 P5 품질 게이트는 [`dev-plan/implement_20260709_112451.md`](dev-plan/implement_20260709_112451.md)에 고정되어 있습니다.
운영 배포 전 로컬 검증 가능한 보완 계획은 [`dev-plan/implement_20260709_232143.md`](dev-plan/implement_20260709_232143.md)에 정리되어 있습니다.

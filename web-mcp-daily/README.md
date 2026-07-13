# MCP 운세 브리핑

`web-mcp-daily`는 `manseryeok-mcp` 서버의 `/mcp` endpoint만 호출해 운세 브리핑을 만드는 별도 웹 앱입니다. `web-lucky`처럼 `manseryeok-engine`을 직접 import하지 않고, MCP 서버가 제공하는 tool surface를 실제 제품 화면에서 검증하는 목적입니다.

## 목적

- MCP JSON-RPC 흐름으로 `initialize`, `notifications/initialized`, `tools/call`을 수행합니다.
- `오늘 운세 브리핑`, `주간 운세`, `월간 운세`, `토정비결 연간 운세`, `대운/세운 깊이 분석`을 한 화면에서 검증합니다.
- MCP 서버가 꺼져 있으면 local fallback 없이 오류를 보여줍니다.
- 결과 화면에 호출 tool, HTTP status, 응답 크기, `structuredContent` 파싱 여부를 표시합니다.
- token은 localStorage/sessionStorage에 저장하지 않고 현재 화면의 runtime state에서만 사용합니다.

## 메뉴와 사용 Tool

| 메뉴 | MCP tool chain | 응답 정책 |
| --- | --- | --- |
| 오늘 운세 브리핑 | `calendar_day_info`, `saju_palja`, `saju_full_reading` | 기본 `sipsin + sinsal + relations`, compact `sipsin` |
| 주간 운세 | `calendar_day_info` 7회, `saju_palja`, `saju_full_reading` | 주간은 `sipsin` 중심 요약 |
| 월간 운세 | `calendar_month`, `saju_palja`, `saju_full_reading` | `calendar_month.compact=true` |
| 토정비결 연간 운세 | `tojeong_yearly` | 12개월 운세와 총운 중심 |
| 대운/세운 깊이 분석 | `saju_daeun`, `saju_full_reading` | balanced/expert 선택 |

## 실행

먼저 MCP HTTP 서버를 실행합니다.

```bash
npm --prefix ../mcp-server run dev:http
```

다른 터미널에서 웹앱을 실행합니다. 로컬 MCP 서버의 기본 CORS 허용 포트와 맞추기 위해 `5173`을 사용합니다.

```bash
npm install
npm run dev:local
```

루트에서 실행할 때는 다음처럼 실행할 수 있습니다.

```bash
npm --prefix web-mcp-daily install
npm --prefix web-mcp-daily run dev:local
```

브라우저에서 `http://127.0.0.1:5173/`을 열고 탭을 선택한 뒤 `선택 메뉴 샘플 실행`을 누르면 해당 메뉴의 MCP tool chain이 실제 호출됩니다.

## 환경 변수

```bash
VITE_MCP_URL=/mcp
VITE_MCP_AUTH_MODE=none
VITE_MCP_AUTH_TOKEN=
MCP_HTTP_TARGET=http://127.0.0.1:3100
```

`VITE_MCP_AUTH_MODE`는 `none`, `x-token`, `bearer`를 지원합니다. 화면의 `연결/인증/응답 정책` 패널에서도 같은 값을 런타임으로 바꿔 볼 수 있습니다. 실제 운영 token은 커밋하지 말고 로컬 환경이나 배포 secret에서만 주입합니다.

## 화면 테스트

- `선택 메뉴 샘플 실행`: 현재 선택한 탭의 샘플 출생 정보로 MCP 브리핑을 생성합니다.
- `연결/인증/응답 정책`: auth mode, token, 오늘 응답 정책, 대운/세운 깊이, 토정 대상 연도를 현재 화면에서만 지정합니다.
- `MCP 검증 정보`: tool 이름, HTTP status, 응답 byte size, `structuredContent` 여부를 표시합니다.
- 실패 분류는 서버 대시보드/PlayMCP preflight와 같은 용어를 사용합니다: `auth`, `cors`, `endpoint`, `protocol`, `size`, `server`, `tool`, `network`, `timeout`.

토큰 서버를 수동으로 확인하려면 MCP 서버와 앱을 같은 proxy target에 맞춰 실행합니다.

```bash
PORT=3101 MCP_AUTH_TOKEN=test-token CORS_ORIGIN=http://127.0.0.1:5173 npm --prefix mcp-server run dev:http
MCP_HTTP_TARGET=http://127.0.0.1:3101 npm --prefix web-mcp-daily run dev:local
```

그 다음 화면의 `연결/인증/응답 정책`에서 `X-MCP-Auth-Token`을 선택하고 `test-token`을 입력해 실행합니다. 잘못된 token을 넣으면 auth 오류가 표시되어야 합니다.

## 검증

```bash
npm run build
npm run guard:mcp-only:self-test
npm run guard:mcp-only
npm run browser:check
```

`guard:mcp-only`는 `src`의 `manseryeok-engine`, `../engine`, `engine/src` 직접 import와 명시적인 local-engine fallback 심볼을 차단합니다. README 같은 문서는 검사하지 않습니다. `guard:mcp-only:self-test`는 허용/차단 fixture를 함께 실행해 guard 자체의 오탐·누락을 확인합니다.

`browser:check`는 MCP 서버와 Vite dev server를 임시로 띄운 뒤 다음을 확인합니다.

- 다섯 메뉴 happy path 생성 성공
- 오늘: `calendar_day_info`, `saju_palja`, `saju_full_reading` 표시
- 주간: 7일 흐름과 `calendar_day_info` 표시
- 월간: `calendar_month`와 compact 월간 요약 표시
- 토정비결: `tojeong_yearly`와 12개월 운세 표시
- 대운/세운: `saju_daeun`, `saju_full_reading` 표시
- MCP 서버 OFF 상태에서 다섯 메뉴 모두 오류 UI 표시
- 화면의 auth 패널에서 잘못된 token은 auth 오류
- 화면의 auth 패널에서 정상 `X-MCP-Auth-Token`은 브리핑 생성 성공
- compact 응답 정책에서 `include: ["sipsin"]` 표시

루트에서 전체 검증할 때는 다음 명령을 권장합니다.

```bash
npm --prefix mcp-server test
npm --prefix web-mcp-daily run build
npm --prefix web-mcp-daily run guard:mcp-only
npm --prefix web-mcp-daily run browser:check
npm --prefix web-mcp-daily audit --omit=dev
rg "localStorage|sessionStorage" web-mcp-daily/src
```

마지막 `rg` 명령은 매칭이 없어야 정상입니다.

두 웹 빌드의 raw/gzip total 및 largest asset budget은 루트 size report로 확인합니다. CI 기준은 `web-lucky`가 total raw `512KiB`, total gzip `128KiB`, largest raw `256KiB`, largest gzip `64KiB`이고, `web-mcp-daily`가 각각 `64KiB`, `24KiB`, `56KiB`, `20KiB`입니다. 어느 항목이든 초과하면 실패합니다.

```bash
npm --prefix web-lucky run build
npm --prefix web-mcp-daily run build
node scripts/web-demo-size-report.mjs --fail-on-budget \
  --budget web-lucky.totalRawBytes=512KiB \
  --budget web-lucky.totalGzipBytes=128KiB \
  --budget web-lucky.largestRawBytes=256KiB \
  --budget web-lucky.largestGzipBytes=64KiB \
  --budget web-mcp-daily.totalRawBytes=64KiB \
  --budget web-mcp-daily.totalGzipBytes=24KiB \
  --budget web-mcp-daily.largestRawBytes=56KiB \
  --budget web-mcp-daily.largestGzipBytes=20KiB
```

기준선 기록/비교는 각각 `--write-baseline <json>`, `--baseline <json>`을 사용합니다. budget은 같은 `--budget` 옵션이나 `WEB_SIZE_<TARGET>_*_BYTES` 환경 변수로 관리하며, 환경 변수의 target 이름에서는 하이픈을 밑줄로 바꿉니다(`WEB_SIZE_WEB_LUCKY_*`, `WEB_SIZE_WEB_MCP_DAILY_*`).

## Troubleshooting

### `/mcp`가 403 CORS 오류를 반환하는 경우

MCP 서버 기본 CORS allowlist는 `http://127.0.0.1:5173`과 `http://localhost:5173`입니다. 웹앱을 `5200` 같은 다른 포트로 띄우면 `/mcp` 호출이 `CORS origin denied`로 실패할 수 있습니다.

해결 방법은 둘 중 하나입니다.

```bash
npm --prefix web-mcp-daily run dev:local
```

또는 MCP 서버 CORS를 현재 앱 포트에 맞춥니다.

```bash
CORS_ORIGIN=http://127.0.0.1:5200 npm --prefix mcp-server run dev:http
```

## 문서

- [MCP 브리핑 구현 계획](../dev-plan/implement_20260710_144214.md)
- [웹앱·MCP 통합 검증 계획](../dev-plan/implement_20260713_103828.md)
- [프로젝트 종료 문서 정합성 계획](../dev-plan/implement_20260713_154958.md)

## web-lucky와의 차이

`web-lucky`는 `manseryeok-engine`을 직접 사용해 여러 경량 도구를 제공하는 허브입니다. `web-mcp-daily`는 MCP 서버 실전 사용 검증을 위해 만든 별도 앱이며, 계산은 반드시 MCP tool 응답을 통해서만 수행합니다.

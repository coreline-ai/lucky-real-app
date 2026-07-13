# web-lucky

`lucky-real-app` 모노레포의 **경량 웹 도구 허브**입니다.
홈에서 모드를 고르면 만세력 엔진으로 바로 계산합니다 (서버 저장 없음).

## 5모드

| mode | 이름 | 엔진 |
|---|---|---|
| `iljin` | 오늘의 일진 | `getCalendarDayAsync` + 연도 shard |
| `chemi` | 우리 케미 | `calculateCompatibilityAsync` + 연도 shard |
| `naming` | 이름 후보 체커 | `Naming.analyzeNames` |
| `solar-terms` | 절기 타임라인 | `listSolarTermsForYearAsync` + 연도 shard |
| `tojeong` | 토정 한 해 요약 | `analyzeTojeong` + `solarToLunarAsync` 연도 shard |

딥링크 예: `http://127.0.0.1:5173/?mode=tojeong`

## 요구 사항

- Node.js 18+
- 모노레포 `engine/` (`file:../engine` + Vite alias → `../engine/src`)

## 설치 · 실행

```bash
cd web-lucky
npm install
npm run dev
```

| 명령 | 설명 |
|---|---|
| `npm run dev` | 개발 서버 |
| `npm run build` | 타입체크 + 프로덕션 빌드 |
| `npm run data:generate` | 엔진 정본 JSON에서 public 연도 shard 재생성 |
| `npm run preview` | 빌드 미리보기 |
| `npm test` | 도메인 단위 테스트 (실엔진) |
| `npm run browser:perf` | 토정·케미·이름 계산 지연과 Long Task 측정 |

## 브라우저 스모크

프로덕션 빌드 미리보기를 띄운 뒤 Playwright 스모크를 실행합니다.

```bash
npm run build
npm run preview -- --host 127.0.0.1 --port 4173
```

다른 터미널에서:

```bash
node scripts/browser-hub-check.mjs
node scripts/browser-check.mjs
```

- `browser-hub-check.mjs`: 루트 허브에서 5개 모드 진입과 공통 고지를 확인합니다.
- `browser-check.mjs`: 토정·절기 딥링크의 결과, 요청 shard URL, 비대형 chunk, 빠른 연도 변경의 stale-result 방지를 확인합니다.

## 브라우저 데이터 shard PoC

`predev`, `prebuild`, `pretest`는 엔진의 deterministic generator를 호출해
`public/manseryeok-data/`를 재생성합니다. 이 디렉터리는 생성 산출물이므로 Git에서
제외하며, 정본은 `engine/src/engine/core/data/*.generated.json`입니다.

- 토정의 양력 생일 변환은 해당 양력 연도의 `lunar-solar/<year>.json`만 요청합니다.
- 절기 타임라인은 선택한 `solar-terms/<year>.json`만 요청합니다.
- manifest와 각 연도 shard는 엔진 client의 memory cache에서 요청 중복까지 공유합니다.
- 로딩 중 홈 이동이나 빠른 절기 연도 변경은 요청 sequence를 비교해 오래된 결과를 버립니다.
- 윤달, 1월의 음력 전년도 전환, 지원 범위 밖 연도, sync API parity, memory cache를 단위 테스트합니다.

2026-07-13 브라우저 검증에서 토정 직접 진입은 `manifest.json`과
`lunar-solar/1990.json`, 절기 직접 진입은 `manifest.json`과
`solar-terms/2026.json`만 요청했습니다. 두 직접 진입 경로 모두
`manseryeok-engine-*.js` 대형 chunk를 요청하지 않습니다.

## 보안 · 번들 기준

릴리즈 전 dependency gate는 production dependency 기준으로 확인합니다.

```bash
npm audit --omit=dev
```

전체 `npm audit`에서 Vite/esbuild 개발 서버 계열 devDependency 경고가 나올 수 있습니다. 공개 런타임 번들에는 포함되지 않지만, 개발 서버를 외부망에 노출하지 않습니다. Vite major upgrade는 별도 유지보수 브랜치에서 `npm test`, `npm run typecheck`, `npm run build`, 브라우저 스모크를 모두 통과시킨 뒤 적용합니다.

초기 로딩 비용을 낮추기 위해 허브에서 각 모드 화면은 동적 import로 로드합니다.
대형 변환 데이터는 `public/manseryeok-data/`의 연도별 JSON shard로 분리되어 JS
asset에 포함되지 않습니다. 2026-07-13 빌드 기준 JS/CSS asset 총량은 385.2KB(raw),
87.9KB(gzip)이고, 최대 chunk는 `tojeong-*.js` 171.4KB(raw), 43.9KB(gzip)입니다.

### Worker/PWA 결정

2026-07-13 headless Chromium의 warm-preview 측정 결과는 토정 152.7ms, 케미
76.3ms, 이름 39.8ms였고, 50ms 이상 Long Task는 0건이었습니다. 현재 수치로는
계산용 Web Worker가 복잡도 대비 이득이 없으므로 구현하지 않았습니다. PWA/service
worker도 오프라인 설치 요구가 확정되지 않아 이번 PoC 범위에서는 추가하지 않았습니다.
연도 shard는 memory cache까지만 사용하며, 네트워크 재방문 캐시는 표준 HTTP cache에
맡깁니다.

## 시연 입력

| 모드 | 입력 | 기대 |
|---|---|---|
| home | — | 카드 5개 |
| iljin | (기본 오늘) 또는 2026-07-09 | 일진·음력·길흉 |
| chemi | 1990-03-15 / 1992-08-20 (기본값) | 점수·등급·조언 |
| naming | 김 + 민준, 서연 | 점수 표 2행 |
| solar-terms | 올해 | 절기 목록·다음 절기 |
| tojeong | 1990-03-15 · 2026 | 제N괘 + 월 12칸 |

공통 고지: 오락·자기성찰용 (의료·투자·법률·재무 판단 아님).

## 문서

| 문서 | 설명 |
|---|---|
| [dev-plan/implement_20260709_222644.md](dev-plan/implement_20260709_222644.md) | 토정 단일 앱 MVP |
| [dev-plan/implement_20260709_224721.md](dev-plan/implement_20260709_224721.md) | 허브 + 5모드 통합 |
| [../dev-plan/implement_20260713_103828.md](../dev-plan/implement_20260713_103828.md) | 엔진 sharding과 MCP 교차검증 구현 |
| [../dev-plan/implement_20260713_154958.md](../dev-plan/implement_20260713_154958.md) | 프로젝트 종료 문서 정합성 검증 |

## 관련 패키지

- [`../engine/`](../engine/) — 정본 엔진
- [`../mcp-server/`](../mcp-server/) — 동일 계산 MCP 툴 (웹 런타임 미사용)
- [`../realapp/`](../realapp/), [`../game/`](../game/) — 별도 제품

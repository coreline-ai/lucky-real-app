# web-lucky

`lucky-real-app` 모노레포의 **경량 웹 도구 허브**입니다.
홈에서 모드를 고르면 만세력 엔진으로 바로 계산합니다 (서버 저장 없음).

## 5모드

| mode | 이름 | 엔진 |
|---|---|---|
| `iljin` | 오늘의 일진 | `Calendar.getCalendarDay` |
| `chemi` | 우리 케미 | `Compatibility.calculateCompatibility` |
| `naming` | 이름 후보 체커 | `Naming.analyzeNames` |
| `solar-terms` | 절기 타임라인 | `listSolarTermsForYear` |
| `tojeong` | 토정 한 해 요약 | `Tojeong.analyzeTojeong` + `solarToLunar` |

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
| `npm run preview` | 빌드 미리보기 |
| `npm test` | 도메인 단위 테스트 (실엔진) |

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

## 관련 패키지

- [`../engine/`](../engine/) — 정본 엔진
- [`../mcp-server/`](../mcp-server/) — 동일 계산 MCP 툴 (웹 런타임 미사용)
- [`../realapp/`](../realapp/), [`../game/`](../game/) — 별도 제품

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

## Tool Catalog

| Group | Tool | Key Input | Output |
|---|---|---|---|
| Calendar | `calendar_day_info` | solar `year/month/day` | 일진, 음력, 오행, 12신살, 길흉, 택일, 절기 |
| Calendar | `calendar_month` | solar `year/month`, `compact?` | 월간지, 일별 일진 배열 |
| Calendar | `date_convert` | `solar_to_lunar` 또는 `lunar_to_solar` | 변환 날짜 |
| Calendar | `solar_terms` | `year` 또는 `year/month/day` | 24절기와 KST 입절 시각 |
| Calendar | `korean_legal_time` | 날짜+시각 | 한국 법정시, DST, 모호/부재 시각 |
| Saju | `saju_full_reading` | `birth`, `subSchool?`, `include?` | 팔자, 십신, 지장간, 운성, 운, 신살, 격국, 용신 |
| Saju | `saju_palja` | `birth` | 경량 팔자 |
| Saju | `saju_daeun` | `birth`, `count?` | 대운 목록 |
| Compatibility | `compatibility_score` | `person1`, `person2` | 총점, 등급, 카테고리, 조언, 양쪽 팔자 |
| Tojeong | `tojeong_yearly` | `birth`, `targetYear` | 144괘, 총운, 월별 12운 |
| Charts | `ziwei_chart` | `birth`, `school?`, `interpret?` | 자미두수 12궁 명반 |
| Charts | `qimen_chart` | 날짜+시각, `school?`, `birth` 또는 `palja` | 기문둔갑 포국과 선택 학파 분석 |
| Charts | `daeyukim_chart` | 날짜+시각, `interpret?` | 대육임 과식 |
| Charts | `guseong_chart` | `birthYear`, `gender`, `target?` | 구성기학 본명성, 연월일반 |
| Numeric | `harak_reading` | 생년월일 | 하락이수 괘와 해석 |
| Numeric | `daejeong_reading` | `birth` 또는 `palja` | 대정수 64괘 |
| Numeric | `hongyeon_reading` | `birth` 또는 `palja` | 홍연 본명성, 구궁 배치 |
| Numeric | `maehwa_divination` | `time`, `number`, `name` 방식 | 매화역수 본괘, 변괘, 해석 |
| Naming | `naming_analyze` | 성, 후보 이름, 한자, 학파 | 성명학 점수, 수리, 발음/자원 오행 |
| Naming | `ganji_info` | 간지 한자 문자열 | 독음, 오행, unknown 분류 |

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

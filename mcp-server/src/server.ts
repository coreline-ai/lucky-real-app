// MCP 서버 조립점: McpServer 생성 + instructions + 툴/리소스/프롬프트 그룹 등록.
// P1+에서 tools/*.ts 의 register<Group>Tools(server) 호출이 여기에 추가된다.
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';

import { ENGINE_META, SERVER_NAME, SERVER_VERSION } from './meta.js';
import { registerPrompts } from './prompts/index.js';
import { registerResources } from './resources/index.js';
import { registerCalendarTools } from './tools/calendar.js';
import { registerChartTools } from './tools/charts.js';
import { registerCompatibilityTools } from './tools/compatibility.js';
import { registerNamingTools } from './tools/naming.js';
import { registerNumericTools } from './tools/numeric.js';
import { registerSajuTools } from './tools/saju.js';
import { registerTojeongTools } from './tools/tojeong.js';

// 안전 고지 + 사용 가이드 확정본 (P4)
const INSTRUCTIONS = `한국 만세력(萬歲曆)·명리 계산 MCP 서버입니다. manseryeok-engine(v${ENGINE_META.engineVersion}, 규칙 ${ENGINE_META.ruleVersion})의 결정론적 계산 결과를 20개 툴로 제공합니다: 달력·일진(5), 사주(3), 궁합(1), 토정비결(1), 자미두수·기문둔갑·대육임·구성기학(4), 하락이수·대정수·홍연·매화역수(4), 작명·간지정보(2).

[안전 원칙]
- 목적: 오락·자기성찰용 콘텐츠 계산. 의료·투자·법률·재무 판단의 근거로 사용할 수 없으며, 단정적 예언·공포 조장 표현을 피하세요.
- 이 서버는 계산값과 근거 데이터만 반환합니다. 사용자에게 보여줄 해석 문구의 작성과 어조는 호출 측(클라이언트) 책임입니다.

[입력 규약]
- 모든 날짜·시각은 KST(Asia/Seoul) 기준입니다.
- 지원 범위: 달력/변환 1899-01-01~2101-12-31, 팔자 기반 계산 1908-04-01~2101-12-31(한국 법정시 정책).
- 출생시 미상은 hour/minute을 null로 — 시주가 생략되며 팔자의 hourGan/hourJi는 빈 문자열('')로 표현됩니다. 자미두수·기문둔갑·대육임은 시각이 필수입니다.
- 1948~1960·1987~1988년 서머타임 구간의 모호(AMBIGUOUS_CIVIL_TIME)/부재(NONEXISTENT_CIVIL_TIME) 시각 오류를 받으면 details의 전환 구간을 참고해 사용자에게 시각을 재확인하세요.

[효율 팁]
- saju_palja로 얻은 팔자는 daejeong_reading·hongyeon_reading·qimen_chart(hongyeon)의 palja 입력으로 재사용할 수 있습니다(재계산 불필요).
- 대형 응답은 calendar_month의 compact, saju_full_reading의 include로 줄일 수 있습니다.
- 서버 메타(지원 범위·학파 목록·오류 코드)는 리소스 manseryeok://meta, 계산 정책 문서는 manseryeok://docs/*에서 읽을 수 있습니다. daily-briefing / couple-reading / naming-consult 프롬프트가 툴 체인 사용법을 안내합니다.`;

export function createServer(): McpServer {
  const server = new McpServer(
    { name: SERVER_NAME, version: SERVER_VERSION },
    { instructions: INSTRUCTIONS },
  );

  registerCalendarTools(server);
  registerSajuTools(server);
  registerCompatibilityTools(server);
  registerTojeongTools(server);
  registerChartTools(server);
  registerNumericTools(server);
  registerNamingTools(server);
  registerResources(server);
  registerPrompts(server);

  return server;
}

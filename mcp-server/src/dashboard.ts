import { buildDashboardClient } from './dashboard/client.js';
import { TOOL_SMOKE_FIXTURES } from './dashboard/fixtures.js';
import { DASHBOARD_CSS } from './dashboard/styles.js';
export type { ToolSmokeFixture } from './dashboard/fixtures.js';
export { TOOL_SMOKE_FIXTURES } from './dashboard/fixtures.js';
export { formatResultSummary, formatRawDebug, clipText } from './dashboard/summary.js';

const fixturesJson = JSON.stringify(TOOL_SMOKE_FIXTURES, null, 2);

const GROUP_FILTERS = [
  'All',
  'Calendar',
  'Saju',
  'Compatibility',
  'Tojeong',
  'Charts',
  'Numeric',
  'Naming',
] as const;

function groupFilterChips(): string {
  return GROUP_FILTERS.map((g, i) => {
    const active = i === 0 ? ' active' : '';
    return `<button type="button" class="filter-chip${active}" data-group="${g}">${g}</button>`;
  }).join('');
}

export const TOOL_DASHBOARD_HTML = `<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>manseryeok-mcp Tool Dashboard</title>
  <style>
${DASHBOARD_CSS}
  </style>
</head>
<body class="view-cards">
  <main>
    <div class="sticky-top">
      <header>
        <div>
          <h1>manseryeok-mcp Tool Dashboard</h1>
          <p class="subtitle">툴 상태 점검 (로컬) — <strong>tools/list</strong>와 fixture 기반 <strong>tools/call</strong> smoke를 브라우저에서 확인합니다.</p>
        </div>
        <div class="toolbar">
          <button type="button" id="refreshBtn" class="secondary">목록 새로고침</button>
          <button type="button" id="runAllBtn" class="primary">전체 툴 테스트</button>
        </div>
      </header>

      <section class="cards" aria-label="KPI">
        <div class="card"><div class="label">Server</div><div id="serverValue" class="value">-</div></div>
        <div class="card"><div class="label">Tools</div><div id="toolsValue" class="value">-</div></div>
        <div class="card" id="passedCard"><div class="label">Passed</div><div id="passedValue" class="value">0</div></div>
        <div class="card" id="failedCard"><div class="label">Failed</div><div id="failedValue" class="value">0</div></div>
      </section>

      <div class="statusbar">
        <span class="pill"><span id="healthDot" class="dot"></span><span id="healthText">health 대기</span></span>
        <span class="pill"><span id="listDot" class="dot"></span><span id="listText">tools/list 대기</span></span>
        <span class="pill">MCP path: <code>/mcp</code></span>
        <span class="pill">Dashboard: <code>/dashboard</code></span>
        <span class="pill" id="lastRunText">Last run: —</span>
      </div>

      <div class="progress-wrap" id="progressWrap">
        <div class="progress-meta">
          <span>Run progress</span>
          <span id="progressText">0 / 0</span>
        </div>
        <div class="progress-bar" id="progressBar"><i id="progressBarFill"></i></div>
      </div>

      <div class="filterbar" id="filterBar">
        ${groupFilterChips()}
        <button type="button" class="filter-chip fail-chip" id="failedOnlyChip">Failed only</button>
        <input type="search" id="searchInput" placeholder="툴 이름 검색…" aria-label="Search tools" />
        <div class="view-toggle">
          <button type="button" class="filter-chip active" id="viewCardsBtn">Cards</button>
          <button type="button" class="filter-chip" id="viewTableBtn">Table</button>
        </div>
      </div>
    </div>

    <div id="toolGridWrap" class="tool-grid-wrap">
      <div class="empty">Loading…</div>
    </div>

    <section class="tableWrap">
      <table>
        <thead>
          <tr>
            <th>#</th><th>Group</th><th>Tool</th><th>Smoke Input</th><th>Status</th><th>Action</th>
          </tr>
        </thead>
        <tbody id="toolRows"><tr><td colspan="6" class="small">Loading…</td></tr></tbody>
      </table>
    </section>

    <footer>
      각 툴은 고정 fixture로 호출됩니다. 성공 기준은 HTTP 200 + JSON-RPC result +
      <code>isError !== true</code> + <code>structuredContent</code> 존재입니다.
      설명·payload·응답 JSON은 기본 접힘이며, 한 줄 요약이 먼저 표시됩니다.
      대시보드는 로컬 점검용이며 출생정보 fixture는 서버에 저장하지 않습니다.
    </footer>
  </main>
  <script>
${buildDashboardClient(fixturesJson)}
  </script>
</body>
</html>
`;

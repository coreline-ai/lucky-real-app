/**
 * Browser client for tool dashboard (string-exported into HTML).
 * DOM markers: filter-chip, progress-bar, one-line-summary, view-cards, kpi-fail
 */
export function buildDashboardClient(fixturesJson: string): string {
  return `
(function () {
  const TOOL_SMOKE_FIXTURES = ${fixturesJson};
  const MCP_HEADERS = {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/event-stream',
    'MCP-Protocol-Version': '2025-11-25',
  };
  let nextId = 1;
  let tools = [];
  const state = new Map();
  let filterGroup = 'All';
  let failedOnly = false;
  let searchQuery = '';
  let viewMode = 'cards'; // cards | table
  let runProgress = { done: 0, total: 0, visible: false };

  const el = (id) => document.getElementById(id);

  function clip(text, n) {
    const s = String(text || '');
    return s.length > n ? s.slice(0, n - 1) + '…' : s;
  }

  function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, (char) =>
      ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char],
    );
  }

  function formatResultSummary(result, ms) {
    const timing = ms != null ? ' · ' + ms + 'ms' : '';
    if (result.isError) {
      const text = result.content && result.content[0] && result.content[0].text
        ? result.content[0].text : 'MCP error';
      return 'FAIL' + timing + ' · ' + clip(text, 120);
    }
    if (!result.structuredContent) {
      return 'FAIL' + timing + ' · structuredContent missing';
    }
    const firstText = result.content && result.content[0] && result.content[0].text
      ? String(result.content[0].text).trim() : '';
    if (firstText) return 'OK' + timing + ' · ' + clip(firstText, 140);
    const keys = Object.keys(result.structuredContent).filter((k) => k !== 'meta');
    return 'OK' + timing + ' · keys: ' + (keys.slice(0, 6).join(', ') || '(meta only)');
  }

  function formatRawDebug(result) {
    const structured = result.structuredContent || {};
    const keys = Object.keys(structured).filter((key) => key !== 'meta');
    const meta = structured.meta || {};
    const firstText = result.content && result.content[0] && result.content[0].text
      ? result.content[0].text : '';
    return JSON.stringify({ keys, meta, text: clip(firstText, 180) }, null, 2);
  }

  async function rpc(method, params, protocolHeader) {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/event-stream',
    };
    if (protocolHeader !== false) headers['MCP-Protocol-Version'] = '2025-11-25';
    const response = await fetch('/mcp', {
      method: 'POST',
      headers,
      body: JSON.stringify({ jsonrpc: '2.0', id: nextId++, method, params }),
    });
    const body = await response.json();
    if (!response.ok) throw new Error('HTTP ' + response.status + ': ' + JSON.stringify(body.error || body));
    if (body.error) throw new Error('JSON-RPC ' + body.error.code + ': ' + body.error.message);
    return body.result;
  }

  async function notify(method, params) {
    await fetch('/mcp', {
      method: 'POST',
      headers: MCP_HEADERS,
      body: JSON.stringify({ jsonrpc: '2.0', method, params: params || {} }),
    });
  }

  async function refreshHealth() {
    const dot = el('healthDot');
    try {
      const response = await fetch('/health');
      const data = await response.json();
      dot.className = 'dot ok';
      el('healthText').textContent = 'health OK · ' + data.name + '@' + data.version + ' · ' + data.ruleVersion;
      el('serverValue').textContent = data.mode || 'OK';
    } catch (error) {
      dot.className = 'dot fail';
      el('healthText').textContent = 'health FAIL · ' + error.message;
      el('serverValue').textContent = 'FAIL';
    }
  }

  async function refreshTools() {
    const dot = el('listDot');
    try {
      await rpc('initialize', {
        protocolVersion: '2025-11-25',
        capabilities: {},
        clientInfo: { name: 'mcp-dashboard', version: '0.1.0' },
      }, false);
      await notify('notifications/initialized');
      const result = await rpc('tools/list', {});
      tools = result.tools || [];
      dot.className = 'dot ok';
      el('listText').textContent = 'tools/list OK · ' + tools.length + ' tools';
      el('toolsValue').textContent = String(tools.length);
      renderAll();
    } catch (error) {
      tools = [];
      dot.className = 'dot fail';
      el('listText').textContent = 'tools/list FAIL · ' + error.message;
      el('toolsValue').textContent = '—';
      const grid = el('toolGridWrap');
      const tbody = el('toolRows');
      const msg = '툴 목록을 불러오지 못했습니다. HTTP 서버가 실행 중인지 확인하세요. (' + error.message + ')';
      if (grid) grid.innerHTML = '<div class="empty">' + escapeHtml(msg) + '</div>';
      if (tbody) tbody.innerHTML = '<tr><td colspan="6" class="empty">' + escapeHtml(msg) + '</td></tr>';
    }
  }

  function toolStatus(name) {
    return state.get(name) || { status: 'idle', message: '대기', ms: null, summary: '', raw: '', openFail: false };
  }

  function statusClass(status) {
    if (status === 'ok') return 'okText';
    if (status === 'fail') return 'failText';
    if (status === 'running') return 'runText';
    return 'idleText';
  }

  function filteredTools() {
    return tools.filter((tool) => {
      const fixture = TOOL_SMOKE_FIXTURES[tool.name];
      const group = fixture ? fixture.group : 'Unknown';
      if (filterGroup !== 'All' && group !== filterGroup) return false;
      if (failedOnly && toolStatus(tool.name).status !== 'fail') return false;
      if (searchQuery) {
        const q = searchQuery.toLowerCase();
        if (!tool.name.toLowerCase().includes(q) && !(tool.description || '').toLowerCase().includes(q)) {
          return false;
        }
      }
      return true;
    });
  }

  function groupsInOrder(list) {
    const order = ['Calendar', 'Saju', 'Compatibility', 'Tojeong', 'Charts', 'Numeric', 'Naming', 'Unknown'];
    const map = new Map();
    for (const tool of list) {
      const fixture = TOOL_SMOKE_FIXTURES[tool.name];
      const g = fixture ? fixture.group : 'Unknown';
      if (!map.has(g)) map.set(g, []);
      map.get(g).push(tool);
    }
    const keys = [...map.keys()].sort((a, b) => order.indexOf(a) - order.indexOf(b));
    return keys.map((g) => ({ group: g, tools: map.get(g) }));
  }

  function renderProgress() {
    const wrap = el('progressWrap');
    if (!runProgress.visible) {
      wrap.classList.remove('visible');
      return;
    }
    wrap.classList.add('visible');
    el('progressText').textContent = runProgress.done + ' / ' + runProgress.total;
    const pct = runProgress.total ? Math.round((runProgress.done / runProgress.total) * 100) : 0;
    el('progressBarFill').style.width = pct + '%';
  }

  function updateCounters() {
    let passed = 0;
    let failed = 0;
    for (const value of state.values()) {
      if (value.status === 'ok') passed += 1;
      if (value.status === 'fail') failed += 1;
    }
    el('passedValue').textContent = String(passed);
    el('failedValue').textContent = String(failed);
    const passCard = el('passedCard');
    const failCard = el('failedCard');
    passCard.className = 'card' + (passed > 0 ? ' kpi-ok' : '');
    failCard.className = 'card' + (failed > 0 ? ' kpi-fail' : '');
  }

  function toolCardHtml(tool) {
    const fixture = TOOL_SMOKE_FIXTURES[tool.name];
    const current = toolStatus(tool.name);
    const st = statusClass(current.status);
    const openAttr = current.status === 'fail' ? ' open' : '';
    return (
      '<article class="tool-card status-' + current.status + '" data-tool-card="' + tool.name + '">' +
        '<div class="top">' +
          '<div class="toolName">' + escapeHtml(tool.name) + '</div>' +
          '<div class="badge-status ' + st + '">' + current.status.toUpperCase() +
            (current.ms != null ? ' · ' + current.ms + 'ms' : '') + '</div>' +
        '</div>' +
        '<div class="one-line-summary" data-summary="' + tool.name + '">' +
          escapeHtml(current.summary || current.message || '—') +
        '</div>' +
        '<div class="fixture-label">' + escapeHtml(fixture ? fixture.label : 'fixture 없음') + '</div>' +
        '<div class="desc-clamp">' + escapeHtml(clip(tool.description || '', 160)) + '</div>' +
        '<details class="fold"><summary>설명 전체</summary><div class="small">' +
          escapeHtml(tool.description || '') + '</div></details>' +
        '<details class="fold"><summary>payload</summary><pre class="block">' +
          escapeHtml(JSON.stringify(fixture ? fixture.args : {}, null, 2)) + '</pre></details>' +
        '<details class="fold"' + openAttr + '><summary>응답 디버그</summary><pre class="block">' +
          escapeHtml(current.raw || '') + '</pre></details>' +
        '<div class="card-actions">' +
          '<button class="secondary" data-tool="' + tool.name + '" ' +
            (!fixture || current.status === 'running' ? 'disabled' : '') + '>Run</button>' +
          (current.summary
            ? '<button class="secondary" data-copy="' + tool.name + '">Copy summary</button>'
            : '') +
        '</div>' +
      '</article>'
    );
  }

  function toolRowHtml(tool, index) {
    const fixture = TOOL_SMOKE_FIXTURES[tool.name];
    const current = toolStatus(tool.name);
    const st = statusClass(current.status);
    const openAttr = current.status === 'fail' ? ' open' : '';
    return (
      '<tr class="row-status-' + current.status + '">' +
        '<td>' + String(index + 1).padStart(2, '0') + '</td>' +
        '<td><span class="pill">' + escapeHtml(fixture ? fixture.group : 'Unknown') + '</span></td>' +
        '<td><div class="toolName">' + escapeHtml(tool.name) + '</div>' +
          '<details class="fold"><summary>설명</summary><div class="desc-clamp" style="-webkit-line-clamp:unset">' +
          escapeHtml(tool.description || '') + '</div></details></td>' +
        '<td><div class="fixture-label">' + escapeHtml(fixture ? fixture.label : 'fixture 없음') + '</div>' +
          '<details class="fold"><summary>payload</summary><pre class="block">' +
          escapeHtml(JSON.stringify(fixture ? fixture.args : {}, null, 2)) + '</pre></details></td>' +
        '<td><div class="badge-status ' + st + '">' + current.status.toUpperCase() +
          (current.ms != null ? ' · ' + current.ms + 'ms' : '') + '</div>' +
          '<div class="one-line-summary">' + escapeHtml(current.summary || current.message || '') + '</div>' +
          '<details class="fold"' + openAttr + '><summary>응답 디버그</summary><pre class="block">' +
          escapeHtml(current.raw || '') + '</pre></details></td>' +
        '<td><button class="secondary" data-tool="' + tool.name + '" ' +
          (!fixture || current.status === 'running' ? 'disabled' : '') + '>Run</button></td>' +
      '</tr>'
    );
  }

  function bindActions(root) {
    root.querySelectorAll('button[data-tool]').forEach((button) => {
      button.addEventListener('click', () => runTool(button.dataset.tool));
    });
    root.querySelectorAll('button[data-copy]').forEach((button) => {
      button.addEventListener('click', async () => {
        const name = button.dataset.copy;
        const cur = toolStatus(name);
        try {
          await navigator.clipboard.writeText(cur.summary || cur.message || '');
        } catch (_) { /* ignore */ }
      });
    });
    root.querySelectorAll('button[data-run-group]').forEach((button) => {
      button.addEventListener('click', () => runGroup(button.dataset.runGroup));
    });
  }

  function renderAll() {
    document.body.classList.remove('view-cards', 'view-table');
    document.body.classList.add(viewMode === 'table' ? 'view-table' : 'view-cards');
    if (el('viewCardsBtn')) el('viewCardsBtn').classList.toggle('active', viewMode === 'cards');
    if (el('viewTableBtn')) el('viewTableBtn').classList.toggle('active', viewMode === 'table');

    const list = filteredTools();
    const grid = el('toolGridWrap');
    const tbody = el('toolRows');
    if (!grid || !tbody) return;

    if (!tools.length) {
      grid.innerHTML = '<div class="empty">툴 목록 로딩 중이거나 비어 있습니다. 「목록 새로고침」을 눌러 보세요.</div>';
      tbody.innerHTML = '<tr><td colspan="6" class="empty">No tools loaded</td></tr>';
      updateCounters();
      renderProgress();
      return;
    }

    if (!list.length) {
      grid.innerHTML = '<div class="empty">필터 결과가 없습니다.</div>';
      tbody.innerHTML = '<tr><td colspan="6" class="empty">필터 결과가 없습니다.</td></tr>';
    } else {
      const grouped = groupsInOrder(list);
      grid.innerHTML = grouped.map(({ group, tools: gt }) => {
        return (
          '<section class="group-section" data-group="' + escapeHtml(group) + '">' +
            '<div class="group-head"><h2>' + escapeHtml(group) +
            ' <span class="pill">' + gt.length + '</span></h2>' +
            '<button type="button" class="secondary" data-run-group="' + escapeHtml(group) + '">Run group</button></div>' +
            '<div class="tool-grid">' + gt.map(toolCardHtml).join('') + '</div></section>'
        );
      }).join('');

      let idx = 0;
      tbody.innerHTML = list.map((tool) => toolRowHtml(tool, ++idx)).join('');
    }

    bindActions(grid);
    bindActions(tbody);
    updateCounters();
    renderProgress();
    el('lastRunText').textContent = window.__lastRunAt
      ? 'Last run: ' + window.__lastRunAt
      : 'Last run: —';
  }

  async function runTool(name) {
    const fixture = TOOL_SMOKE_FIXTURES[name];
    if (!fixture) return;
    const started = performance.now();
    state.set(name, { status: 'running', message: 'tools/call 실행 중', ms: null, summary: '실행 중…', raw: '' });
    renderAll();
    try {
      const result = await rpc('tools/call', { name, arguments: fixture.args });
      const ms = Math.round(performance.now() - started);
      if (result.isError) {
        const text = result.content && result.content[0] && result.content[0].text
          ? result.content[0].text : 'unknown MCP error';
        state.set(name, {
          status: 'fail',
          message: text,
          ms,
          summary: formatResultSummary(result, ms),
          raw: formatRawDebug(result),
        });
      } else if (!result.structuredContent) {
        state.set(name, {
          status: 'fail',
          message: 'structuredContent missing',
          ms,
          summary: formatResultSummary(result, ms),
          raw: formatRawDebug(result),
        });
      } else {
        state.set(name, {
          status: 'ok',
          message: 'structuredContent OK',
          ms,
          summary: formatResultSummary(result, ms),
          raw: formatRawDebug(result),
        });
      }
    } catch (error) {
      const ms = Math.round(performance.now() - started);
      state.set(name, {
        status: 'fail',
        message: error.message,
        ms,
        summary: 'FAIL · ' + ms + 'ms · ' + clip(error.message, 120),
        raw: '',
      });
    }
    window.__lastRunAt = new Date().toLocaleTimeString();
    renderAll();
  }

  async function runGroup(group) {
    const names = tools
      .filter((t) => {
        const f = TOOL_SMOKE_FIXTURES[t.name];
        return f && f.group === group;
      })
      .map((t) => t.name);
    runProgress = { done: 0, total: names.length, visible: true };
    renderProgress();
    for (const name of names) {
      await runTool(name);
      runProgress.done += 1;
      renderProgress();
    }
    runProgress.visible = false;
    renderProgress();
  }

  async function runAll() {
    el('runAllBtn').disabled = true;
    const names = tools.filter((t) => TOOL_SMOKE_FIXTURES[t.name]).map((t) => t.name);
    runProgress = { done: 0, total: names.length, visible: true };
    renderProgress();
    for (const name of names) {
      await runTool(name);
      runProgress.done += 1;
      renderProgress();
    }
    runProgress.visible = false;
    renderProgress();
    el('runAllBtn').disabled = false;
  }

  function setFilter(group, isFailedToggle) {
    if (isFailedToggle) {
      failedOnly = !failedOnly;
    } else {
      filterGroup = group;
    }
    document.querySelectorAll('.filter-chip[data-group]').forEach((chip) => {
      chip.classList.toggle('active', chip.dataset.group === filterGroup);
    });
    el('failedOnlyChip').classList.toggle('active', failedOnly);
    renderAll();
  }

  el('refreshBtn').addEventListener('click', async () => {
    await refreshHealth();
    await refreshTools();
  });
  el('runAllBtn').addEventListener('click', runAll);
  el('failedOnlyChip').addEventListener('click', () => setFilter(filterGroup, true));
  document.querySelectorAll('.filter-chip[data-group]').forEach((chip) => {
    chip.addEventListener('click', () => setFilter(chip.dataset.group, false));
  });
  el('searchInput').addEventListener('input', (e) => {
    searchQuery = e.target.value.trim();
    renderAll();
  });
  el('viewCardsBtn').addEventListener('click', () => { viewMode = 'cards'; renderAll(); });
  el('viewTableBtn').addEventListener('click', () => { viewMode = 'table'; renderAll(); });

  refreshHealth().then(refreshTools);
})();
`;
}

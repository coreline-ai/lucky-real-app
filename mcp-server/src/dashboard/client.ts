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
  let authMode = 'none'; // none | x-header | bearer
  let authToken = '';
  let listSizeBytes = null;
  let largestResponse = { name: '-', bytes: 0, status: 'OK' };

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

  function byteLength(value) {
    return new TextEncoder().encode(String(value || '')).length;
  }

  function formatBytes(bytes) {
    if (bytes == null) return '-';
    if (bytes >= 1024 * 1024) return (bytes / 1024 / 1024).toFixed(2) + ' MB';
    if (bytes >= 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return bytes + ' B';
  }

  function sizeStatus(bytes) {
    if (bytes == null) return 'IDLE';
    if (bytes > 100 * 1024) return 'LARGE';
    if (bytes > 32 * 1024) return 'WATCH';
    return 'OK';
  }

  function sizeClass(status) {
    if (status === 'LARGE') return 'size-large';
    if (status === 'WATCH') return 'size-watch';
    if (status === 'OK') return 'size-ok';
    return '';
  }

  function authHeader() {
    const token = authToken.trim();
    if (authMode === 'x-header' && token) return { 'X-MCP-Auth-Token': token };
    if (authMode === 'bearer' && token) return { Authorization: 'Bearer ' + token };
    return {};
  }

  function mcpHeaders(protocolHeader) {
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/event-stream',
    };
    if (protocolHeader !== false) headers['MCP-Protocol-Version'] = '2025-11-25';
    return Object.assign(headers, authHeader());
  }

  function classifyFailure(status, body, text) {
    const message = String((body && body.error && body.error.message) || text || '');
    const code = body && body.error ? body.error.code : undefined;
    if (status === 401 || code === -32001) return 'auth';
    if (status === 403) return 'cors';
    if (status === 404) return 'endpoint';
    if (status === 405) return 'protocol';
    if (status === 413 || message.toLowerCase().includes('too large')) return 'size';
    if (status >= 500 || code === -32603) return 'server';
    if (code === -32602 || code === -32000) return 'protocol';
    if (body && body.error) return 'json-rpc';
    return 'unknown';
  }

  function requestError(message, classification, bytes, details) {
    const error = new Error(message);
    error.classification = classification;
    error.bytes = bytes;
    error.details = details;
    return error;
  }

  function setDot(id, tone) {
    const node = el(id);
    if (!node) return;
    node.className = 'dot' + (tone ? ' ' + tone : '');
  }

  function updateAuthStatus() {
    const modeLabel = authMode === 'x-header' ? 'X-MCP-Auth-Token' : authMode === 'bearer' ? 'Bearer' : 'none';
    const needsToken = authMode !== 'none';
    setDot('authDot', needsToken && !authToken.trim() ? 'run' : 'ok');
    el('authText').textContent = needsToken
      ? 'auth ' + modeLabel + (authToken.trim() ? ' ready' : ' token empty')
      : 'auth none';
  }

  function updateErrorStatus(classification, message, ok) {
    setDot('errorDot', ok ? 'ok' : 'fail');
    el('errorText').textContent = ok
      ? 'error classification OK'
      : 'error ' + classification + ' · ' + clip(message, 70);
  }

  function updateSizeKpis() {
    el('listSizeValue').textContent = listSizeBytes == null ? '-' : formatBytes(listSizeBytes);
    const listStatus = sizeStatus(listSizeBytes);
    el('listSizeValue').className = 'value ' + sizeClass(listStatus);

    const values = [...state.entries()]
      .filter(([, value]) => typeof value.responseBytes === 'number')
      .map(([name, value]) => ({ name, bytes: value.responseBytes, status: sizeStatus(value.responseBytes) }));
    if (listSizeBytes != null) values.push({ name: 'tools/list', bytes: listSizeBytes, status: listStatus });
    largestResponse = values.sort((a, b) => b.bytes - a.bytes)[0] || { name: '-', bytes: 0, status: 'OK' };
    el('largestSizeValue').textContent = largestResponse.name === '-' ? '-' : formatBytes(largestResponse.bytes);
    el('largestSizeValue').className = 'value ' + sizeClass(largestResponse.status);

    const hasLarge = values.some((item) => item.status === 'LARGE');
    const hasWatch = values.some((item) => item.status === 'WATCH');
    setDot('sizeDot', hasLarge ? 'fail' : hasWatch ? 'run' : values.length ? 'ok' : '');
    el('sizeText').textContent = values.length
      ? 'size ' + (hasLarge ? 'LARGE' : hasWatch ? 'WATCH' : 'OK') + ' · largest ' + largestResponse.name + ' ' + formatBytes(largestResponse.bytes)
      : 'size 대기';
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

  function formatRawDebug(result, sizeInfo) {
    const structured = result.structuredContent || {};
    const keys = Object.keys(structured).filter((key) => key !== 'meta');
    const meta = structured.meta || {};
    const firstText = result.content && result.content[0] && result.content[0].text
      ? result.content[0].text : '';
    return JSON.stringify({ keys, meta, size: sizeInfo || null, text: clip(firstText, 180) }, null, 2);
  }

  async function rpc(method, params, protocolHeader) {
    const response = await fetch('/mcp', {
      method: 'POST',
      headers: mcpHeaders(protocolHeader),
      body: JSON.stringify({ jsonrpc: '2.0', id: nextId++, method, params }),
    });
    const text = await response.text();
    const bytes = byteLength(text);
    let body = null;
    try {
      body = text ? JSON.parse(text) : null;
    } catch (_) {
      body = null;
    }
    if (!response.ok) {
      const classification = classifyFailure(response.status, body, text);
      throw requestError('HTTP ' + response.status + ': ' + clip(text || JSON.stringify(body || {}), 180), classification, bytes, body);
    }
    if (body && body.error) {
      const classification = classifyFailure(response.status, body, text);
      throw requestError('JSON-RPC ' + body.error.code + ': ' + body.error.message, classification, bytes, body.error);
    }
    return { result: body ? body.result : undefined, bytes, status: response.status };
  }

  async function notify(method, params) {
    await fetch('/mcp', {
      method: 'POST',
      headers: Object.assign({}, MCP_HEADERS, authHeader()),
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
      const response = await rpc('tools/list', {});
      const result = response.result || {};
      tools = result.tools || [];
      listSizeBytes = response.bytes;
      dot.className = 'dot ok';
      el('listText').textContent = 'tools/list OK · ' + tools.length + ' tools · ' + formatBytes(response.bytes);
      el('toolsValue').textContent = String(tools.length);
      updateErrorStatus('none', 'OK', true);
      renderAll();
    } catch (error) {
      tools = [];
      dot.className = 'dot fail';
      el('listText').textContent = 'tools/list FAIL · ' + error.message;
      el('toolsValue').textContent = '—';
      updateErrorStatus(error.classification || 'unknown', error.message, false);
      const grid = el('toolGridWrap');
      const tbody = el('toolRows');
      const msg = '툴 목록을 불러오지 못했습니다. 분류: ' + (error.classification || 'unknown') + ' (' + error.message + ')';
      if (grid) grid.innerHTML = '<div class="empty">' + escapeHtml(msg) + '</div>';
      if (tbody) tbody.innerHTML = '<tr><td colspan="6" class="empty">' + escapeHtml(msg) + '</td></tr>';
      updateSizeKpis();
    }
  }

  function toolStatus(name) {
    return state.get(name) || {
      status: 'idle',
      message: '대기',
      ms: null,
      summary: '',
      raw: '',
      openFail: false,
      responseBytes: null,
      resultBytes: null,
      structuredBytes: null,
      classification: '',
    };
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
    updateSizeKpis();
  }

  function toolCardHtml(tool) {
    const fixture = TOOL_SMOKE_FIXTURES[tool.name];
    const current = toolStatus(tool.name);
    const st = statusClass(current.status);
    const openAttr = current.status === 'fail' ? ' open' : '';
    const sz = sizeStatus(current.responseBytes);
    const classification = current.classification || (current.status === 'fail' ? 'unknown' : '');
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
        '<div class="metric-row">' +
          '<span class="metric-chip ' + sizeClass(sz) + '">size ' +
            (current.responseBytes == null ? '-' : sz + ' ' + formatBytes(current.responseBytes)) + '</span>' +
          (classification ? '<span class="metric-chip">error ' + escapeHtml(classification) + '</span>' : '') +
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
    const sz = sizeStatus(current.responseBytes);
    const classification = current.classification || (current.status === 'fail' ? 'unknown' : '');
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
          '<div class="metric-row"><span class="metric-chip ' + sizeClass(sz) + '">size ' +
          (current.responseBytes == null ? '-' : sz + ' ' + formatBytes(current.responseBytes)) + '</span>' +
          (classification ? '<span class="metric-chip">error ' + escapeHtml(classification) + '</span>' : '') +
          '</div>' +
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

  function registrationPayload(status, details) {
    el('registrationResult').textContent = JSON.stringify(Object.assign({
      status,
      authMode,
      tokenStored: false,
    }, details), null, 2);
  }

  async function runInfoLoad() {
    const button = el('infoLoadBtn');
    button.disabled = true;
    setDot('infoDot', 'run');
    el('infoText').textContent = '정보 불러오기 실행 중';
    el('registrationResult').textContent = 'initialize → notifications/initialized → tools/list 실행 중...';
    try {
      const initialize = await rpc('initialize', {
        protocolVersion: '2025-11-25',
        capabilities: {},
        clientInfo: { name: 'playmcp-preflight-dashboard', version: '0.1.0' },
      }, false);
      await notify('notifications/initialized');
      const list = await rpc('tools/list', {});
      const listedTools = (list.result && list.result.tools) || [];
      tools = listedTools;
      listSizeBytes = list.bytes;
      el('toolsValue').textContent = String(tools.length);
      el('listText').textContent = 'tools/list OK · ' + tools.length + ' tools · ' + formatBytes(list.bytes);
      setDot('listDot', 'ok');
      setDot('infoDot', 'ok');
      el('infoText').textContent = '정보 불러오기 OK · ' + tools.length + ' tools';
      updateErrorStatus('none', 'OK', true);
      registrationPayload('PASS', {
        server: initialize.result && initialize.result.serverInfo ? initialize.result.serverInfo : null,
        toolsListCount: tools.length,
        toolsListSize: {
          bytes: list.bytes,
          display: formatBytes(list.bytes),
          status: sizeStatus(list.bytes),
        },
        representativeTools: tools.slice(0, 5).map((tool) => tool.name),
      });
      renderAll();
    } catch (error) {
      setDot('infoDot', 'fail');
      el('infoText').textContent = '정보 불러오기 FAIL · ' + (error.classification || 'unknown');
      updateErrorStatus(error.classification || 'unknown', error.message, false);
      registrationPayload('FAIL', {
        classification: error.classification || 'unknown',
        responseBytes: error.bytes || null,
        message: error.message,
      });
      renderAll();
    } finally {
      button.disabled = false;
    }
  }

  async function runBodyLimitProbe() {
    const button = el('bodyLimitBtn');
    button.disabled = true;
    setDot('infoDot', 'run');
    el('infoText').textContent = '413 테스트 실행 중';
    try {
      const body = JSON.stringify({
        jsonrpc: '2.0',
        id: nextId++,
        method: 'tools/list',
        params: { padding: 'x'.repeat(1024 * 1024 + 256) },
      });
      const response = await fetch('/mcp', {
        method: 'POST',
        headers: mcpHeaders(true),
        body,
      });
      const text = await response.text();
      let parsed = null;
      try {
        parsed = text ? JSON.parse(text) : null;
      } catch (_) {
        parsed = null;
      }
      const bytes = byteLength(text);
      const classification = classifyFailure(response.status, parsed, text);
      if (response.status === 413 && classification === 'size') {
        setDot('infoDot', 'ok');
        el('infoText').textContent = '413 테스트 OK · size';
        updateErrorStatus('size', '413 classified as size', true);
        registrationPayload('PASS', {
          probe: 'body-limit',
          httpStatus: response.status,
          classification,
          responseBytes: bytes,
        });
      } else {
        setDot('infoDot', 'fail');
        el('infoText').textContent = '413 테스트 FAIL · ' + classification;
        updateErrorStatus(classification, 'Expected 413 size classification, got HTTP ' + response.status, false);
        registrationPayload('FAIL', {
          probe: 'body-limit',
          httpStatus: response.status,
          classification,
          responseBytes: bytes,
        });
      }
    } catch (error) {
      setDot('infoDot', 'fail');
      el('infoText').textContent = '413 테스트 FAIL · ' + (error.classification || 'unknown');
      updateErrorStatus(error.classification || 'unknown', error.message, false);
      registrationPayload('FAIL', {
        probe: 'body-limit',
        classification: error.classification || 'unknown',
        message: error.message,
      });
    } finally {
      button.disabled = false;
    }
  }

  async function runTool(name) {
    const fixture = TOOL_SMOKE_FIXTURES[name];
    if (!fixture) return;
    const started = performance.now();
    state.set(name, {
      status: 'running',
      message: 'tools/call 실행 중',
      ms: null,
      summary: '실행 중…',
      raw: '',
      responseBytes: null,
      resultBytes: null,
      structuredBytes: null,
      classification: '',
    });
    renderAll();
    try {
      const call = await rpc('tools/call', { name, arguments: fixture.args });
      const result = call.result || {};
      const ms = Math.round(performance.now() - started);
      const resultBytes = byteLength(JSON.stringify(result));
      const structuredBytes = result.structuredContent ? byteLength(JSON.stringify(result.structuredContent)) : 0;
      const sizeInfo = {
        responseBytes: call.bytes,
        resultBytes,
        structuredBytes,
        status: sizeStatus(call.bytes),
      };
      if (result.isError) {
        const text = result.content && result.content[0] && result.content[0].text
          ? result.content[0].text : 'unknown MCP error';
        state.set(name, {
          status: 'fail',
          message: text,
          ms,
          summary: formatResultSummary(result, ms),
          raw: formatRawDebug(result, sizeInfo),
          responseBytes: call.bytes,
          resultBytes,
          structuredBytes,
          classification: 'tool',
        });
      } else if (!result.structuredContent) {
        state.set(name, {
          status: 'fail',
          message: 'structuredContent missing',
          ms,
          summary: formatResultSummary(result, ms),
          raw: formatRawDebug(result, sizeInfo),
          responseBytes: call.bytes,
          resultBytes,
          structuredBytes,
          classification: 'tool',
        });
      } else {
        state.set(name, {
          status: 'ok',
          message: 'structuredContent OK',
          ms,
          summary: formatResultSummary(result, ms),
          raw: formatRawDebug(result, sizeInfo),
          responseBytes: call.bytes,
          resultBytes,
          structuredBytes,
          classification: '',
        });
      }
      updateErrorStatus('none', 'OK', true);
    } catch (error) {
      const ms = Math.round(performance.now() - started);
      state.set(name, {
        status: 'fail',
        message: error.message,
        ms,
        summary: 'FAIL · ' + ms + 'ms · ' + (error.classification || 'unknown') + ' · ' + clip(error.message, 120),
        raw: JSON.stringify({
          classification: error.classification || 'unknown',
          responseBytes: error.bytes || null,
          message: error.message,
        }, null, 2),
        responseBytes: error.bytes || null,
        resultBytes: null,
        structuredBytes: null,
        classification: error.classification || 'unknown',
      });
      updateErrorStatus(error.classification || 'unknown', error.message, false);
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
  el('infoLoadBtn').addEventListener('click', runInfoLoad);
  el('bodyLimitBtn').addEventListener('click', runBodyLimitProbe);
  el('authMode').addEventListener('change', (event) => {
    authMode = event.target.value;
    updateAuthStatus();
  });
  el('authToken').addEventListener('input', (event) => {
    authToken = event.target.value;
    updateAuthStatus();
  });
  el('clearAuthBtn').addEventListener('click', () => {
    authToken = '';
    el('authToken').value = '';
    updateAuthStatus();
  });
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

  updateAuthStatus();
  updateSizeKpis();
  refreshHealth().then(refreshTools);
})();
`;
}

/** Dashboard CSS — markers used by tests: status-bar, kpi-fail, progress-bar, filter-chip, view-cards */
export const DASHBOARD_CSS = `
:root {
  color-scheme: dark;
  --bg: #080b13;
  --panel: #111827;
  --panel2: #0f172a;
  --line: #263244;
  --text: #e5e7eb;
  --muted: #94a3b8;
  --ok: #2dd4bf;
  --fail: #fb7185;
  --run: #fbbf24;
  --idle: #64748b;
  --accent: #60a5fa;
  --accent-soft: rgba(96, 165, 250, 0.15);
}
* { box-sizing: border-box; }
body {
  margin: 0;
  font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", sans-serif;
  background: var(--bg);
  color: var(--text);
  line-height: 1.45;
}
main { width: min(1200px, calc(100% - 28px)); margin: 0 auto; padding: 24px 0 48px; }
.sticky-top {
  position: sticky; top: 0; z-index: 20;
  background: linear-gradient(180deg, rgba(8,11,19,.98) 70%, rgba(8,11,19,.88));
  padding-bottom: 10px; margin-bottom: 8px;
  border-bottom: 1px solid transparent;
}
header { display: flex; flex-wrap: wrap; justify-content: space-between; gap: 14px; align-items: flex-start; }
h1 { margin: 0 0 4px; font-size: clamp(1.4rem, 3vw, 2rem); font-weight: 750; letter-spacing: -0.03em; }
.subtitle { margin: 0; color: var(--muted); font-size: 0.92rem; max-width: 40rem; }
.toolbar { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; }
button {
  border: 0; border-radius: 999px; padding: 9px 14px; font-weight: 700; font-size: 0.9rem;
  color: #06111f; background: var(--accent); cursor: pointer;
}
button.secondary { color: var(--text); background: #1f2937; border: 1px solid var(--line); }
button:disabled { cursor: not-allowed; opacity: 0.55; }
button.primary { background: var(--accent); color: #06111f; }
.cards {
  display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px; margin: 14px 0 10px;
}
.card {
  background: rgba(17,24,39,0.9); border: 1px solid var(--line); border-radius: 14px; padding: 14px 16px;
}
.card .label { color: var(--muted); font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.08em; font-weight: 600; }
.card .value { margin-top: 6px; font-size: 1.35rem; font-weight: 800; }
.card.kpi-ok .value { color: var(--ok); }
.card.kpi-fail .value { color: var(--fail); }
.card.kpi-fail { border-color: rgba(251,113,133,0.45); box-shadow: 0 0 0 1px rgba(251,113,133,0.12); }
.statusbar, .filterbar { display: flex; flex-wrap: wrap; gap: 8px; margin: 8px 0; align-items: center; }
.pill {
  display: inline-flex; align-items: center; gap: 6px; padding: 6px 10px;
  border: 1px solid var(--line); border-radius: 999px; background: rgba(15,23,42,0.85); font-size: 0.82rem; color: var(--muted);
}
.filter-chip {
  border: 1px solid var(--line); background: #1f2937; color: var(--text);
  border-radius: 999px; padding: 6px 12px; font-size: 0.82rem; font-weight: 600; cursor: pointer;
}
.filter-chip.active { background: var(--accent-soft); border-color: var(--accent); color: #dbeafe; }
.filter-chip.fail-chip.active { border-color: var(--fail); color: #fecdd3; background: rgba(251,113,133,0.12); }
#searchInput {
  flex: 1; min-width: 140px; max-width: 220px;
  background: #0f172a; border: 1px solid var(--line); border-radius: 999px;
  color: var(--text); padding: 7px 12px; font-size: 0.85rem;
}
.progress-wrap { margin: 8px 0 12px; display: none; }
.progress-wrap.visible { display: block; }
.progress-meta { display: flex; justify-content: space-between; font-size: 0.82rem; color: var(--muted); margin-bottom: 4px; }
.progress-bar {
  height: 6px; border-radius: 999px; background: #1e293b; overflow: hidden;
}
.progress-bar > i {
  display: block; height: 100%; width: 0%; background: linear-gradient(90deg, var(--accent), var(--ok));
  transition: width 0.2s ease;
}
.view-toggle { margin-left: auto; display: flex; gap: 6px; }
.group-section { margin: 18px 0; }
.group-head {
  display: flex; align-items: center; justify-content: space-between; gap: 10px;
  margin-bottom: 10px; padding-bottom: 6px; border-bottom: 1px solid var(--line);
}
.group-head h2 { margin: 0; font-size: 0.95rem; font-weight: 700; letter-spacing: 0.02em; }
.tool-grid {
  display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 10px;
}
.tool-card {
  position: relative;
  background: rgba(15,23,42,0.88); border: 1px solid var(--line); border-radius: 14px;
  padding: 12px 12px 12px 14px; display: flex; flex-direction: column; gap: 8px;
  border-left: 4px solid var(--idle);
}
.tool-card.status-ok { border-left-color: var(--ok); }
.tool-card.status-fail { border-left-color: var(--fail); }
.tool-card.status-running { border-left-color: var(--run); }
.tool-card:hover { border-color: #334155; }
.tool-card .top { display: flex; justify-content: space-between; gap: 8px; align-items: flex-start; }
.toolName { font-weight: 750; color: #dbeafe; font-size: 0.92rem; word-break: break-all; }
.badge-status { font-size: 0.75rem; font-weight: 800; letter-spacing: 0.04em; }
.badge-status.okText { color: var(--ok); }
.badge-status.failText { color: var(--fail); }
.badge-status.runText { color: var(--run); }
.badge-status.idleText { color: var(--idle); }
.one-line-summary {
  font-size: 0.84rem; color: #cbd5e1; min-height: 1.2em;
}
.fixture-label { font-size: 0.78rem; color: var(--muted); }
.desc-clamp {
  font-size: 0.78rem; color: var(--muted);
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}
.card-actions { display: flex; gap: 6px; flex-wrap: wrap; margin-top: auto; }
details.fold { font-size: 0.8rem; color: var(--muted); }
details.fold summary { cursor: pointer; color: #94a3b8; user-select: none; }
details.fold[open] summary { margin-bottom: 6px; }
pre.block {
  margin: 0; max-height: 140px; overflow: auto; padding: 8px 10px; border-radius: 10px;
  background: #050816; color: #cbd5e1; font-size: 0.72rem; white-space: pre-wrap;
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
}
.tableWrap {
  overflow: auto; border: 1px solid var(--line); border-radius: 16px; background: rgba(15,23,42,0.72);
  display: none;
}
.view-table .tableWrap { display: block; }
.view-table .tool-grid-wrap { display: none; }
.view-cards .tableWrap { display: none; }
.view-cards .tool-grid-wrap { display: block; }
table { width: 100%; border-collapse: collapse; min-width: 880px; }
th, td { padding: 10px 12px; border-bottom: 1px solid var(--line); vertical-align: top; text-align: left; font-size: 0.85rem; }
th {
  position: sticky; top: 0; background: #111827; color: #94a3b8;
  font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.06em; z-index: 1;
}
tr.row-status-ok { box-shadow: inset 3px 0 0 var(--ok); }
tr.row-status-fail { box-shadow: inset 3px 0 0 var(--fail); }
tr.row-status-running { box-shadow: inset 3px 0 0 var(--run); }
.dot { width: 8px; height: 8px; border-radius: 999px; background: var(--idle); display: inline-block; }
.dot.ok { background: var(--ok); } .dot.fail { background: var(--fail); } .dot.run { background: var(--run); }
.empty { color: var(--muted); padding: 24px; text-align: center; }
footer { color: var(--muted); margin-top: 22px; font-size: 0.85rem; line-height: 1.55; }
code { font-family: ui-monospace, Menlo, Consolas, monospace; font-size: 0.85em; }
@media (max-width: 900px) { .cards { grid-template-columns: repeat(2, minmax(0, 1fr)); } }
@media (max-width: 560px) {
  main { width: min(100% - 16px, 1200px); }
  .cards { grid-template-columns: 1fr; }
  table { min-width: 0; }
}
`;

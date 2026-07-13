import './styles.css';

import { createBriefing, type BirthInput, type DailyBriefing } from './domain/briefing';
import {
  createDeepCycleFortune,
  createMonthlyFortune,
  createTojeongFortune,
  createWeeklyFortune,
  type DeepCycleFortune,
  type MonthlyFortune,
  type TojeongFortune,
  type WeeklyFortune,
} from './domain/fortune';
import { addKstDays, kstToday } from './domain/kst';
import { McpClient, McpClientError, type AuthMode, type McpTrace } from './mcp/client';
import { FortuneMcp, type SajuSection } from './mcp/orchestrator';

interface FormState {
  name: string;
  birthDate: string;
  birthTime: string;
  birthTimeUnknown: boolean;
  gender: 'male' | 'female';
}

type ActiveTab = 'daily' | 'weekly' | 'monthly' | 'tojeong' | 'deep';
type IncludeMode = 'balanced' | 'compact';
type DeepMode = 'balanced' | 'expert';

interface ConnectionState {
  authMode: AuthMode;
  authToken: string;
  includeMode: IncludeMode;
  deepMode: DeepMode;
  targetYear: number;
  authPanelOpen: boolean;
}

type FortuneResult =
  | { kind: 'daily'; data: DailyBriefing }
  | { kind: 'weekly'; data: WeeklyFortune }
  | { kind: 'monthly'; data: MonthlyFortune }
  | { kind: 'tojeong'; data: TojeongFortune }
  | { kind: 'deep'; data: DeepCycleFortune };

interface AppState {
  activeTab: ActiveTab;
  status: 'idle' | 'loading' | 'success' | 'error';
  form: FormState;
  connection: ConnectionState;
  result?: FortuneResult;
  traces: McpTrace[];
  error?: { title: string; message: string; kind?: string };
}

const endpoint = import.meta.env.VITE_MCP_URL || '/mcp';
const defaultAuthMode = normalizeAuthMode(import.meta.env.VITE_MCP_AUTH_MODE);
const defaultAuthToken = import.meta.env.VITE_MCP_AUTH_TOKEN || '';
const today = kstToday();
const appElement = document.querySelector<HTMLDivElement>('#app');
const sampleForm: FormState = {
  name: '테스트 사용자',
  birthDate: '1990-03-15',
  birthTime: '14:30',
  birthTimeUnknown: false,
  gender: 'male',
};

if (!appElement) throw new Error('#app mount point가 없습니다.');
const appRoot: HTMLDivElement = appElement;

const tabs: Array<{ id: ActiveTab; label: string; short: string }> = [
  { id: 'daily', label: '오늘 운세 브리핑', short: '오늘' },
  { id: 'weekly', label: '주간 운세', short: '주간' },
  { id: 'monthly', label: '월간 운세', short: '월간' },
  { id: 'tojeong', label: '토정비결 연간 운세', short: '토정' },
  { id: 'deep', label: '대운/세운 깊이 분석', short: '심화' },
];

let state: AppState = {
  activeTab: 'daily',
  status: 'idle',
  form: sampleForm,
  connection: {
    authMode: defaultAuthMode,
    authToken: defaultAuthToken,
    includeMode: 'balanced',
    deepMode: 'balanced',
    targetYear: today.year,
    authPanelOpen: false,
  },
  traces: [],
};
let generationSequence = 0;

function normalizeAuthMode(value: string | undefined): AuthMode {
  if (value === 'x-token' || value === 'bearer') return value;
  return 'none';
}

function escapeHtml(value: unknown): string {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function formatBytes(bytes: number): string {
  if (bytes < 1024) return `${bytes} B`;
  return `${(bytes / 1024).toFixed(1)} KB`;
}

function authModeLabel(mode = state.connection.authMode): string {
  if (mode === 'x-token') return 'X-MCP-Auth-Token';
  if (mode === 'bearer') return 'Bearer 인증';
  return '로컬 개발 모드';
}

function endpointHint(): string {
  if (endpoint === '/mcp') return '/mcp → 로컬 MCP 서버(기본 127.0.0.1:3100/mcp)';
  return endpoint;
}

function includeModeLabel(mode = state.connection.includeMode): string {
  if (mode === 'compact') return 'compact: palja + sipsin';
  return '기본: palja + sipsin + sinsal + relations';
}

function deepModeLabel(mode = state.connection.deepMode): string {
  if (mode === 'expert') return 'expert: 전체 섹션';
  return 'balanced: 대운 + 세운 + 격국 + 용신';
}

function dailySections(mode: IncludeMode): SajuSection[] {
  return mode === 'compact' ? ['sipsin'] : ['sipsin', 'sinsal', 'relations'];
}

function deepSections(mode: DeepMode): SajuSection[] {
  if (mode === 'expert') {
    return ['sipsin', 'jijanggan', 'unsung', 'daeun', 'un', 'sinsal', 'relations', 'gyeokguk', 'yongsin'];
  }
  return ['daeun', 'un', 'gyeokguk', 'yongsin', 'relations'];
}

function activeLabel(): string {
  return tabs.find((tab) => tab.id === state.activeTab)?.label ?? '운세';
}

function tabLabel(tabId: ActiveTab): string {
  return tabs.find((tab) => tab.id === tabId)?.label ?? '운세';
}

function formFromDom(): FormState {
  const birthDate = document.querySelector<HTMLInputElement>('#birthDate')?.value ?? '';
  const birthTime = document.querySelector<HTMLInputElement>('#birthTime')?.value ?? '';
  return {
    name: document.querySelector<HTMLInputElement>('#name')?.value.trim() ?? '',
    birthDate,
    birthTime,
    birthTimeUnknown: document.querySelector<HTMLInputElement>('#birthTimeUnknown')?.checked ?? false,
    gender: (document.querySelector<HTMLSelectElement>('#gender')?.value === 'female' ? 'female' : 'male'),
  };
}

function connectionFromDom(): ConnectionState {
  const authValue = document.querySelector<HTMLSelectElement>('#authMode')?.value;
  const includeValue = document.querySelector<HTMLSelectElement>('#includeMode')?.value;
  const deepValue = document.querySelector<HTMLSelectElement>('#deepMode')?.value;
  const targetYear = Number(document.querySelector<HTMLInputElement>('#targetYear')?.value ?? state.connection.targetYear);
  return {
    authMode: normalizeAuthMode(authValue),
    authToken: document.querySelector<HTMLInputElement>('#authToken')?.value ?? '',
    includeMode: includeValue === 'compact' ? 'compact' : 'balanced',
    deepMode: deepValue === 'expert' ? 'expert' : 'balanced',
    targetYear: Number.isInteger(targetYear) ? targetYear : today.year,
    authPanelOpen: document.querySelector<HTMLDetailsElement>('#authSettings')?.open ?? state.connection.authPanelOpen,
  };
}

function parseBirthInput(form: FormState): BirthInput {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(form.birthDate);
  if (!match) throw new Error('생년월일을 YYYY-MM-DD 형식으로 입력해 주세요.');
  const [, yearText, monthText, dayText] = match;
  const year = Number(yearText);
  const month = Number(monthText);
  const day = Number(dayText);
  if (!Number.isInteger(year) || !Number.isInteger(month) || !Number.isInteger(day)) {
    throw new Error('생년월일 숫자를 확인해 주세요.');
  }

  let hour: number | null = null;
  let minute: number | null = null;
  if (!form.birthTimeUnknown && form.birthTime) {
    const timeMatch = /^(\d{2}):(\d{2})$/.exec(form.birthTime);
    if (!timeMatch) throw new Error('출생 시간은 HH:MM 형식으로 입력해 주세요.');
    hour = Number(timeMatch[1]);
    minute = Number(timeMatch[2]);
  }

  return {
    year,
    month,
    day,
    hour,
    minute,
    gender: form.gender,
    calendarType: 'solar',
    isLeapMonth: false,
    midnightMode: 'yaja',
    trueSolarTime: false,
    birthPlace: null,
  };
}

async function generateActiveFortune(): Promise<void> {
  const sequence = ++generationSequence;
  const activeTab = state.activeTab;
  const form = formFromDom();
  const connection = connectionFromDom();
  state = { ...state, status: 'loading', form, connection, error: undefined, traces: [], result: undefined };
  render();

  const client = new McpClient({
    endpoint,
    authMode: connection.authMode,
    authToken: connection.authToken,
    clientName: 'web-mcp-daily',
  });
  const fortune = new FortuneMcp(client);

  try {
    const birth = parseBirthInput(form);
    let result: FortuneResult;

    if (activeTab === 'daily') {
      const calendar = await fortune.callCalendarDay(today);
      const palja = await fortune.callSajuPalja(birth);
      const reading = await fortune.callSajuFullReading(birth, dailySections(connection.includeMode));
      result = { kind: 'daily', data: createBriefing({ today, calendar, palja, reading, traces: fortune.getTraces() }) };
    } else if (activeTab === 'weekly') {
      const dates = Array.from({ length: 7 }, (_, index) => addKstDays(today, index));
      const calendarDays = [];
      for (const date of dates) {
        calendarDays.push(await fortune.callCalendarDay(date));
      }
      const palja = await fortune.callSajuPalja(birth);
      const reading = await fortune.callSajuFullReading(birth, ['sipsin']);
      result = { kind: 'weekly', data: createWeeklyFortune({ dates, calendarDays, palja, reading }) };
    } else if (activeTab === 'monthly') {
      const calendarMonth = await fortune.callCalendarMonth({ year: today.year, month: today.month, compact: true });
      const palja = await fortune.callSajuPalja(birth);
      const reading = await fortune.callSajuFullReading(birth, ['sipsin']);
      result = { kind: 'monthly', data: createMonthlyFortune({ year: today.year, month: today.month, calendarMonth, palja, reading }) };
    } else if (activeTab === 'tojeong') {
      const tojeong = await fortune.callTojeongYearly(birth, connection.targetYear);
      result = { kind: 'tojeong', data: createTojeongFortune(tojeong) };
    } else {
      const daeun = await fortune.callSajuDaeun(birth, 8);
      const fullReading = await fortune.callSajuFullReading(birth, deepSections(connection.deepMode));
      result = { kind: 'deep', data: createDeepCycleFortune({ birth, fullReading, daeun, mode: connection.deepMode }) };
    }

    if (sequence !== generationSequence) return;
    state = { ...state, status: 'success', form, connection, result, traces: fortune.getTraces() };
  } catch (error) {
    if (sequence !== generationSequence) return;
    const traces = fortune.getTraces();
    if (error instanceof McpClientError) {
      state = {
        ...state,
        status: 'error',
        form,
        connection,
        traces,
        error: {
          title: `${tabLabel(activeTab)} 생성 실패`,
          message: error.message,
          kind: error.kind,
        },
      };
    } else {
      state = {
        ...state,
        status: 'error',
        form,
        connection,
        traces,
        error: {
          title: '입력 또는 응답 처리 실패',
          message: error instanceof Error ? error.message : String(error),
        },
      };
    }
  }
  render();
}

function runSampleFortune(): void {
  const scheduledSequence = ++generationSequence;
  const connection = connectionFromDom();
  state = {
    ...state,
    status: 'idle',
    form: sampleForm,
    connection,
    result: undefined,
    error: undefined,
    traces: [],
  };
  render();
  window.setTimeout(() => {
    if (scheduledSequence !== generationSequence) return;
    void generateActiveFortune();
  }, 0);
}

function renderKeywords(values: string[]): string {
  return values.map((value) => `<span class="chip">${escapeHtml(value)}</span>`).join('');
}

function renderTraceTable(traces: McpTrace[]): string {
  if (traces.length === 0) {
    return '<p class="muted">아직 MCP 호출 기록이 없습니다.</p>';
  }
  const rows = traces
    .map(
      (trace) => `
        <tr>
          <td>${escapeHtml(trace.toolName ?? trace.label)}</td>
          <td>${trace.status ? escapeHtml(trace.status) : '-'}</td>
          <td>${trace.ok ? '성공' : '실패'}</td>
          <td>${formatBytes(trace.bytes)}</td>
          <td>${trace.structuredContent ? '예' : '-'}</td>
          <td>${trace.durationMs}ms</td>
          <td>${trace.errorKind ? escapeHtml(trace.errorKind) : '-'}</td>
        </tr>
      `,
    )
    .join('');

  return `
    <div class="tableWrap">
      <table>
        <thead>
          <tr>
            <th>호출</th>
            <th>HTTP</th>
            <th>상태</th>
            <th>크기</th>
            <th>structured</th>
            <th>시간</th>
            <th>분류</th>
          </tr>
        </thead>
        <tbody>${rows}</tbody>
      </table>
    </div>
  `;
}

function renderDaily(data: DailyBriefing): string {
  return `
    <section class="statusBand success" data-status="success">
      <strong>MCP 서버를 통해 생성됨</strong>
      <span>${escapeHtml(data.dateLabel)} · ${escapeHtml(data.todayGanji)} · ${escapeHtml(data.todayElement)} · ${escapeHtml(includeModeLabel())}</span>
    </section>
    <section class="cards">
      <article class="card modeCard">
        <span class="eyebrow">오늘 모드</span>
        <h2>${escapeHtml(data.mode)}</h2>
        <p>${escapeHtml(data.modeLine)}</p>
      </article>
      <article class="card">
        <span class="eyebrow">오늘의 기운</span>
        <h3>${escapeHtml(data.todayGanji)} · ${escapeHtml(data.todayElement)}</h3>
        <div class="chips">${renderKeywords(data.energyKeywords)}</div>
      </article>
      <article class="card">
        <span class="eyebrow">나에게 들어오는 흐름</span>
        <h3>내 일주 ${escapeHtml(data.personalDayPillar)}</h3>
        <p>${escapeHtml(data.flow)}</p>
      </article>
      <article class="card">
        <span class="eyebrow">오늘의 행동 제안</span>
        <ul>${data.actions.map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul>
      </article>
      <article class="card">
        <span class="eyebrow">주의 키워드</span>
        <div class="chips caution">${renderKeywords(data.cautionKeywords)}</div>
      </article>
      <article class="card">
        <span class="eyebrow">근거</span>
        <ul>${data.evidence.map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul>
        <p class="metaLine">engine ${escapeHtml(data.meta.engineVersion ?? '-')} · rule ${escapeHtml(data.meta.ruleVersion ?? '-')} · include ${escapeHtml(data.meta.sections.join(', ') || '-')}</p>
      </article>
    </section>
  `;
}

function renderWeekly(data: WeeklyFortune): string {
  return `
    <section class="statusBand success" data-status="success"><strong>${escapeHtml(data.mode)}</strong><span>${escapeHtml(data.rangeLabel)}</span></section>
    <section class="cards">
      <article class="card modeCard"><span class="eyebrow">주간 요약</span><h2>주간 운세</h2><p>${escapeHtml(data.summary)}</p><div class="chips">${renderKeywords(data.keywords)}</div></article>
      <article class="card"><span class="eyebrow">집중하기 좋은 날</span><ul>${data.goodDays.map((item) => `<li>${escapeHtml(item.label)} · ${escapeHtml(item.ganji)} · ${escapeHtml(item.reason)}</li>`).join('')}</ul></article>
      <article class="card"><span class="eyebrow">주의가 필요한 날</span><ul>${data.cautionDays.map((item) => `<li>${escapeHtml(item.label)} · ${escapeHtml(item.ganji)} · ${escapeHtml(item.reason)}</li>`).join('')}</ul></article>
      <article class="card wideCard"><span class="eyebrow">7일 일진 타임라인</span><div class="miniGrid">${data.timeline.map((item) => `<div class="miniTile"><strong>${escapeHtml(item.label)}</strong><span>${escapeHtml(item.ganji)} · ${escapeHtml(item.element)}</span><p>${escapeHtml(item.note)}</p></div>`).join('')}</div></article>
      <article class="card"><span class="eyebrow">근거</span><ul>${data.evidence.map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul></article>
    </section>
  `;
}

function renderMonthly(data: MonthlyFortune): string {
  return `
    <section class="statusBand success" data-status="success"><strong>${escapeHtml(data.mode)}</strong><span>${escapeHtml(data.monthLabel)} · ${escapeHtml(data.monthGanji)}</span></section>
    <section class="cards">
      <article class="card modeCard"><span class="eyebrow">월간 요약</span><h2>월간 운세</h2><p>${escapeHtml(data.summary)}</p><div class="chips">${renderKeywords(data.keywords)}</div></article>
      <article class="card"><span class="eyebrow">좋은 날 후보</span><ul>${data.goodDays.map((item) => `<li>${escapeHtml(item.date)} · ${escapeHtml(item.ganji)} · ${escapeHtml(item.reason)}</li>`).join('')}</ul></article>
      <article class="card"><span class="eyebrow">주의 날 후보</span><ul>${data.cautionDays.map((item) => `<li>${escapeHtml(item.date)} · ${escapeHtml(item.ganji)} · ${escapeHtml(item.reason)}</li>`).join('')}</ul></article>
      <article class="card"><span class="eyebrow">전환점</span><ul>${(data.turningPoints.length > 0 ? data.turningPoints : ['절기 전환점은 별도 표기 없음']).map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul></article>
      <article class="card"><span class="eyebrow">근거</span><ul>${data.evidence.map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul></article>
    </section>
  `;
}

function renderTojeong(data: TojeongFortune): string {
  return `
    <section class="statusBand success" data-status="success"><strong>${escapeHtml(data.targetYear)} 토정비결</strong><span>${escapeHtml(data.title)} · ${escapeHtml(data.gwae)}</span></section>
    <section class="cards">
      <article class="card modeCard"><span class="eyebrow">연간 총운</span><h2>${escapeHtml(data.title)}</h2><p>${escapeHtml(data.overall)}</p><div class="chips">${renderKeywords(data.keywords)}</div></article>
      <article class="card wideCard"><span class="eyebrow">12개월 운세</span><div class="miniGrid">${data.monthly.map((item, index) => `<div class="miniTile"><strong>${index + 1}월</strong><p>${escapeHtml(item)}</p></div>`).join('')}</div></article>
      <article class="card"><span class="eyebrow">심화 보기</span><p>대운/세운 관점은 별도 호출로 분리했습니다.</p><button class="secondaryButton" id="openDeepFromYearly" type="button">대운/세운 탭으로 이동</button></article>
      <article class="card"><span class="eyebrow">근거</span><ul>${data.evidence.map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul></article>
    </section>
  `;
}

function renderDeep(data: DeepCycleFortune): string {
  return `
    <section class="statusBand success" data-status="success"><strong>${escapeHtml(data.mode)}</strong><span>${escapeHtml(data.currentDaeun)}</span></section>
    <section class="cards">
      <article class="card modeCard"><span class="eyebrow">깊이 분석 요약</span><h2>대운/세운</h2><p>${escapeHtml(data.summary)}</p></article>
      <article class="card"><span class="eyebrow">현재 대운</span><h3>${escapeHtml(data.currentDaeun)}</h3></article>
      <article class="card"><span class="eyebrow">세운/월운</span><p>세운 ${escapeHtml(data.seun)} · 월운 ${escapeHtml(data.wolun)}</p></article>
      <article class="card"><span class="eyebrow">용신/기신</span><p>${escapeHtml(data.yongsin)}</p></article>
      <article class="card"><span class="eyebrow">격국</span><p>${escapeHtml(data.gyeokguk)}</p></article>
      <article class="card"><span class="eyebrow">주의 포인트</span><ul>${data.cautions.map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul></article>
      <article class="card"><span class="eyebrow">근거</span><ul>${data.evidence.map((item) => `<li>${escapeHtml(item)}</li>`).join('')}</ul></article>
    </section>
  `;
}

function renderResult(): string {
  if (state.status === 'loading') {
    return `<section class="statusBand loading" data-status="loading"><strong>${escapeHtml(activeLabel())} 생성 중</strong><span>MCP tool 응답을 기다리고 있습니다.</span></section>`;
  }
  if (state.status === 'error') {
    return `
      <section class="statusBand error" data-status="error">
        <strong>${escapeHtml(state.error?.title ?? '오류')}</strong>
        <span>${escapeHtml(state.error?.message ?? '알 수 없는 오류')}</span>
        ${state.error?.kind ? `<em>${escapeHtml(state.error.kind)}</em>` : ''}
      </section>
    `;
  }
  if (state.result?.kind === 'daily') return renderDaily(state.result.data);
  if (state.result?.kind === 'weekly') return renderWeekly(state.result.data);
  if (state.result?.kind === 'monthly') return renderMonthly(state.result.data);
  if (state.result?.kind === 'tojeong') return renderTojeong(state.result.data);
  if (state.result?.kind === 'deep') return renderDeep(state.result.data);
  return `
    <section class="statusBand idle" data-status="idle">
      <strong>${escapeHtml(activeLabel())} 대기</strong>
      <span>테스트 데이터로 바로 실행을 누르면 선택한 메뉴의 MCP tool chain이 실제 호출됩니다.</span>
    </section>
  `;
}

function renderTabs(): string {
  return `
    <nav class="tabBar" aria-label="운세 메뉴">
      ${tabs.map((tab) => `
        <button class="tabButton ${state.activeTab === tab.id ? 'active' : ''}" type="button" data-tab="${tab.id}" aria-pressed="${state.activeTab === tab.id}">
          <span>${escapeHtml(tab.short)}</span>
          <strong>${escapeHtml(tab.label)}</strong>
        </button>
      `).join('')}
    </nav>
  `;
}

function render(): void {
  appRoot.innerHTML = `
    <main class="appShell">
      <section class="topBar">
        <div>
          <p class="eyebrow">manseryeok-mcp fortune suite</p>
          <h1>MCP 운세 브리핑</h1>
        </div>
        <div class="endpointBadge">
          <span>로컬 MCP 서버</span>
          <strong>${escapeHtml(authModeLabel())}</strong>
        </div>
      </section>

      <section class="testStrip">
        <div>
          <strong>로컬 MCP 테스트 모드</strong>
          <span>이 화면은 다섯 운세 메뉴가 MCP 서버 호출로 동작하는지 확인하는 로컬 데모입니다. ${escapeHtml(endpointHint())}</span>
        </div>
        <button class="secondaryButton" id="topQuickTest" type="button" ${state.status === 'loading' ? 'disabled' : ''}>
          선택 메뉴 샘플 실행
        </button>
      </section>

      ${renderTabs()}

      <section class="layout">
        <form class="inputPanel" id="briefingForm">
          <div class="formHeader">
            <div>
              <span class="eyebrow">입력</span>
              <h2>${escapeHtml(today.label)} 기준</h2>
            </div>
            <span class="todayBadge">KST</span>
          </div>
          <label>
            이름
            <input id="name" name="name" type="text" autocomplete="name" value="${escapeHtml(state.form.name)}" />
          </label>
          <label>
            생년월일
            <input id="birthDate" name="birthDate" type="date" required value="${escapeHtml(state.form.birthDate)}" />
          </label>
          <div class="inlineFields">
            <label>
              출생 시간
              <input id="birthTime" name="birthTime" type="time" value="${escapeHtml(state.form.birthTime)}" ${state.form.birthTimeUnknown ? 'disabled' : ''} />
            </label>
            <label>
              성별
              <select id="gender" name="gender">
                <option value="male" ${state.form.gender === 'male' ? 'selected' : ''}>남성</option>
                <option value="female" ${state.form.gender === 'female' ? 'selected' : ''}>여성</option>
              </select>
            </label>
          </div>
          <label class="checkLine">
            <input id="birthTimeUnknown" name="birthTimeUnknown" type="checkbox" ${state.form.birthTimeUnknown ? 'checked' : ''} />
            출생 시간을 모름
          </label>
          <div class="buttonRow">
            <button class="primaryButton" id="submitBriefing" type="submit" ${state.status === 'loading' ? 'disabled' : ''}>
              ${escapeHtml(activeLabel())} 생성
            </button>
            <button class="secondaryButton" id="quickTest" type="button" ${state.status === 'loading' ? 'disabled' : ''}>
              샘플 실행
            </button>
          </div>
          <p class="smallNote">출생 정보는 서버에 저장하지 않고 현재 MCP 요청에만 사용합니다.</p>
          <details class="settingsPanel" id="authSettings" ${state.connection.authPanelOpen ? 'open' : ''}>
            <summary>연결/인증/응답 정책</summary>
            <label>
              인증 방식
              <select id="authMode" name="authMode">
                <option value="none" ${state.connection.authMode === 'none' ? 'selected' : ''}>로컬 개발 모드</option>
                <option value="x-token" ${state.connection.authMode === 'x-token' ? 'selected' : ''}>X-MCP-Auth-Token</option>
                <option value="bearer" ${state.connection.authMode === 'bearer' ? 'selected' : ''}>Authorization Bearer</option>
              </select>
            </label>
            <label>
              토큰
              <input id="authToken" name="authToken" type="password" autocomplete="off" value="${escapeHtml(state.connection.authToken)}" placeholder="MCP_AUTH_TOKEN 값" />
            </label>
            <label>
              오늘 응답 정책
              <select id="includeMode" name="includeMode">
                <option value="balanced" ${state.connection.includeMode === 'balanced' ? 'selected' : ''}>기본: sipsin + sinsal + relations</option>
                <option value="compact" ${state.connection.includeMode === 'compact' ? 'selected' : ''}>compact: sipsin only</option>
              </select>
            </label>
            <label>
              대운/세운 깊이
              <select id="deepMode" name="deepMode">
                <option value="balanced" ${state.connection.deepMode === 'balanced' ? 'selected' : ''}>balanced</option>
                <option value="expert" ${state.connection.deepMode === 'expert' ? 'selected' : ''}>expert</option>
              </select>
            </label>
            <label>
              토정 대상 연도
              <input id="targetYear" name="targetYear" type="number" min="1908" max="2101" value="${escapeHtml(state.connection.targetYear)}" />
            </label>
            <p class="smallNote">토큰은 저장하지 않고 현재 화면의 MCP 요청 header에만 사용합니다. 대형 응답은 compact/include 정책으로 먼저 줄입니다.</p>
          </details>
        </form>

        <section class="resultPanel">
          ${renderResult()}
          <section class="verifyPanel">
            <div class="verifyHeader">
              <div>
                <span class="eyebrow">MCP 검증 정보</span>
                <h2>호출 기록</h2>
              </div>
              <span>${escapeHtml(endpointHint())} · ${escapeHtml(authModeLabel())} · ${escapeHtml(includeModeLabel())} · ${escapeHtml(deepModeLabel())}</span>
            </div>
            ${renderTraceTable(state.traces)}
          </section>
        </section>
      </section>
    </main>
  `;

  document.querySelector<HTMLFormElement>('#briefingForm')?.addEventListener('submit', (event) => {
    event.preventDefault();
    void generateActiveFortune();
  });
  document.querySelector<HTMLButtonElement>('#quickTest')?.addEventListener('click', runSampleFortune);
  document.querySelector<HTMLButtonElement>('#topQuickTest')?.addEventListener('click', runSampleFortune);
  document.querySelectorAll<HTMLButtonElement>('[data-tab]').forEach((button) => {
    button.addEventListener('click', () => {
      const tab = button.dataset.tab as ActiveTab | undefined;
      if (!tab) return;
      generationSequence += 1;
      state = { ...state, activeTab: tab, status: 'idle', form: formFromDom(), connection: connectionFromDom(), result: undefined, traces: [], error: undefined };
      render();
    });
  });
  document.querySelector<HTMLInputElement>('#birthTimeUnknown')?.addEventListener('change', () => {
    state = { ...state, form: formFromDom(), connection: connectionFromDom() };
    render();
  });
  ['#authMode', '#includeMode', '#deepMode'].forEach((selector) => {
    document.querySelector<HTMLSelectElement>(selector)?.addEventListener('change', () => {
      state = { ...state, form: formFromDom(), connection: connectionFromDom() };
      render();
    });
  });
  document.querySelector<HTMLButtonElement>('#openDeepFromYearly')?.addEventListener('click', () => {
    generationSequence += 1;
    state = { ...state, activeTab: 'deep', status: 'idle', form: formFromDom(), connection: connectionFromDom(), result: undefined, traces: [], error: undefined };
    render();
  });
}

render();

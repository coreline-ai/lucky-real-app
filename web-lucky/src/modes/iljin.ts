import { renderShell } from '../app/shell';
import { kstNowParts } from '../domain/kst';
import { runIljinDay, shiftDate } from '../domain/iljin';

function pad(y: number, m: number, d: number): string {
  return `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

export function renderIljinMode(
  root: HTMLElement,
  onHome: () => void,
): void {
  const kst = kstNowParts();
  let y = kst.year;
  let m = kst.month;
  let d = kst.day;
  let renderSeq = 0;
  const handleHome = () => {
    renderSeq += 1;
    onHome();
  };

  const paint = async () => {
    const seq = ++renderSeq;
    let body: string;
    const renderBody = (bodyHtml: string) => {
      renderShell(root, {
        title: '오늘의 일진',
        eyebrow: 'web-lucky · 일진',
        showHome: true,
        onHome: handleHome,
        bodyHtml,
        testId: 'iljin-body',
      });

      const applyDate = () => {
        const val = (root.querySelector('#iljin-date') as HTMLInputElement).value;
        const [ys, ms, ds] = val.split('-').map(Number);
        y = ys;
        m = ms;
        d = ds;
        void paint();
      };
      root.querySelector('#iljin-apply')?.addEventListener('click', applyDate);
      root.querySelector('#iljin-prev')?.addEventListener('click', () => {
        const n = shiftDate(y, m, d, -1);
        y = n.year;
        m = n.month;
        d = n.day;
        void paint();
      });
      root.querySelector('#iljin-next')?.addEventListener('click', () => {
        const n = shiftDate(y, m, d, 1);
        y = n.year;
        m = n.month;
        d = n.day;
        void paint();
      });
    };

    renderBody(`
      <section class="card" data-testid="iljin-loading">
        <h2>일진 요약</h2>
        <div class="field-row">
          <div class="field">
            <label for="iljin-date">조회 날짜 (양력)</label>
            <input id="iljin-date" type="date" value="${pad(y, m, d)}" />
          </div>
        </div>
        <div class="actions">
          <button type="button" class="secondary" id="iljin-prev">← 하루 전</button>
          <button type="button" class="primary" id="iljin-apply">조회</button>
          <button type="button" class="secondary" id="iljin-next">하루 후 →</button>
        </div>
        <p class="help">해당 연도 shard 로딩 중…</p>
      </section>`);

    const outcome = await runIljinDay(y, m, d);
    if (seq !== renderSeq) return;
    if (!outcome.ok) {
      body = `
        <div class="error-box" data-testid="error-box" role="alert">${outcome.message}</div>
        <div class="field">
          <label for="iljin-date">조회 날짜</label>
          <input id="iljin-date" type="date" value="${pad(y, m, d)}" />
        </div>
        <div class="actions">
          <button type="button" class="primary" id="iljin-apply">조회</button>
        </div>`;
    } else {
      const info = outcome.dayInfo;
      const jieqiRaw = (info as { jieqi?: unknown }).jieqi;
      const jieqi =
        jieqiRaw == null
          ? '—'
          : typeof jieqiRaw === 'string'
            ? jieqiRaw
            : typeof jieqiRaw === 'object' &&
                jieqiRaw !== null &&
                'koreanName' in jieqiRaw
              ? String((jieqiRaw as { koreanName: string }).koreanName)
              : String(jieqiRaw);
      body = `
        <section class="card" data-testid="iljin-result">
          <h2>일진 요약</h2>
          <div class="field-row">
            <div class="field">
              <label for="iljin-date">조회 날짜 (양력)</label>
              <input id="iljin-date" type="date" value="${pad(y, m, d)}" />
            </div>
          </div>
          <div class="actions">
            <button type="button" class="secondary" id="iljin-prev">← 하루 전</button>
            <button type="button" class="primary" id="iljin-apply">조회</button>
            <button type="button" class="secondary" id="iljin-next">하루 후 →</button>
          </div>
          <dl class="kv" data-testid="iljin-kv">
            <div><dt>양력</dt><dd>${info.solarDate}</dd></div>
            <div><dt>음력</dt><dd>${info.lunarDate}${info.isLeapMonth ? ' (윤달)' : ''}</dd></div>
            <div><dt>일진</dt><dd data-testid="iljin-ganji">${info.dayGanJi}</dd></div>
            <div><dt>오행</dt><dd>${info.ohaeng}</dd></div>
            <div><dt>12신살</dt><dd>${info.sinsal12}</dd></div>
            <div><dt>길흉</dt><dd>${info.gilhyung}</dd></div>
            <div><dt>택일 힌트</dt><dd>${info.taekil}</dd></div>
            <div><dt>절기</dt><dd>${jieqi}</dd></div>
          </dl>
          <p class="help">길흉은 전통 달력 참고용이며, 일정 성공을 보장하지 않습니다.</p>
        </section>`;
    }

    renderBody(body);
  };

  void paint();
}

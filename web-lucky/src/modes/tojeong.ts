import { DISCLAIMER } from '../app/constants';
import { renderShell } from '../app/shell';
import { defaultTargetYear, kstNowParts, yearPresetList } from '../domain/kst';
import { overallTone } from '../domain/overall-badge';
import { buildShareText, shareTextLooksSafe } from '../domain/share';
import {
  runTojeongYearly,
  type BirthInput,
  type CalendarType,
  type TojeongYearlyOk,
} from '../domain/tojeong';

const MONTH_LABELS = [
  '1월',
  '2월',
  '3월',
  '4월',
  '5월',
  '6월',
  '7월',
  '8월',
  '9월',
  '10월',
  '11월',
  '12월',
];

type ViewState =
  | { kind: 'form'; keepYear?: number }
  | { kind: 'loading' }
  | { kind: 'result'; outcome: TojeongYearlyOk; birth: BirthInput }
  | { kind: 'error'; message: string; birth: BirthInput; targetYear: number };

function padDate(y: number, m: number, d: number): string {
  return `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
}

function previewText(full: string, max = 42): string {
  const t = full.trim();
  return t.length > max ? `${t.slice(0, max)}…` : t;
}

function showToast(message: string): void {
  let el = document.querySelector<HTMLDivElement>('.toast');
  if (!el) {
    el = document.createElement('div');
    el.className = 'toast';
    document.body.appendChild(el);
  }
  el.textContent = message;
  el.classList.add('show');
  window.setTimeout(() => el?.classList.remove('show'), 2200);
}

export function renderTojeongMode(
  root: HTMLElement,
  onHome: () => void,
): void {
  let state: ViewState = { kind: 'form' };
  let expandedMonth: number | null = null;
  let lastBirth: BirthInput | null = null;
  let lastTargetYear = defaultTargetYear();
  let calculationSequence = 0;
  const handleHome = () => {
    calculationSequence += 1;
    onHome();
  };

  const parseForm = (
    form: HTMLFormElement,
  ): { birth: BirthInput; targetYear: number } | { error: string } => {
    const dateVal = (form.elements.namedItem('birthDate') as HTMLInputElement)
      .value;
    const calendarType = (
      form.elements.namedItem('calendarType') as HTMLSelectElement
    ).value as CalendarType;
    const isLeapMonth = (
      form.elements.namedItem('isLeapMonth') as HTMLInputElement
    ).checked;
    const targetYear = Number(
      (form.elements.namedItem('targetYear') as HTMLInputElement).value,
    );
    if (!dateVal) return { error: '생년월일을 입력해 주세요.' };
    const [year, month, day] = dateVal.split('-').map(Number);
    if (!year || !month || !day) {
      return { error: '생년월일 형식이 올바르지 않습니다.' };
    }
    return {
      birth: {
        year,
        month,
        day,
        calendarType,
        isLeapMonth: calendarType === 'lunar' ? isLeapMonth : false,
      },
      targetYear,
    };
  };

  const runCalculation = (birth: BirthInput, targetYear: number) => {
    const sequence = ++calculationSequence;
    lastBirth = birth;
    lastTargetYear = targetYear;
    state = { kind: 'loading' };
    paint();
    window.setTimeout(() => {
      void (async () => {
        const outcome = await runTojeongYearly(birth, targetYear);
        if (sequence !== calculationSequence) return;
        if (!outcome.ok) {
          state = {
            kind: 'error',
            message: outcome.message,
            birth,
            targetYear,
          };
        } else {
          expandedMonth = null;
          state = { kind: 'result', outcome, birth };
        }
        paint();
      })();
    }, 40);
  };

  const paint = () => {
    if (state.kind === 'loading') {
      renderShell(root, {
        title: '토정 한 해 요약',
        eyebrow: 'web-lucky · 토정',
        showHome: true,
        onHome: handleHome,
        bodyHtml: `<div class="card loading" data-testid="loading">144괘 중 배정 중…</div>`,
      });
      return;
    }

    if (state.kind === 'error') {
      const st = state;
      renderShell(root, {
        title: '토정 한 해 요약',
        eyebrow: 'web-lucky · 토정',
        showHome: true,
        onHome: handleHome,
        bodyHtml: `
          <div class="error-box" data-testid="error-box" role="alert">${st.message}</div>
          <div class="actions">
            <button type="button" class="primary" id="back-form">입력 수정</button>
            <button type="button" class="secondary" id="retry">다시 시도</button>
          </div>`,
      });
      root.querySelector('#back-form')?.addEventListener('click', () => {
        state = { kind: 'form', keepYear: st.targetYear };
        lastBirth = st.birth;
        lastTargetYear = st.targetYear;
        paint();
      });
      root.querySelector('#retry')?.addEventListener('click', () => {
        runCalculation(st.birth, st.targetYear);
      });
      return;
    }

    if (state.kind === 'result') {
      const { outcome, birth } = state;
      const { result, lunarBirth, targetYear } = outcome;
      const inter = result.interpretation;
      const tone = overallTone(inter.overall);
      const kst = kstNowParts();
      const highlightYear = targetYear === kst.year;
      const monthsHtml = inter.monthly
        .map((text, i) => {
          const monthNum = i + 1;
          const classes = ['month-cell'];
          if (expandedMonth === i) classes.push('expanded');
          if (highlightYear) {
            if (monthNum < kst.month) classes.push('past');
            if (monthNum === kst.month) classes.push('current');
          }
          const body = expandedMonth === i ? text : previewText(text);
          return `
            <button type="button" class="${classes.join(' ')}" data-month="${i}" data-testid="month-cell-${i}">
              <div class="month-label">${MONTH_LABELS[i]}</div>
              <div class="month-preview">${body}</div>
            </button>`;
        })
        .join('');

      renderShell(root, {
        title: '토정 한 해 요약',
        eyebrow: 'web-lucky · 토정',
        showHome: true,
        onHome: handleHome,
        bodyHtml: `
          <section class="card result-hero" data-testid="result-hero">
            <div class="year-label">${targetYear}년 신수</div>
            <div class="meta-line" style="text-align:center">제${result.gwae.gwaeNumber}괘 · ${result.gwae.gwaeCode}</div>
            <h2 class="gwae-title" data-testid="gwae-title">${inter.title}</h2>
            <p class="poem">${inter.poem}</p>
            <div class="badge ${tone}" data-testid="overall-badge">${inter.overall}</div>
            <p class="description">${inter.description}</p>
            <p class="meta-line" data-testid="lunar-birth">
              계산에 사용한 음력 생일: ${lunarBirth.year}-${lunarBirth.month}-${lunarBirth.day}${lunarBirth.isLeapMonth ? ' (윤달)' : ''}
              ${birth.calendarType === 'solar' ? ` · 입력 양력 ${birth.year}-${birth.month}-${birth.day}` : ''}
            </p>
          </section>
          <section class="card">
            <h2>월별 12칸</h2>
            <div class="month-grid" data-testid="month-grid">${monthsHtml}</div>
          </section>
          <section class="card">
            <h2>다시 보기 · 공유</h2>
            <div class="field">
              <label for="rerun-year">대상 연도 변경</label>
              <input id="rerun-year" type="number" min="1900" max="2101" value="${targetYear}" />
            </div>
            <div class="actions">
              <button type="button" class="primary" id="rerun-year-btn">이 연도로 다시 보기</button>
              <button type="button" class="secondary" id="share-btn">공유 문장 복사</button>
              <button type="button" class="secondary" id="other-person">다른 입력</button>
            </div>
            <p class="help">공유 문장에는 생년월일을 넣지 않습니다. ${DISCLAIMER}</p>
          </section>`,
      });

      root.querySelectorAll<HTMLButtonElement>('[data-month]').forEach((btn) => {
        btn.addEventListener('click', () => {
          const idx = Number(btn.dataset.month);
          expandedMonth = expandedMonth === idx ? null : idx;
          paint();
        });
      });
      root.querySelector('#rerun-year-btn')?.addEventListener('click', () => {
        const y = Number(
          (root.querySelector('#rerun-year') as HTMLInputElement).value,
        );
        runCalculation(birth, y);
      });
      root.querySelector('#other-person')?.addEventListener('click', () => {
        lastBirth = null;
        lastTargetYear = targetYear;
        state = { kind: 'form', keepYear: targetYear };
        paint();
      });
      root.querySelector('#share-btn')?.addEventListener('click', async () => {
        const text = buildShareText({ targetYear, result });
        if (!shareTextLooksSafe(text)) {
          showToast('공유 문장 생성 오류');
          return;
        }
        try {
          await navigator.clipboard.writeText(text);
          showToast('공유 문장을 복사했습니다');
        } catch {
          const ta = document.createElement('textarea');
          ta.value = text;
          document.body.appendChild(ta);
          ta.select();
          document.execCommand('copy');
          ta.remove();
          showToast('공유 문장을 복사했습니다');
        }
      });
      return;
    }

    // form
    const keepYear = state.keepYear;
    const kst = kstNowParts();
    const presets = yearPresetList();
    const yearValue = keepYear ?? lastTargetYear ?? defaultTargetYear();
    const defaultDate =
      lastBirth != null
        ? padDate(lastBirth.year, lastBirth.month, lastBirth.day)
        : '1990-03-15';
    const cal = lastBirth?.calendarType ?? 'solar';
    const leap = lastBirth?.isLeapMonth ?? false;

    renderShell(root, {
      title: '토정 한 해 요약',
      eyebrow: 'web-lucky · 토정',
      showHome: true,
      onHome: handleHome,
      bodyHtml: `
        <section class="card" id="input-section">
          <h2>생일 · 대상 연도</h2>
          <p class="help">토정은 출생 시각을 사용하지 않습니다. 양력은 음력 변환 후 144괘를 배정합니다.</p>
          <form id="tojeong-form">
            <div class="field">
              <label for="birthDate">생년월일</label>
              <input id="birthDate" name="birthDate" type="date" required value="${defaultDate}" />
            </div>
            <div class="field-row">
              <div class="field">
                <label for="calendarType">달력</label>
                <select id="calendarType" name="calendarType">
                  <option value="solar" ${cal === 'solar' ? 'selected' : ''}>양력</option>
                  <option value="lunar" ${cal === 'lunar' ? 'selected' : ''}>음력</option>
                </select>
              </div>
              <div class="field">
                <label for="targetYear">대상 연도</label>
                <input id="targetYear" name="targetYear" type="number" min="1900" max="2101" required value="${yearValue}" />
              </div>
            </div>
            <div class="chips" id="year-presets">
              ${presets
                .map(
                  (y) =>
                    `<button type="button" class="chip${y === yearValue ? ' active' : ''}" data-year="${y}">${y}</button>`,
                )
                .join('')}
            </div>
            <label class="checkbox-row">
              <input type="checkbox" name="isLeapMonth" id="isLeapMonth" ${leap ? 'checked' : ''} ${cal === 'lunar' ? '' : 'disabled'} />
              음력 윤달
            </label>
            <div class="actions">
              <button type="submit" class="primary" id="submit-btn" data-testid="tojeong-submit">내 ${yearValue} 보기</button>
            </div>
          </form>
          <p class="help">오늘(KST) ${kst.year}-${String(kst.month).padStart(2, '0')}-${String(kst.day).padStart(2, '0')}</p>
        </section>`,
    });

    const form = root.querySelector<HTMLFormElement>('#tojeong-form')!;
    const calSelect = root.querySelector<HTMLSelectElement>('#calendarType')!;
    const leapInput = root.querySelector<HTMLInputElement>('#isLeapMonth')!;
    const yearInput = root.querySelector<HTMLInputElement>('#targetYear')!;
    const submitBtn = root.querySelector<HTMLButtonElement>('#submit-btn')!;
    const syncLeap = () => {
      leapInput.disabled = calSelect.value !== 'lunar';
      if (calSelect.value !== 'lunar') leapInput.checked = false;
    };
    calSelect.addEventListener('change', syncLeap);
    syncLeap();
    root.querySelectorAll<HTMLButtonElement>('#year-presets .chip').forEach((chip) => {
      chip.addEventListener('click', () => {
        const y = Number(chip.dataset.year);
        yearInput.value = String(y);
        submitBtn.textContent = `내 ${y} 보기`;
        root
          .querySelectorAll('#year-presets .chip')
          .forEach((c) => c.classList.remove('active'));
        chip.classList.add('active');
      });
    });
    form.addEventListener('submit', (ev) => {
      ev.preventDefault();
      const parsed = parseForm(form);
      if ('error' in parsed) {
        state = {
          kind: 'error',
          message: parsed.error,
          birth: lastBirth ?? {
            year: 1990,
            month: 3,
            day: 15,
            calendarType: 'solar',
          },
          targetYear: Number(yearInput.value) || defaultTargetYear(),
        };
        paint();
        return;
      }
      runCalculation(parsed.birth, parsed.targetYear);
    });
  };

  paint();
}

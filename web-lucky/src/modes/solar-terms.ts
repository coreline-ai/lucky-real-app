import { renderShell } from '../app/shell';
import { kstNowParts } from '../domain/kst';
import { daysUntilTerm, runSolarTermsYear } from '../domain/solar-terms';

export function renderSolarTermsMode(
  root: HTMLElement,
  onHome: () => void,
): void {
  const kst = kstNowParts();
  let year = kst.year;
  let renderSeq = 0;
  const handleHome = () => {
    renderSeq += 1;
    onHome();
  };

  const paint = async () => {
    const seq = ++renderSeq;
    const requestedYear = year;
    renderShell(root, {
      title: '절기 타임라인',
      eyebrow: 'web-lucky · 절기',
      showHome: true,
      onHome: handleHome,
      bodyHtml: `<section class="card loading" data-testid="loading">
        <div class="actions">
          <button type="button" class="secondary" id="year-prev">← ${requestedYear - 1}</button>
          <strong>${requestedYear}년 shard 로딩 중…</strong>
          <button type="button" class="secondary" id="year-next">${requestedYear + 1} →</button>
        </div>
      </section>`,
      testId: 'solar-terms-body',
    });
    root.querySelector('#year-prev')?.addEventListener('click', () => {
      year = requestedYear - 1;
      void paint();
    });
    root.querySelector('#year-next')?.addEventListener('click', () => {
      year = requestedYear + 1;
      void paint();
    });
    const outcome = await runSolarTermsYear(requestedYear, kst);
    if (seq !== renderSeq) return;
    let body: string;
    if (!outcome.ok) {
      body = `<div class="error-box" role="alert">${outcome.message}</div>`;
    } else {
      const next = outcome.next;
      const current = outcome.current;
      const nextBanner = next
        ? `<div class="banner next-term" data-testid="next-term">다음 절기: <strong>${next.koreanName}</strong>
            (${next.year}-${next.month}-${next.day} ${String(next.hour).padStart(2, '0')}:${String(next.minute).padStart(2, '0')})
            · D${daysUntilTerm(next, kst) >= 0 ? '-' : '+'}${Math.abs(daysUntilTerm(next, kst))}</div>`
        : `<div class="banner" data-testid="next-term">이 목록에서 남은 다음 절기가 없습니다.</div>`;
      const curBanner = current
        ? `<p class="help" data-testid="current-term">지금 구간 마커: ${current.koreanName} 이후</p>`
        : '';

      const list = outcome.terms
        .map((t) => {
          const isNext =
            next != null &&
            t.koreanName === next.koreanName &&
            t.month === next.month &&
            t.day === next.day;
          const isCur =
            current != null &&
            t.koreanName === current.koreanName &&
            t.month === current.month &&
            t.day === current.day;
          const cls = [
            'term-item',
            isNext ? 'is-next' : '',
            isCur ? 'is-current' : '',
          ]
            .filter(Boolean)
            .join(' ');
          return `<li class="${cls}" data-testid="term-${t.koreanName}">
            <span class="term-name">${t.koreanName}</span>
            <span class="term-when">${t.month}/${t.day} ${String(t.hour).padStart(2, '0')}:${String(t.minute).padStart(2, '0')}</span>
          </li>`;
        })
        .join('');

      body = `
        <section class="card" data-testid="solar-terms-result">
          <div class="actions">
            <button type="button" class="secondary" id="year-prev">← ${requestedYear - 1}</button>
            <strong data-testid="solar-year">${requestedYear}년</strong>
            <button type="button" class="secondary" id="year-next">${requestedYear + 1} →</button>
          </div>
          ${nextBanner}
          ${curBanner}
          <ol class="term-list" data-testid="term-list">${list}</ol>
        </section>`;
    }

    renderShell(root, {
      title: '절기 타임라인',
      eyebrow: 'web-lucky · 절기',
      showHome: true,
      onHome: handleHome,
      bodyHtml: body,
      testId: 'solar-terms-body',
    });

    root.querySelector('#year-prev')?.addEventListener('click', () => {
      year = requestedYear - 1;
      void paint();
    });
    root.querySelector('#year-next')?.addEventListener('click', () => {
      year = requestedYear + 1;
      void paint();
    });
  };

  void paint();
}

import { DISCLAIMER, type ModeMeta } from './constants';

export function renderShell(
  root: HTMLElement,
  opts: {
    title: string;
    eyebrow?: string;
    showHome?: boolean;
    onHome?: () => void;
    bodyHtml: string;
    testId?: string;
  },
): void {
  root.innerHTML = `
    <header class="hero">
      <p class="eyebrow">${opts.eyebrow ?? 'web-lucky'}</p>
      <h1>${opts.title}</h1>
      ${
        opts.showHome
          ? `<div class="actions hero-actions"><button type="button" class="secondary" id="nav-home" data-testid="nav-home">← 홈으로</button></div>`
          : ''
      }
    </header>
    <p class="disclaimer" data-testid="disclaimer-shell">${DISCLAIMER}</p>
    <div id="mode-body" data-testid="${opts.testId ?? 'mode-body'}">${opts.bodyHtml}</div>
    <p class="footer">${DISCLAIMER} · manseryeok-engine</p>
  `;
  if (opts.showHome && opts.onHome) {
    root.querySelector('#nav-home')?.addEventListener('click', opts.onHome);
  }
}

export function modeCardsHtml(catalog: ModeMeta[]): string {
  return `
    <section class="card hub-intro">
      <h2>무엇을 볼까요?</h2>
      <p class="help">만세력 엔진으로 계산하는 가벼운 웹 도구 모음입니다. 서버에 저장하지 않습니다.</p>
      <div class="hub-grid" data-testid="hub-grid">
        ${catalog
          .map(
            (m) => `
          <button type="button" class="hub-card" data-mode="${m.id}" data-testid="hub-card-${m.id}">
            <span class="hub-emoji" aria-hidden="true">${m.emoji}</span>
            <span class="hub-title">${m.title}</span>
            <span class="hub-blurb">${m.blurb}</span>
          </button>`,
          )
          .join('')}
      </div>
    </section>`;
}

import { MODE_CATALOG, type ModeId } from '../app/constants';
import { modeCardsHtml, renderShell } from '../app/shell';

export function renderHome(
  root: HTMLElement,
  onSelect: (mode: ModeId) => void,
): void {
  renderShell(root, {
    title: 'web-lucky',
    eyebrow: '만세력 라이트 도구',
    showHome: false,
    bodyHtml: modeCardsHtml(MODE_CATALOG),
    testId: 'home-body',
  });
  const lead = document.createElement('p');
  lead.className = 'lead hub-lead';
  lead.textContent =
    '일진 · 케미 · 이름 · 절기 · 토정 — 원하는 도구를 골라 바로 계산해 보세요.';
  root.querySelector('.hero')?.appendChild(lead);

  root.querySelectorAll<HTMLButtonElement>('[data-mode]').forEach((btn) => {
    btn.addEventListener('click', () => {
      const mode = btn.dataset.mode as ModeId;
      onSelect(mode);
    });
  });
}

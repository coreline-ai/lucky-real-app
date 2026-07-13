import { renderShell } from '../app/shell';
import { parseGivenNameCandidates, runNaming } from '../domain/naming';

function escapeHtml(value: unknown): string {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

export function renderNamingMode(
  root: HTMLElement,
  onHome: () => void,
): void {
  let resultHtml = '';

  const paint = () => {
    const body = `
      <section class="card">
        <h2>성 · 이름 후보</h2>
        <p class="help">후보는 쉼표 또는 줄바꿈으로 구분해 최대 6개까지 비교합니다. (한글 1~2글자)</p>
        <form id="naming-form">
          <div class="field">
            <label for="surname">성 (한 글자)</label>
            <input id="surname" name="surname" type="text" maxlength="2" required value="김" />
          </div>
          <div class="field">
            <label for="candidates">이름 후보</label>
            <textarea id="candidates" name="candidates" rows="4" required>민준, 서연</textarea>
          </div>
          <div class="actions">
            <button type="submit" class="primary" data-testid="naming-submit">비교하기</button>
          </div>
        </form>
      </section>
      <div id="naming-result">${resultHtml}</div>`;

    renderShell(root, {
      title: '이름 후보 체커',
      eyebrow: 'web-lucky · 작명',
      showHome: true,
      onHome,
      bodyHtml: body,
      testId: 'naming-body',
    });

    root.querySelector('#naming-form')?.addEventListener('submit', (ev) => {
      ev.preventDefault();
      const form = ev.target as HTMLFormElement;
      const surname = (form.elements.namedItem('surname') as HTMLInputElement)
        .value;
      const raw = (form.elements.namedItem('candidates') as HTMLTextAreaElement)
        .value;
      const names = parseGivenNameCandidates(raw);
      const outcome = runNaming(surname, names);
      if (!outcome.ok) {
        resultHtml = `<div class="error-box" data-testid="error-box" role="alert">${escapeHtml(outcome.message)}</div>`;
      } else {
        const rows = outcome.candidates
          .map((c) => {
            const suri = `원${c.suri81.won.gilhyung}/형${c.suri81.hyeong.gilhyung}/이${c.suri81.yi.gilhyung}/정${c.suri81.jeong.gilhyung}`;
            return `<tr>
              <td>${escapeHtml(c.name)}</td>
              <td data-testid="score-${escapeHtml(c.name)}">${escapeHtml(c.totalScore)}</td>
              <td>${escapeHtml(c.strokes.join('-'))}</td>
              <td>${escapeHtml(c.balumOhaeng.join('·'))}</td>
              <td>${escapeHtml(suri)}</td>
            </tr>`;
          })
          .join('');
        resultHtml = `
          <section class="card" data-testid="naming-result-card">
            <h2>비교 결과 (점수 높은 순)</h2>
            ${outcome.truncated ? '<p class="help">후보는 6개까지만 반영했습니다.</p>' : ''}
            <div class="table-wrap">
              <table class="data-table" data-testid="naming-table">
                <thead>
                  <tr><th>이름</th><th>점수</th><th>획수</th><th>발음오행</th><th>81수리</th></tr>
                </thead>
                <tbody>${rows}</tbody>
              </table>
            </div>
          </section>`;
      }
      paint();
    });
  };

  paint();
}

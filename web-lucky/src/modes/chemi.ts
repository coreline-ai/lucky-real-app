import { renderShell } from '../app/shell';
import { runChemi, type ChemiPersonInput } from '../domain/chemi';
import type { Gender } from 'manseryeok-engine';

function parsePerson(
  form: HTMLFormElement,
  prefix: string,
): ChemiPersonInput | { error: string } {
  const dateVal = (form.elements.namedItem(`${prefix}Date`) as HTMLInputElement)
    .value;
  if (!dateVal) return { error: `${prefix === 'p1' ? '첫' : '두'} 번째 생일을 입력해 주세요.` };
  const [year, month, day] = dateVal.split('-').map(Number);
  const gender = (form.elements.namedItem(`${prefix}Gender`) as HTMLSelectElement)
    .value as Gender;
  const isLunar =
    (form.elements.namedItem(`${prefix}Cal`) as HTMLSelectElement).value ===
    'lunar';
  const isLeapMonth = (
    form.elements.namedItem(`${prefix}Leap`) as HTMLInputElement
  ).checked;
  const timeKnown = (form.elements.namedItem(`${prefix}TimeKnown`) as HTMLInputElement)
    .checked;
  let hour: number | null = null;
  let minute: number | null = null;
  if (timeKnown) {
    hour = Number(
      (form.elements.namedItem(`${prefix}Hour`) as HTMLInputElement).value,
    );
    minute = Number(
      (form.elements.namedItem(`${prefix}Minute`) as HTMLInputElement).value,
    );
    if (
      !Number.isInteger(hour) ||
      hour < 0 ||
      hour > 23 ||
      !Number.isInteger(minute) ||
      minute < 0 ||
      minute > 59
    ) {
      return { error: '출생 시·분을 확인해 주세요. (모름이면 체크 해제)' };
    }
  }
  return {
    year,
    month,
    day,
    gender,
    isLunar,
    isLeapMonth: isLunar ? isLeapMonth : false,
    hour,
    minute,
  };
}

function personFields(prefix: string, defaults: {
  date: string;
  gender: Gender;
}): string {
  return `
    <div class="card nested">
      <h3>${prefix === 'p1' ? '첫 번째 사람' : '두 번째 사람'}</h3>
      <div class="field">
        <label for="${prefix}Date">생년월일</label>
        <input id="${prefix}Date" name="${prefix}Date" type="date" required value="${defaults.date}" />
      </div>
      <div class="field-row">
        <div class="field">
          <label for="${prefix}Gender">성별</label>
          <select id="${prefix}Gender" name="${prefix}Gender">
            <option value="male" ${defaults.gender === 'male' ? 'selected' : ''}>남성</option>
            <option value="female" ${defaults.gender === 'female' ? 'selected' : ''}>여성</option>
          </select>
        </div>
        <div class="field">
          <label for="${prefix}Cal">달력</label>
          <select id="${prefix}Cal" name="${prefix}Cal">
            <option value="solar" selected>양력</option>
            <option value="lunar">음력</option>
          </select>
        </div>
      </div>
      <label class="checkbox-row">
        <input type="checkbox" name="${prefix}Leap" id="${prefix}Leap" disabled /> 음력 윤달
      </label>
      <label class="checkbox-row">
        <input type="checkbox" name="${prefix}TimeKnown" id="${prefix}TimeKnown" /> 출생 시각 알음
      </label>
      <div class="field-row time-row hidden" id="${prefix}TimeRow">
        <div class="field">
          <label for="${prefix}Hour">시</label>
          <input id="${prefix}Hour" name="${prefix}Hour" type="number" min="0" max="23" value="12" />
        </div>
        <div class="field">
          <label for="${prefix}Minute">분</label>
          <input id="${prefix}Minute" name="${prefix}Minute" type="number" min="0" max="59" value="0" />
        </div>
      </div>
    </div>`;
}

export function renderChemiMode(
  root: HTMLElement,
  onHome: () => void,
): void {
  let resultHtml = '';

  const paint = () => {
    const body = `
      <p class="help">점수는 관계의 “정답”이 아니라 가벼운 대화 소재입니다. 낮은 등급도 결함이 아니라 서로 다른 리듬으로 읽어 주세요.</p>
      <form id="chemi-form">
        ${personFields('p1', { date: '1990-03-15', gender: 'male' })}
        ${personFields('p2', { date: '1992-08-20', gender: 'female' })}
        <div class="actions">
          <button type="submit" class="primary" data-testid="chemi-submit">케미 보기</button>
        </div>
      </form>
      <div id="chemi-result">${resultHtml}</div>`;

    renderShell(root, {
      title: '우리 케미',
      eyebrow: 'web-lucky · 궁합',
      showHome: true,
      onHome,
      bodyHtml: body,
      testId: 'chemi-body',
    });

    const form = root.querySelector<HTMLFormElement>('#chemi-form')!;
    for (const prefix of ['p1', 'p2'] as const) {
      const cal = form.elements.namedItem(`${prefix}Cal`) as HTMLSelectElement;
      const leap = form.elements.namedItem(`${prefix}Leap`) as HTMLInputElement;
      const timeKnown = form.elements.namedItem(
        `${prefix}TimeKnown`,
      ) as HTMLInputElement;
      const timeRow = root.querySelector(`#${prefix}TimeRow`)!;
      const sync = () => {
        leap.disabled = cal.value !== 'lunar';
        if (cal.value !== 'lunar') leap.checked = false;
        timeRow.classList.toggle('hidden', !timeKnown.checked);
      };
      cal.addEventListener('change', sync);
      timeKnown.addEventListener('change', sync);
      sync();
    }

    form.addEventListener('submit', (ev) => {
      ev.preventDefault();
      const p1 = parsePerson(form, 'p1');
      if ('error' in p1) {
        resultHtml = `<div class="error-box" role="alert">${p1.error}</div>`;
        paint();
        return;
      }
      const p2 = parsePerson(form, 'p2');
      if ('error' in p2) {
        resultHtml = `<div class="error-box" role="alert">${p2.error}</div>`;
        paint();
        return;
      }
      const outcome = runChemi(p1, p2);
      if (!outcome.ok) {
        resultHtml = `<div class="error-box" data-testid="error-box" role="alert">${outcome.message}</div>`;
      } else {
        const r = outcome.result;
        const cats = r.categories
          .map(
            (c: { name: string; score: number; maxScore: number; description: string }) =>
              `<li><strong>${c.name}</strong> ${c.score}/${c.maxScore} — ${c.description}</li>`,
          )
          .join('');
        const advice = r.advice.map((a: string) => `<li>${a}</li>`).join('');
        resultHtml = `
          <section class="card" data-testid="chemi-result-card">
            <h2>결과</h2>
            <p class="score-line" data-testid="chemi-score"><span class="score-num">${r.totalScore}</span>점 · <span class="grade">${r.grade}</span>등급</p>
            <p>${r.summary}</p>
            <ul class="plain">${cats}</ul>
            <h3>조언</h3>
            <ul class="plain" data-testid="chemi-advice">${advice}</ul>
          </section>`;
      }
      paint();
      root.querySelector('#chemi-result')?.scrollIntoView({ behavior: 'smooth' });
    });
  };

  paint();
}

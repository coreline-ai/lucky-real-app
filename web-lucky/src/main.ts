import { type ModeId } from './app/constants';
import { getModeFromLocation, onRouteChange, setMode } from './app/router';
import { renderHome } from './modes/home';
import { renderIljinMode } from './modes/iljin';
import { renderChemiMode } from './modes/chemi';
import { renderNamingMode } from './modes/naming';
import { renderSolarTermsMode } from './modes/solar-terms';
import { renderTojeongMode } from './modes/tojeong';

const appEl = document.querySelector<HTMLDivElement>('#app');
if (!appEl) {
  throw new Error('#app missing');
}
const app: HTMLElement = appEl;

function goHome(): void {
  setMode(null);
  route();
}

function openMode(mode: ModeId): void {
  setMode(mode);
  route();
}

function route(): void {
  const mode = getModeFromLocation();
  if (mode == null) {
    renderHome(app, openMode);
    return;
  }
  switch (mode) {
    case 'iljin':
      renderIljinMode(app, goHome);
      break;
    case 'chemi':
      renderChemiMode(app, goHome);
      break;
    case 'naming':
      renderNamingMode(app, goHome);
      break;
    case 'solar-terms':
      renderSolarTermsMode(app, goHome);
      break;
    case 'tojeong':
      renderTojeongMode(app, goHome);
      break;
    default:
      goHome();
  }
}

onRouteChange(route);
route();

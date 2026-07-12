import { type ModeId } from './app/constants';
import { getModeFromLocation, onRouteChange, setMode } from './app/router';

type ModeRenderer = (root: HTMLElement, onHome: () => void) => void;

const modeRenderers: Record<ModeId, () => Promise<ModeRenderer>> = {
  iljin: async () => (await import('./modes/iljin')).renderIljinMode,
  chemi: async () => (await import('./modes/chemi')).renderChemiMode,
  naming: async () => (await import('./modes/naming')).renderNamingMode,
  'solar-terms': async () =>
    (await import('./modes/solar-terms')).renderSolarTermsMode,
  tojeong: async () => (await import('./modes/tojeong')).renderTojeongMode,
};

const appEl = document.querySelector<HTMLDivElement>('#app');
if (!appEl) {
  throw new Error('#app missing');
}
const app: HTMLElement = appEl;
let routeSequence = 0;

function goHome(): void {
  setMode(null);
  void route();
}

function openMode(mode: ModeId): void {
  setMode(mode);
  void route();
}

async function route(): Promise<void> {
  const sequence = ++routeSequence;
  const mode = getModeFromLocation();
  if (mode == null) {
    const { renderHome } = await import('./modes/home');
    if (sequence !== routeSequence) return;
    renderHome(app, openMode);
    return;
  }
  const renderMode = await modeRenderers[mode]();
  if (sequence !== routeSequence) return;
  renderMode(app, goHome);
}

onRouteChange(() => {
  void route();
});
void route();

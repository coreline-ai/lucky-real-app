import { isModeId, type ModeId } from './constants';

export function getModeFromLocation(
  search: string = window.location.search,
): ModeId | null {
  const params = new URLSearchParams(search);
  const mode = params.get('mode');
  return isModeId(mode) ? mode : null;
}

export function setMode(mode: ModeId | null, replace = false): void {
  const url = new URL(window.location.href);
  if (mode == null) {
    url.searchParams.delete('mode');
  } else {
    url.searchParams.set('mode', mode);
  }
  const next = `${url.pathname}${url.search}${url.hash}`;
  if (replace) {
    window.history.replaceState({ mode }, '', next);
  } else {
    window.history.pushState({ mode }, '', next);
  }
}

export function onRouteChange(handler: () => void): () => void {
  const fn = () => handler();
  window.addEventListener('popstate', fn);
  return () => window.removeEventListener('popstate', fn);
}

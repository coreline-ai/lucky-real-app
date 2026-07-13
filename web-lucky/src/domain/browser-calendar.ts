import { createBrowserShardedCalendar } from 'manseryeok-engine/engine/browser';

export type BrowserCalendar = ReturnType<typeof createBrowserShardedCalendar>;

const basePath = `${import.meta.env.BASE_URL.replace(/\/$/, '')}/manseryeok-data`;
let sharedCalendar: BrowserCalendar | null = null;

/** Shared browser-only client. The engine owns request de-duplication and memory caching. */
export function getBrowserCalendar(): BrowserCalendar {
  if (!sharedCalendar) {
    sharedCalendar = createBrowserShardedCalendar({ baseUrl: basePath });
  }
  return sharedCalendar;
}

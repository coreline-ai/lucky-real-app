import { McpClientProvider } from './mcp-client';
import type { BirthFormInput, GameReadings, SajuProvider } from './types';
import { ProviderError } from './types';

function envFlag(name: 'VITE_USE_MCP' | 'VITE_MCP_STRICT', fallback: boolean): boolean {
  const value = import.meta.env[name];
  if (value === undefined || value === '') return fallback;
  return value.toLowerCase() === 'true';
}

async function createLocalProvider(): Promise<SajuProvider> {
  const { LocalEngineProvider } = await import('./local-engine');
  return new LocalEngineProvider();
}

function createMcpProvider(): SajuProvider {
  return new McpClientProvider({ baseUrl: import.meta.env.VITE_MCP_URL || '/mcp' });
}

async function readBoth(provider: SajuProvider, input: BirthFormInput): Promise<GameReadings> {
  const [player, boss] = await Promise.all([
    provider.getPlayerDayPillar(input),
    provider.getTodayIljin(),
  ]);
  return { player, boss };
}

export async function resolveGameReadings(input: BirthFormInput): Promise<GameReadings> {
  const useMcp = envFlag('VITE_USE_MCP', true);
  const strict = envFlag('VITE_MCP_STRICT', false);

  if (!useMcp) {
    return readBoth(await createLocalProvider(), input);
  }

  try {
    return await readBoth(createMcpProvider(), input);
  } catch (error) {
    if (strict) throw error;
    const localResult = await readBoth(await createLocalProvider(), input);
    return {
      ...localResult,
      fallbackReason: formatProviderError(error),
    };
  }
}

export function formatProviderError(error: unknown): string {
  if (error instanceof ProviderError) return `${error.code}: ${error.message}`;
  if (error instanceof Error) return error.message;
  return String(error);
}

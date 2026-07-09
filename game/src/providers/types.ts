export type Gender = 'male' | 'female';
export type PillarSource = 'mcp' | 'local' | 'mcp-bridge';

export interface BirthFormInput {
  year: number;
  month: number;
  day: number;
  hour: number | null;
  minute: number | null;
  gender: Gender;
}

export interface DayPillar {
  gan: string;
  ji: string;
  ganji: string;
}

export interface PillarSourceMeta {
  source: PillarSource;
  tool?: 'saju_palja' | 'calendar_day_info';
  engineVersion?: string;
  ruleVersion?: string;
  note?: string;
}

export interface PillarReading {
  pillar: DayPillar;
  meta: PillarSourceMeta;
}

export interface GameReadings {
  player: PillarReading;
  boss: PillarReading;
  fallbackReason?: string;
}

export interface SajuProvider {
  getPlayerDayPillar(input: BirthFormInput): Promise<PillarReading>;
  getTodayIljin(): Promise<PillarReading>;
}

export class ProviderError extends Error {
  readonly code: string;
  readonly source: PillarSource | 'mcp-http';
  readonly details?: unknown;

  constructor(message: string, options: { code?: string; source?: PillarSource | 'mcp-http'; details?: unknown } = {}) {
    super(message);
    this.name = 'ProviderError';
    this.code = options.code ?? 'PROVIDER_ERROR';
    this.source = options.source ?? 'mcp-http';
    this.details = options.details;
  }
}

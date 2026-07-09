import { ManseryeokEngine } from '@/engine/core/manseryeok-engine';

import { kstToday } from '../domain/kst';
import type { BirthFormInput, DayPillar, PillarReading, SajuProvider } from './types';

const LOCAL_META = {
  source: 'local' as const,
  engineVersion: '0.1.0',
  ruleVersion: 'krlt-yaja-2026.07',
};

function toDayPillar(context: { ganji: { day: { gan: string; ji: string } } }): DayPillar {
  const gan = context.ganji.day.gan;
  const ji = context.ganji.day.ji;
  return { gan, ji, ganji: `${gan}${ji}` };
}

export class LocalEngineProvider implements SajuProvider {
  async getPlayerDayPillar(input: BirthFormInput): Promise<PillarReading> {
    const context = ManseryeokEngine.getSolarContext({
      year: input.year,
      month: input.month,
      day: input.day,
      ...(input.hour !== null ? { hour: input.hour } : {}),
      ...(input.hour !== null && input.minute !== null ? { minute: input.minute } : {}),
    });

    return { pillar: toDayPillar(context), meta: { ...LOCAL_META } };
  }

  async getTodayIljin(): Promise<PillarReading> {
    const today = kstToday();
    const context = ManseryeokEngine.getSolarContext(today);
    return { pillar: toDayPillar(context), meta: { ...LOCAL_META } };
  }
}

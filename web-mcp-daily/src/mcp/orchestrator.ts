import type { BirthInput } from '../domain/briefing';
import type { KstDateParts } from '../domain/kst';
import { McpClient, type McpToolResult } from './client';

export type SajuSection =
  | 'sipsin'
  | 'jijanggan'
  | 'unsung'
  | 'daeun'
  | 'un'
  | 'sinsal'
  | 'relations'
  | 'gyeokguk'
  | 'yongsin';

export interface CalendarMonthArgs {
  year: number;
  month: number;
  compact: boolean;
}

export class FortuneMcp {
  constructor(private readonly client: McpClient) {}

  getTraces() {
    return this.client.getTraces();
  }

  async callCalendarDay(date: KstDateParts): Promise<McpToolResult> {
    return (await this.client.callTool('calendar_day_info', {
      year: date.year,
      month: date.month,
      day: date.day,
    })).result;
  }

  async callCalendarMonth(args: CalendarMonthArgs): Promise<McpToolResult> {
    return (await this.client.callTool('calendar_month', { ...args })).result;
  }

  async callSajuPalja(birth: BirthInput): Promise<McpToolResult> {
    return (await this.client.callTool('saju_palja', { birth })).result;
  }

  async callSajuFullReading(birth: BirthInput, include: SajuSection[]): Promise<McpToolResult> {
    return (await this.client.callTool('saju_full_reading', { birth, include })).result;
  }

  async callTojeongYearly(birth: BirthInput, targetYear: number): Promise<McpToolResult> {
    return (await this.client.callTool('tojeong_yearly', { birth, targetYear })).result;
  }

  async callSajuDaeun(birth: BirthInput, count = 8): Promise<McpToolResult> {
    return (await this.client.callTool('saju_daeun', { birth, count })).result;
  }
}

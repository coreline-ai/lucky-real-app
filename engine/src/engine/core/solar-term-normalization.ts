const SOLAR_TERM_NAME_MAP: Record<string, string> = {
  冬至: '동지',
  小寒: '소한',
  大寒: '대한',
  立春: '입춘',
  雨水: '우수',
  惊蛰: '경칩',
  驚蟄: '경칩',
  春分: '춘분',
  清明: '청명',
  淸明: '청명',
  谷雨: '곡우',
  穀雨: '곡우',
  立夏: '입하',
  小满: '소만',
  小滿: '소만',
  芒种: '망종',
  芒種: '망종',
  夏至: '하지',
  小暑: '소서',
  大暑: '대서',
  立秋: '입추',
  处暑: '처서',
  處暑: '처서',
  白露: '백로',
  秋分: '추분',
  寒露: '한로',
  霜降: '상강',
  立冬: '입동',
  小雪: '소설',
  大雪: '대설',
  DONG_ZHI: '동지',
  XIAO_HAN: '소한',
  DA_HAN: '대한',
  LI_CHUN: '입춘',
  YU_SHUI: '우수',
  JING_ZHE: '경칩',
  CHUN_FEN: '춘분',
  QING_MING: '청명',
  GU_YU: '곡우',
  LI_XIA: '입하',
  XIAO_MAN: '소만',
  MANG_ZHONG: '망종',
  XIA_ZHI: '하지',
  XIAO_SHU: '소서',
  DA_SHU: '대서',
  LI_QIU: '입추',
  CHU_SHU: '처서',
  BAI_LU: '백로',
  QIU_FEN: '추분',
  HAN_LU: '한로',
  SHUANG_JIANG: '상강',
  LI_DONG: '입동',
  XIAO_XUE: '소설',
  DA_XUE: '대설',
};

const SOURCE_TO_KST_OFFSET_HOURS = 1;

export interface SolarTermInfo {
  sourceName: string;
  koreanName: string;
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
  julianDay: number;
}

export function normalizeSolarTermName(name: string): string {
  return SOLAR_TERM_NAME_MAP[name] ?? name;
}

export function normalizeSolarTermToKst(term: SolarTermInfo): SolarTermInfo {
  const shifted = new Date(Date.UTC(
    term.year,
    term.month - 1,
    term.day,
    term.hour + SOURCE_TO_KST_OFFSET_HOURS,
    term.minute,
    term.second,
  ));

  return {
    ...term,
    year: shifted.getUTCFullYear(),
    month: shifted.getUTCMonth() + 1,
    day: shifted.getUTCDate(),
    hour: shifted.getUTCHours(),
    minute: shifted.getUTCMinutes(),
    second: shifted.getUTCSeconds(),
    julianDay: term.julianDay + SOURCE_TO_KST_OFFSET_HOURS / 24,
  };
}

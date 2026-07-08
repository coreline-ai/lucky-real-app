import { describe, expect, it } from 'vitest';
import type { Gyeokguk, Palja } from '@/engine/types';
import {
  JIJANGGAN_TABLE,
  calculateJijangganSipsin,
  calculateSipsin,
  extractJijanggan,
} from '@/engine/saju/sipsin';
import { determineYongsin } from '@/engine/saju/yongsin';

const EXPECTED_BONGI: Record<string, string> = {
  '子': '癸',
  '丑': '己',
  '寅': '甲',
  '卯': '乙',
  '辰': '戊',
  '巳': '丙',
  '午': '丁',
  '未': '己',
  '申': '庚',
  '酉': '辛',
  '戌': '戊',
  '亥': '壬',
};
const DUMMY_GYEOKGUK: Gyeokguk = {
  name: '테스트격',
  hanja: '',
  description: '',
};


const paljaWithYearJi = (yearJi: string): Palja => ({
  yearGan: '',
  yearJi,
  monthGan: '',
  monthJi: '卯',
  dayGan: '甲',
  dayJi: '寅',
  hourGan: '',
  hourJi: '亥',
});

describe('지장간 본기 인덱스 규약', () => {
  it('12지지의 본기를 첫 번째 지장간으로 둔다', () => {
    for (const [ji, bongi] of Object.entries(EXPECTED_BONGI)) {
      expect(JIJANGGAN_TABLE[ji]?.[0]).toBe(bongi);
    }
  });

  it('子지는 癸를 본기로 사용해 지지 십신을 판별한다', () => {
    const palja = paljaWithYearJi('子');

    expect(JIJANGGAN_TABLE['子']).toEqual(['癸', '壬']);
    expect(extractJijanggan(palja).yearJi).toEqual(['癸', '壬']);
    expect(calculateSipsin(palja).yearJi).toBe('정인');
    expect(calculateJijangganSipsin(palja).yearJi.bongi).toBe('정인');
  });
  it('용신 강약 산정에서도 첫 번째 지장간에 본기 가중치를 부여한다', () => {
    const palja: Palja = {
      yearGan: '',
      yearJi: '寅',
      monthGan: '',
      monthJi: '申',
      dayGan: '甲',
      dayJi: '酉',
      hourGan: '',
      hourJi: '亥',
    };

    const yongsin = determineYongsin(palja, DUMMY_GYEOKGUK, 'gangyak');

    expect(yongsin.reasoning).toContain('점수 2.5');
    expect(yongsin.reasoning).toContain('득지:O');
  });
});

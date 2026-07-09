// MCP 리소스: 서버 메타 1종 + 엔진 문서 7종 (dev-plan P4)
// D12: 문서는 ../../engine 상대경로가 아니라 설치된 패키지에서 해석한다.
//      (engine package.json의 files에 docs 포함 — 배포 형태와 무관하게 안전)
import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { createRequire } from 'node:module';
import path from 'node:path';

import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';

import { ENGINE_META, SERVER_NAME, SERVER_VERSION } from '../meta.js';
import { QIMEN_SCHOOLS, SAJU_SUB_SCHOOLS, ZIWEI_SCHOOLS } from '../schemas/output.js';

const require = createRequire(import.meta.url);

/**
 * 툴 카탈로그 정적 사본 (그룹별).
 * tools/list와의 드리프트는 tests/resources-prompts.test.ts가 감시한다.
 */
export const TOOL_CATALOG: Record<string, string[]> = {
  calendar: ['calendar_day_info', 'calendar_month', 'date_convert', 'solar_terms', 'korean_legal_time'],
  saju: ['saju_full_reading', 'saju_palja', 'saju_daeun'],
  compatibility: ['compatibility_score'],
  tojeong: ['tojeong_yearly'],
  charts: ['ziwei_chart', 'qimen_chart', 'daeyukim_chart', 'guseong_chart'],
  numeric: ['harak_reading', 'daejeong_reading', 'hongyeon_reading', 'maehwa_divination'],
  naming: ['naming_analyze', 'ganji_info'],
};

/** 문서 slug → 한국어 제목 (등록 시점의 실제 파일 목록 기준으로 노출) */
const DOC_TITLES: Record<string, string> = {
  'korean-legal-time-policy': '한국 법정시 정책 (표준시·DST 이력)',
  'solar-terms': '절기 데이터 산출·검증',
  'expert-reference-fixtures': '전문가 대조 fixture 규칙',
  'expert-reference-intake': '전문가 검토 절차',
  'external-provider-intake': '외부 만세력 provider 대조 절차',
  'reference-provider-register': '참조 provider 등록부',
  'professional-readiness': '전문가용 준비도 체크',
};

function buildMetaDocument(): Record<string, unknown> {
  return {
    server: { name: SERVER_NAME, version: SERVER_VERSION },
    engine: { ...ENGINE_META },
    timezone: '모든 날짜·시각은 Asia/Seoul(KST) 고정',
    supportedRange: {
      calendar: '1899-01-01 ~ 2101-12-31 (달력·양음력 변환·절기)',
      palja: '1908-04-01 ~ 2101-12-31 (팔자 기반 계산 — 한국 법정시 정책, D8)',
    },
    schools: {
      sajuYongsin: [...SAJU_SUB_SCHOOLS],
      ziwei: [...ZIWEI_SCHOOLS],
      qimen: [...QIMEN_SCHOOLS],
      namingStrokes: ['kangxi', 'modern'],
      midnightMode: ['yaja', 'joja'],
    },
    errorCodes: [
      'MANSERYEOK_RANGE_ERROR',
      'MANSERYEOK_DATA_ERROR',
      'AMBIGUOUS_CIVIL_TIME',
      'NONEXISTENT_CIVIL_TIME',
      'MANSERYEOK_POLICY_ERROR',
      'INVALID_INPUT',
      'INTERNAL_ERROR',
    ],
    tools: TOOL_CATALOG,
    notice:
      '오락·자기성찰 목적의 계산 서버입니다. 의료·투자·법률·재무 판단의 근거로 사용할 수 없으며, 해석 문구 작성은 호출 측 책임입니다.',
  };
}

function resolveDocsDir(): string | null {
  try {
    const pkgPath = require.resolve('manseryeok-engine/package.json');
    const docsDir = path.join(path.dirname(pkgPath), 'docs', 'engine');
    return existsSync(docsDir) ? docsDir : null;
  } catch {
    return null;
  }
}

export function registerResources(server: McpServer): void {
  server.registerResource(
    'meta',
    'manseryeok://meta',
    {
      title: '서버·엔진 메타 정보',
      description: '엔진 버전, 규칙 버전, 지원 날짜 범위, 학파 목록, 오류 코드, 툴 카탈로그 (JSON)',
      mimeType: 'application/json',
    },
    async (uri) => ({
      contents: [
        { uri: uri.href, mimeType: 'application/json', text: JSON.stringify(buildMetaDocument(), null, 2) },
      ],
    }),
  );

  const docsDir = resolveDocsDir();
  if (!docsDir) {
    // 문서 미동봉 환경 — meta만 노출 (파일 접근 실패 시 목록 제외 정책)
    return;
  }
  for (const file of readdirSync(docsDir).filter((f) => f.endsWith('.md')).sort()) {
    const slug = file.replace(/\.md$/, '');
    const filePath = path.join(docsDir, file);
    try {
      readFileSync(filePath, 'utf8'); // 등록 시점 가독성 확인 — 실패 시 목록에서 제외
    } catch {
      continue;
    }
    server.registerResource(
      `docs-${slug}`,
      `manseryeok://docs/${slug}`,
      {
        title: DOC_TITLES[slug] ?? slug,
        description: `manseryeok-engine 문서: ${DOC_TITLES[slug] ?? slug}`,
        mimeType: 'text/markdown',
      },
      async (uri) => ({
        contents: [{ uri: uri.href, mimeType: 'text/markdown', text: readFileSync(filePath, 'utf8') }],
      }),
    );
  }
}

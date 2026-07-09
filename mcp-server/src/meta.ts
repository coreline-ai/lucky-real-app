// 서버·엔진 버전 메타 (dev-plan D7)
// - engineVersion: 설치된 manseryeok-engine 패키지에서 동적 로드
// - ruleVersion: realapp/docs/09-engine-gateway-contract.md 계약 표기와 동일한 상수
//   (한국 법정시 정책 + 야자시 기본 + 절기 월주. 엔진은 이 값을 export하지 않는다)
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

const enginePkg = require('manseryeok-engine/package.json') as { version: string };
const ownPkg = require('../package.json') as { name: string; version: string };

export const SERVER_NAME = 'manseryeok';
export const SERVER_VERSION = ownPkg.version;

/** 모든 툴 응답 structuredContent에 포함되는 공용 메타 */
export const ENGINE_META = {
  engineVersion: enginePkg.version,
  ruleVersion: 'krlt-yaja-2026.07',
} as const;

export type EngineMeta = typeof ENGINE_META;

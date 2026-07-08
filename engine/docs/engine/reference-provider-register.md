# Reference Provider Register

This register separates automated provider agreement from expert-reviewed commercial acceptance.

The machine-readable registry lives in `tests/fixtures/reference-providers.json`. Automated fixture provider names in `tests/fixtures/manseryeok-golden.json` must be listed there as active automated providers. Commercial app surfaces such as Forceteller/Posteller stay under manual benchmarks and must not be counted as automated providers.

## Public Automated Providers

These sources are useful for regression tests and broad mismatch detection, but they are not a substitute for practicing expert review.

| Source | Type | Current Use | Notes |
| --- | --- | --- | --- |
| `manseryeok` | npm/GitHub package | Solar-term range verification and golden fixture cross-checks | KASI-based public library. Used in `tests/engine/solar-terms-provider-range.test.ts` and `tests/engine/external-provider-comparison.test.ts`. |
| `@fullstackfamily/manseryeok` | npm package | Golden fixture cross-checks | Second public implementation used to catch provider-specific drift. |
| `ssaju` | npm/GitHub package | Golden fixture cross-checks | MIT, zero-dependency public saju/manseryeok implementation. Used as a third automated provider in `tests/engine/external-provider-comparison.test.ts`. |
| `urstory/manseryeok-js` | GitHub project | Candidate automated/manual comparison source | Pure JavaScript Korean lunar calendar implementation. Review license, supported year range, and API shape before wiring into CI. |
| `rath/orrery` | GitHub project | Candidate manual/browser comparison source | Browser-side saju/ziwei/birth-chart calculator. Useful as a comparison surface only after license/provenance review. |
| Ablecity manseryeok API | HTTP API candidate | Candidate external API integration | Official docs are currently available and describe a bearer-token API with city, calendar, and midnightType options. Keep it as `candidate` until a test key, response-field mapping, and adapter test are available. |
| `wangta69/laravel-fortune` | GitHub project | Candidate manual comparison source | Project states it is used in production. Its README examples can be used as public examples, not as expert acceptance evidence. |
| `oops-manse` / "진짜만세력" derivatives | GitHub project family | Research only | License and provenance must be reviewed before use. Do not copy code or data into this repository without explicit license approval. |

## Not Found As Public API

No public Forceteller/Posteller manseryeok engine API or open-source repository has been verified yet.

| Source | Date checked | Status | Next action |
| --- | --- | --- | --- |
| Forceteller/Posteller web and app surfaces | 2026-06-29 | Commercial benchmark only; official service/app pages verified, but no public engine API or OSS package registered | Official surfaces describe professional-facing manseryeok features, including regional minute-level time correction, yaja time, and true solar time options. Treat screenshots/manual exports as external app evidence only; do not treat the service as an API provider unless an official endpoint contract is supplied. The machine-readable registry marks this benchmark as `manual-capture-only`, `publicApiStatus: not-verified`, `openSourceStatus: not-verified`, and `automationEligibility: blocked-until-official-api-or-oss`. |

The automated provider report can be generated with:

```bash
npm run provider:report -- ../../outputs/provider-comparison-report.md
npm run provider:manual-package -- ../../outputs/manual-benchmark-package
```

`npm run professional:status` also checks that the automated public-provider comparison set still contains at least 3 declared providers and 3 comparable fixture cases. This protects the public cross-check layer from being accidentally removed while expert evidence is still being collected.
`provider:manual-package` creates a capture packet for manual-only commercial benchmarks and keeps them outside the automated provider set.

Manual app/API captures should include a capture file and SHA-256 hash in the provider response JSON. For `manual-export` and `app-transcription` provider types, `provider:csv-to-json` requires `--require-evidence`. For Forceteller/Posteller, use only manual screenshots, exports, or app-screen transcripts until an official API/source contract is supplied. Convert a filled CSV with evidence verification:

```bash
npm run provider:csv-to-json -- ../../outputs/provider-response.csv ../../outputs/provider-response.json --evidence-dir ../../outputs/provider-evidence --require-evidence
npm run provider:evidence -- ../../outputs/provider-response.json --evidence-dir ../../outputs/provider-evidence --require-evidence --report ../../outputs/provider-evidence-report.md
```

If a Forceteller/Posteller provider later becomes available, it should be added to that report through a small adapter test rather than by copying service code or private data.

## Checked URLs

- Forceteller official manseryeok surface: https://pro.forceteller.com/
- Forceteller app surface: https://pro.forceteller.com/app/
- Forceteller Google Play listing: https://play.google.com/store/apps/details?id=com.forceteller.sajuAlmanac
- `manseryeok` public package/repository: https://npmjs.com/package/manseryeok, https://github.com/yhj1024/manseryeok
- `@fullstackfamily/manseryeok` public package mirror: https://classic.yarnpkg.com/en/package/%40fullstackfamily/manseryeok
- `ssaju` public package/repository: https://npmjs.com/package/ssaju, https://github.com/golbin/ssaju
- Ablecity API landing page: https://ablecity.kr/api/
- Ablecity fortune endpoint candidate: https://api.ablecity.kr/api/v2/saju/fortune

## Expert Acceptance Sources

Expert acceptance must come from 5-10 cases verified by practicing saju/manseryeok professionals, with at least 2 distinct reviewers and 2 distinct reference tools represented in the promoted fixture. Each accepted case belongs in `tests/fixtures/expert-reference-golden.json` and must include:

- reviewer name or stable reviewer id
- reference tool, workbook, or commercial manseryeok used
- verification date
- exact calendar input and birth time
- day-boundary rule (`standard`, `early-jasi`, or `split-jasi`)
- true-solar-time use and longitude, when applicable
- expected year, month, day, and hour pillars
- reference capture file names and SHA-256 hashes for accepted cases
- optional stable reference URLs

Automated provider values must remain in `tests/fixtures/manseryeok-golden.json`; expert-reviewed values must remain in `tests/fixtures/expert-reference-golden.json`.

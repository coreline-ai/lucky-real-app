# External Provider Intake

Use this workflow when comparing Myunglab against a public API, a commercial manseryeok app export, or a manually transcribed provider result.

External provider agreement is regression evidence only. It does not replace the 5-10 expert-reviewed cases required for professional sale readiness.

## Generate A Response Template

```bash
npm run provider:response-template -- ../../outputs/external-provider-response-template.json
npm run provider:response-csv -- ../../outputs/external-provider-response.csv
npm run provider:manual-package -- ../../outputs/manual-benchmark-package
```

The template is generated from `tests/fixtures/expert-review-candidates.json`, so the same boundary cases can be checked by an API, an app, and a practicing expert.
Use `provider:manual-package` for manual-only commercial benchmarks such as Forceteller/Posteller; it writes a CSV, JSON template, metadata snapshot, README, and evidence directory.

## Fill Provider Results

If results are captured in CSV, keep screenshots, exports, or app-screen transcripts in an evidence directory and convert them to JSON with evidence verification:

```bash
npm run evidence:hashes -- ../../outputs/external-provider-evidence ../../outputs/external-provider-evidence-hashes.csv
npm run evidence:fill-csv -- ../../outputs/external-provider-response.csv ../../outputs/external-provider-response.with-hashes.csv --evidence-dir ../../outputs/external-provider-evidence
npm run provider:csv-to-json -- ../../outputs/external-provider-response.with-hashes.csv tests/fixtures/external-provider-responses/<provider-name>-YYYY-MM-DD.json --evidence-dir ../../outputs/external-provider-evidence --require-evidence
```

Copy or write the completed JSON into:

```text
tests/fixtures/external-provider-responses/<provider-name>-YYYY-MM-DD.json
```

Required provider metadata:

- `provider.name`
- `provider.type`: `http-api`, `manual-export`, or `app-transcription`
- `provider.url`, when available
- `provider.capturedAt` in `YYYY-MM-DD`

For each case, fill `providerExpected` with the provider's returned values:

- `solar`, for lunar input conversion checks
- `yearPillar`
- `monthPillar`
- `dayPillar`
- `hourPillar`

Use Hanja pillars such as `甲子`; do not use Hangul labels or combined descriptions.

For each supplied provider result, fill evidence fields:

- `providerCaptureFile`: relative file name under the evidence directory
- `providerCaptureSha256`: SHA-256 hash of the capture/export file
- `providerCaseUrl`: optional source URL, app deep link, or shared export URL

The converter always requires `--require-evidence` for `manual-export` and `app-transcription` provider types. This prevents app or screen-transcribed values from becoming fixtures unless every supplied value is tied to a capture file and SHA-256 hash.
Use `external-provider-evidence-hashes.csv` when you need to inspect hashes manually. Prefer `evidence:fill-csv` for CSV responses: it fills blank `providerCaptureSha256` values from `providerCaptureFile` and fails if an existing hash does not match the evidence file.
The converter also rejects supplied provider values while collection placeholders such as `provider-a` or `YYYY-MM-DD` remain in the provider metadata.

## Verify

```bash
npm run provider:evidence -- tests/fixtures/external-provider-responses/<provider-name>-YYYY-MM-DD.json --evidence-dir ../../outputs/external-provider-evidence --require-evidence --report ../../outputs/external-provider-evidence.md
npm run provider:report -- ../../outputs/provider-comparison-report.md
npm run test:manseryeok
```

The evidence command verifies that every capture path stays inside the evidence directory and that every declared SHA-256 hash matches the actual file. The test `tests/engine/external-provider-response-fixtures.test.ts` validates the response schema and compares every supplied provider value against the current Myunglab engine.

## Provider Status

- `manseryeok`, `@fullstackfamily/manseryeok`, and `ssaju` are already automated package comparisons.
- Forceteller/Posteller is registered as `manual-capture-only`: current checks have not verified a public engine API or open-source engine repository. Use screenshots, exports, or app-screen transcripts with `providerCaptureFile` and `providerCaptureSha256`; do not add it to automated fixture provider names until an official API/source contract is supplied.
- Ablecity is registered as a candidate HTTP API provider. Its public docs describe a bearer-token fortune endpoint, but it must not be wired into CI or counted as an automated provider until a test key is available, response fields are mapped to the fixture schema, and a dedicated adapter test is committed.

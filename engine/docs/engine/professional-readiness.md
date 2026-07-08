# Professional Sale Readiness Gate

Use this gate before claiming that the manseryeok engine is ready for paid professional sale.

```bash
npm run professional:status
```

`professional:status` prints every readiness check and exits successfully even when a check fails. It is useful during development.

Generate a requirement-by-requirement audit of the active professional-sale goal with:

```bash
npm run professional:audit -- ../../outputs/professional-goal-audit.md
```

Generate the shareable readiness dossier, including the latest collection gate snapshot, with:

```bash
npm run expert:collection-status -- --report ../../outputs/expert-collection-status.md
npm run professional:dossier -- ../../outputs/professional-readiness-dossier.md
```

Use this report to see the missing expert focus areas and recommended candidate rows:

```bash
npm run expert:coverage -- ../../outputs/expert-coverage-report.md
npm run expert:priority-sheet -- ../../outputs/priority-review-candidates.md
npm run expert:priority-template -- ../../outputs/priority-review-response-template.json
npm run expert:priority-csv -- ../../outputs/priority-review-response.csv
```

```bash
npm run professional:ready
```

`professional:ready` runs the same checks but exits non-zero when any requirement is missing. It is the release gate.

## Required Checks

- 5-10 accepted expert reference cases in `tests/fixtures/expert-reference-golden.json`
- at least 5 distinct accepted expert focus areas in `requiredCoverage.focusAreas`
- at least 2 distinct expert reviewers and 2 distinct reference tools in accepted fixture sources
- accepted fixture sources must use independent reference tools, not Myunglab or `engineDerived` as the reference
- every accepted expert case includes reference capture file names and SHA-256 evidence metadata
- every accepted expert case includes reviewer credential evidence in `source.reviewerEvidence`
- every accepted expert capture file exists and matches the declared SHA-256 hash
- 10 candidate cases retained in `tests/fixtures/expert-review-candidates.json`
- `npm audit --json` reports 0 total vulnerabilities, and `npm audit --audit-level=moderate` still passes
- `npm run type-check`
- `npm run lint`
- `npm run test:manseryeok`
- `npm run test:api-contracts`
- `npm run test:expert-reference`
- `npm run expert:verify-package -- ../../outputs/expert-review-package`
- `npm run expert:collection-status -- --report ../../outputs/expert-collection-status.md`
- `npm run build`

The gate must fail while accepted expert reference cases are missing. This prevents public or sales copy from claiming professional verification before the evidence exists.

Accepted expert evidence files are verified from `../../outputs/expert-review-evidence` by default. Set `MYUNGLAB_EXPERT_EVIDENCE_DIR` when the capture files live elsewhere:

```bash
MYUNGLAB_EXPERT_EVIDENCE_DIR=../../outputs/expert-review-evidence npm run professional:ready
```

When reviewer responses are available, prefer the release-candidate wrapper before the readiness gate. It runs inbox conversion, inspection, evidence verification, consensus promotion, fixture tests, and readiness reporting in one ordered path:

```bash
npm run expert:release-preflight -- --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-package/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-package/expert-review-tracker.synced.csv --tracker-status consensus-ready --min-reviewers 2 --min-reference-tools 2 --report ../../outputs/expert-release-preflight-summary.md
npm run expert:release-candidate -- --write --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-package/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-package/expert-review-tracker.synced.csv --tracker-status consensus-ready --min-reviewers 2 --min-reference-tools 2 --report ../../outputs/expert-release-candidate-summary.md
npm run professional:ready
```

The release summary must say `Validation scope: full professional-sale gate` before it can support a professional-sale claim. Any report generated with `--metadata-only`, `--skip-tests`, or preflight mode is intentionally labeled as limited validation and is not enough for sale readiness.

You can also run the non-writing preflight by itself while collecting or correcting evidence:

```bash
npm run expert:release-preflight -- --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-package/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-package/expert-review-tracker.synced.csv --report ../../outputs/expert-release-preflight-summary.md
```

When preflight passes, use the release-candidate wrapper to run the full write path in order:

```bash
npm run expert:release-candidate -- --write --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-package/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-package/expert-review-tracker.synced.csv --report ../../outputs/expert-release-candidate-summary.md
```

The wrapper refuses to run unless either `--preflight` or `--write` is present. Write mode can promote verified consensus cases into `tests/fixtures/expert-reference-golden.json`.

If a write-mode release must be reverted, copy the exact `Fixture restore command` from `../../outputs/expert-release-candidate-summary.md`. It uses:

```bash
npm run expert:restore-fixture -- <fixture-backup.json> --fixture tests/fixtures/expert-reference-golden.json --expected-sha <backup-sha256>
```

The restore command verifies the backup SHA-256 and creates a `.pre-restore.bak` copy of the current fixture before replacing it.

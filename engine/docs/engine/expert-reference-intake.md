# Expert Reference Intake

Use this checklist when asking a practicing saju/manseryeok professional to verify commercial acceptance cases.

Start from `tests/fixtures/expert-review-candidates.json`. It contains 10 engine-derived candidate cases designed to cover boundary behavior. These are not accepted expert evidence until a reviewer independently confirms or corrects the pillars.

Generate a reviewer-facing Markdown sheet with:

```bash
npm run expert:review-sheet -- ../../outputs/expert-review-candidates.md
```

Generate a structured response template for the reviewer with:

```bash
npm run expert:response-template -- ../../outputs/expert-review-response-template.json
```

Track reviewer outreach and response file status with:

```bash
npm run expert:tracker -- ../../outputs/expert-review-tracker.csv
npm run expert:tracker-sync -- ../../outputs/expert-review-tracker.csv ../../outputs/priority-review-response.json --out ../../outputs/expert-review-tracker.synced.csv
npm run expert:tracker-summary -- ../../outputs/expert-review-tracker.synced.csv --report ../../outputs/expert-review-tracker-summary.md
npm run expert:collection-status -- --report ../../outputs/expert-collection-status.md
```

Generate the shortest current priority review sheet/template with:

```bash
npm run expert:priority-sheet -- ../../outputs/priority-review-candidates.md
npm run expert:priority-template -- ../../outputs/priority-review-response-template.json
npm run expert:priority-csv -- ../../outputs/priority-review-response.csv
```

Or generate a complete reviewer package with:

```bash
npm run expert:package -- ../../outputs/expert-review-package
npm run expert:verify-package -- ../../outputs/expert-review-package
```

The package includes `expert-review-request-ko.md`, a Korean request letter and CSV writing guide suitable for sending to practicing reviewers.
It also includes `expert-review-tracker.csv`, which should be updated whenever a reviewer is contacted, reminded, responds, or has their response converted for inbox processing.
The same package also includes `manual-benchmark-package/` for Forceteller/Posteller app-screen comparison. This is manual capture evidence only, not an automated API adapter.

Generate the current coverage gap report with:

```bash
npm run expert:coverage -- ../../outputs/expert-coverage-report.md
```

## Required Case Mix

Collect 5-10 accepted cases before claiming professional-sale readiness.

The accepted set must cover at least 5 distinct focus areas from this list:

- `ipchun-boundary`
- `month-solar-term-boundary`
- `midnight-yaja`
- `midnight-joja`
- `lunar-calendar`
- `leap-month`
- `true-solar-time`
- `regional-birth-place`

The strongest 6-case starter mix is one `ipchun-boundary`, one `month-solar-term-boundary`, one `true-solar-time`, one `midnight-yaja`, one `midnight-joja`, and one `lunar-calendar` case. Add `leap-month` when the expert has a trusted reference value.

Use `npm run expert:coverage` after each accepted response to see which focus areas remain uncovered and which candidate rows should be reviewed next.
Use `npm run expert:priority-sheet` and `npm run expert:priority-template` when you want to send only the smallest currently useful candidate subset to a reviewer.
Use `npm run expert:tracker` or the package copy of `expert-review-tracker.csv` to keep reviewer status, reviewer credential, reference tool, response file name, accepted/corrected count, and covered focus areas in one place. After converting a response JSON, run `npm run expert:tracker-sync` to fill reviewer, reviewer credential, response file, accepted/corrected count, and covered focus areas from the response file. Tracker sync rejects accepted/corrected responses when `reviewer.evidence.reviewerCredential` is blank. Then run `npm run expert:tracker-summary` so placeholder reviewer slots are not counted as real progress.

## Reviewer Questions

Ask the reviewer to answer these for every case:

- Which manseryeok tool, workbook, or commercial app did you use?
- Was the calendar input solar or lunar?
- If lunar, was the month a leap month?
- Was the time unknown, approximate, or exact?
- Which day-boundary rule was used: 야자시 or 조자시?
- Was 진태양시 applied?
- If 진태양시 was applied, what longitude or birth place was used?
- What are the expected year, month, day, and hour pillars?
- Which screenshot, PDF, exported file, or workbook page supports the value?
- If a file is attached, what is its SHA-256 hash?

## JSON Case Template

Add accepted cases to `tests/fixtures/expert-reference-golden.json`.

```json
{
  "id": "expert-001",
  "description": "입춘 경계 검수 케이스",
  "source": {
    "type": "expert",
    "reviewer": "reviewer-id-or-name",
    "organization": "optional-organization",
    "referenceTool": "tool/workbook/app used by reviewer",
    "verifiedAt": "2026-06-29"
  },
  "input": {
    "calendar": "solar",
    "year": 2024,
    "month": 2,
    "day": 4,
    "isLeapMonth": false,
    "hour": 17,
    "minute": 27,
    "gender": "male",
    "birthPlace": "Seoul"
  },
  "calculateOptions": {
    "midnightMode": "yaja",
    "trueSolarTime": false,
    "longitude": 126.978
  },
  "expected": {
    "yearPillar": "甲辰",
    "monthPillar": "丙寅",
    "dayPillar": "戊戌",
    "hourPillar": "辛酉"
  }
}
```

The example above is a shape example only. Do not copy it as an accepted expert case unless the exact values are independently verified by the reviewer.

## Evidence Metadata

For each accepted or corrected row, keep enough audit evidence to reconnect the answer to the original reference output:

- `referenceCaptureFile`: screenshot, PDF, CSV export, or workbook page file name
- `referenceCaptureSha256`: optional SHA-256 hash for the capture file
- `referenceUrl`: optional URL for a provider page, shared export, or internal evidence location

The evidence fields do not replace the expert's judgment and are not required for backwards compatibility, but they make later professional-sale audits much easier.

## Promotion Rule

When a reviewer accepts or corrects a candidate:

1. Put completed `.json` or `.csv` responses in `../../outputs/expert-review-responses`.
2. Put screenshots, exports, or workbook captures in `../../outputs/expert-review-evidence`.
3. Run `expert:release-preflight` and fix any inspection, evidence, coverage, or consensus gaps.
4. After preflight passes, run `expert:release-candidate -- --write`.
5. Keep candidates in `expert-review-candidates.json` for traceability unless a candidate itself was invalid.

The release-candidate wrapper is the preferred write path because it creates a fixture backup, verifies evidence, runs expert reference tests, and produces a release summary:

```bash
npm run expert:release-preflight -- --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-package/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-package/expert-review-tracker.synced.csv --report ../../outputs/expert-release-preflight-summary.md
npm run expert:release-candidate -- --write --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-package/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-package/expert-review-tracker.synced.csv --report ../../outputs/expert-release-candidate-summary.md
npm run test:expert-reference
```

Treat `expert-release-candidate-summary.md` as the source of truth for the validation scope. A report that says `limited validation only` or `not sufficient for a professional-sale claim` is not a sale clearance; rerun without `--metadata-only` and without `--skip-tests` before claiming professional readiness.

If a promoted fixture must be reverted, copy the `Fixture restore command` from `expert-release-candidate-summary.md`. It will look like:

```bash
npm run expert:restore-fixture -- <fixture-backup.json> --fixture tests/fixtures/expert-reference-golden.json --expected-sha <backup-sha256>
```

The lower-level `expert:promote` script remains available for controlled diagnostics, but do not use it as the normal professional-sale write path.

```bash
npm run expert:promote -- ../../outputs/priority-review-response-template.json --report ../../outputs/expert-review-report.md
```

If the reviewer fills the CSV file instead, convert it to JSON first:

```bash
npm run expert:csv-to-json -- ../../outputs/priority-review-response.csv ../../outputs/priority-review-response.json
npm run expert:promote -- ../../outputs/priority-review-response.json --report ../../outputs/expert-review-report.md
```

To also generate an audit-friendly single-response diagnostic report, run `expert:promote` without `--write`.

When collecting multiple reviewer responses, inspect them for candidate-level conflicts before promotion:

```bash
npm run expert:collection-plan -- ../../outputs/expert-collection-plan.md ../../outputs/expert-collection-plan.csv
npm run expert:reviewer-packets -- ../../outputs/expert-reviewer-packets
npm run expert:inbox -- ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --tracker ../../outputs/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-tracker.synced.csv --min-reviewers 2 --min-reference-tools 2
```

The collection plan assigns currently missing focus areas to two reviewer/reference-tool slots and suggests evidence file names. `expert:reviewer-packets` creates reviewer-specific prefilled CSV files from that plan, so each reviewer can receive only the current selected candidate rows. The inbox command accepts a folder containing `.json` and `.csv` reviewer responses. It converts CSV files, writes an inspection report, and writes a consensus report. When `--evidence-dir` is supplied, CSV files are first copied into the converted folder with missing `referenceCaptureSha256` values filled from their `referenceCaptureFile` evidence files. If you need to inspect explicit files manually, run:

Start with `../../outputs/expert-review-inbox/expert-review-inbox-summary.md`; it tells you whether inspection passed, whether consensus passed, whether the collection gate passed, and the next action. The inbox command also writes `../../outputs/expert-review-inbox/expert-collection-status.md` from JSON-only normalized responses in `../../outputs/expert-review-inbox/collection-responses/`, so hash-filled CSV work files in `converted/` do not get mistaken for unconverted reviewer responses.
CSV conversion, inspection, promotion, and aggregation all reject accepted/corrected rows while package placeholders such as `reviewer-a`, `reference-tool-a`, or `YYYY-MM-DD` remain in reviewer metadata.
Accepted/corrected rows also require `reviewer.evidence.reviewerCredential` in JSON responses, or `reviewerCredential` in CSV responses. Use it for a concise professional credential, reviewer role, or review-context statement; avoid storing unnecessary personal identifiers.
The `referenceTool` must name an independent manseryeok tool, commercial app, workbook, or text source. Do not use Myunglab, `engineDerived`, or the candidate fixture itself as the reference source.

When response files include `referenceCaptureFile` and `referenceCaptureSha256`, keep the capture files in a separate evidence folder and verify them before promotion:

```bash
npm run evidence:hashes -- ../../outputs/expert-review-evidence ../../outputs/expert-review-evidence-hashes.csv
npm run expert:inbox -- ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-tracker.synced.csv --tracker-status consensus-ready --min-reviewers 2 --min-reference-tools 2
npm run expert:evidence -- ../../outputs/expert-review-inbox/converted/reviewer-a.json ../../outputs/expert-review-inbox/converted/reviewer-b.json --evidence-dir ../../outputs/expert-review-evidence --report ../../outputs/expert-review-evidence.md
npm run expert:collection-gate -- --responses-dir ../../outputs/expert-review-inbox/collection-responses --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-tracker.synced.csv --report ../../outputs/expert-review-inbox/expert-collection-status.md
```

Use `expert-review-evidence-hashes.csv` when you need to inspect hashes manually. For individual CSV files, `evidence:fill-csv` fills blank `referenceCaptureSha256` values from `referenceCaptureFile` and fails if an existing hash does not match the evidence file. For inbox folders, `expert:inbox --evidence-dir ...` runs that fill step automatically before CSV-to-JSON conversion. When `--tracker` and `--tracker-out` are supplied, the inbox command also syncs converted response JSON files into the tracker and writes `expert-review-tracker-summary.md` under the inbox output directory.

Once the inbox, evidence files, and tracker are ready, run preflight first. It does not update `tests/fixtures/expert-reference-golden.json`.

```bash
npm run expert:release-preflight -- --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-package/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-package/expert-review-tracker.synced.csv --report ../../outputs/expert-release-preflight-summary.md
```

After preflight passes, the release-candidate wrapper runs the full promotion and readiness path in order. It refuses write promotion without `--write` because it can update `tests/fixtures/expert-reference-golden.json`.

```bash
npm run expert:release-candidate -- --write --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --tracker ../../outputs/expert-review-package/expert-review-tracker.csv --tracker-out ../../outputs/expert-review-package/expert-review-tracker.synced.csv --report ../../outputs/expert-release-candidate-summary.md
```

The release summary includes the fixture backup path, backup SHA-256, and the exact `expert:restore-fixture` command to use if the write needs to be rolled back.

```bash
npm run expert:inspect -- ../../outputs/reviewer-a.json ../../outputs/reviewer-b.json --strict --require-evidence --report ../../outputs/expert-review-inspection.md
```

`--strict` exits non-zero when two reviewers provide different accepted/corrected pillars for the same candidate. `--require-evidence` also exits non-zero when any accepted/corrected row lacks `reviewerCredential`, `referenceCaptureFile`, or `referenceCaptureSha256`.

For a stricter multi-reviewer diagnostic workflow, aggregate only candidates where at least two reviewers agree on the exact same pillars:

```bash
npm run expert:aggregate -- ../../outputs/reviewer-a.json ../../outputs/reviewer-b.json --min-reviewers 2 --report ../../outputs/expert-review-consensus.md
```

After checking the consensus report, use the release wrapper for the actual write:

```bash
npm run expert:release-preflight -- --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --min-reviewers 2 --min-reference-tools 2
npm run expert:release-candidate -- --write --inbox ../../outputs/expert-review-responses --out ../../outputs/expert-review-inbox --evidence-dir ../../outputs/expert-review-evidence --min-reviewers 2 --min-reference-tools 2
npm run test:expert-reference
```

The release wrapper refuses to write unless the consensus set contains 5-10 cases, covers at least 5 distinct focus areas, contains no conflicting accepted/corrected values for promoted candidates, and verifies every capture file hash from `--evidence-dir`.

# Solar Terms Data

## Scope

The engine stores 24 solar terms in `src/engine/core/data/solar-terms.generated.json`.

- Raw solar-term data range: 1899-2101
- Date-only solar-term wrapper comparison range: 1900-2101
- Legal palja/report calculation range: solar 1908-04-01 through 2101, because Korean legal-time policy is source-backed from the 1908 standard-time adoption.
- Terms per year: 24
- Runtime accessors: `listSolarTermsForYear(year)`, date-only `getSolarTermOnOrBefore(date)`, timestamp-aware `getSolarTermOnOrBeforeDateTime(dateTime)`, and timestamp-aware 12-jeol lookup.

## Data Lineage

`solar-terms.generated.json` is treated as a vendored precomputed generated table. The repository currently does not contain the original generator or upstream ephemeris export that produced the table, so the engine must not claim an independently reproducible astronomical generation source from this file alone.

The table records Chinese source names, Korean term names, source-local timestamp fields, and a Julian day for each term. For professional-sale readiness, the accepted provenance evidence is:

- the committed generated table itself
- runtime normalization documented below
- raw range and ordering validation for 1899-2101
- full public-range comparison against the `manseryeok` npm provider for every term from 1900 through 2101

If the table is regenerated in the future, the generator or upstream export must be committed or archived with the astronomical formula or data source, source timezone, rounding policy, supported year range, and comparison provider.

## Time Standard

The generated JSON currently stores source-local term times that are one hour earlier than Korean Standard Time for the Korean manseryeok use case. Runtime access normalizes these records to KST in `src/engine/core/solar-terms.ts`.

Example:

- Raw 2024 입춘: 2024-02-04 16:27:07
- Runtime KST 2024 입춘: 2024-02-04 17:27:07
- External `manseryeok` provider: 2024-02-04T08:27:00Z, which is 2024-02-04 17:27 KST

This matters because year and month pillars change at the exact solar-term timestamp, not merely at the calendar day.

`getSolarTermOnOrBefore(date)` intentionally remains a date-only Julian-day compatibility wrapper for qimen/daeyukim/calendar-style callers. Saju palja, Daeun, seun, and wolun must use timestamp-aware context APIs so same-day inputs before a term do not cross the boundary early.

## Verification

The following automated tests protect this data:

- `tests/engine/external-provider-matrix.test.ts`: boundary cases around 입춘, 경칩, 자시, and supported legal/public range edges.
- `tests/engine/solar-terms-provider-range.test.ts`: verifies the generated JSON covers every raw year from 1899 through 2101 with 24 sorted terms, confirms runtime KST normalization keeps every date-only comparison year from 1900 through 2101 complete and sorted, checks 1900/2101 wrapper edge lookups, and compares all 24 terms for every comparison year against the public `manseryeok` provider.
- `npm run solar-terms:verify -- ../../outputs/solar-term-verification-report.md`: writes a sale-readiness markdown report proving the same 1900-2101 date-only wrapper/provider comparison set. The current comparison count is 4,848 terms: 202 comparison years * 24 terms.

Allowed drift is two minutes because the local source records seconds while the provider exposes minute-level timestamps.

## Regeneration Requirement

If `solar-terms.generated.json` is regenerated or replaced, run:

```bash
npm run test:manseryeok
npm run solar-terms:verify -- ../../outputs/solar-term-verification-report.md
npm test
```

Any future generator should state:

- astronomical formula or upstream dataset
- timezone of source timestamps
- rounding policy
- supported year range
- comparison provider and tolerated drift

# Expert Reference Fixtures

## Purpose

`tests/fixtures/expert-reference-golden.json` is reserved for reference values confirmed by practicing saju/manseryeok professionals. These cases are separate from provider-derived fixtures so that professional review evidence is not mixed with automated library agreement.

## Acceptance Rule

Before claiming the engine is ready for professional sale, add 5-10 accepted expert cases.
The promoted fixture must also show independent consensus from at least 2 distinct reviewers and at least 2 distinct reference tools.

Each case must include:

- `source.type: "expert"`
- reviewer name or stable reviewer id
- reference tool or workbook used by the reviewer
- verification date
- reviewed candidate id
- accepted/corrected response status
- candidate fixture SHA-256 used for the review
- evidence metadata for accepted cases: screenshot/export file names and SHA-256 hashes
- optional reference URLs for traceability when the reference tool exposes a stable page
- input calendar type and exact birth time
- selected calculation options: yaja/joja, true solar time, longitude
- expected year, month, day, and hour pillars

The fixture test also verifies that:

- `reviewedCandidateId` exists in `tests/fixtures/expert-review-candidates.json`
- `candidateFixtureSha256` matches the current candidate fixture
- accepted cases keep the engine-derived pillars from the reviewed candidate
- corrected cases may differ, but still must pass pillar format and engine comparison checks
- accepted fixture sources contain at least 2 distinct reviewers and 2 distinct reference tools
- accepted fixture sources contain hashed capture evidence for the reviewer/reference-tool result

Use `docs/engine/reference-provider-register.md` to keep public provider comparisons separate from expert-reviewed acceptance evidence.

## Test Behavior

`tests/engine/expert-reference-fixtures.test.ts` always validates fixture policy and case schema. The acceptance block is skipped while there are no expert cases. Once at least one expert case is added, it enforces the 5-10 case acceptance range, the independent consensus policy, hashed capture evidence, and every accepted case.

This is intentional: provider-derived values must not masquerade as expert-reviewed commercial evidence.

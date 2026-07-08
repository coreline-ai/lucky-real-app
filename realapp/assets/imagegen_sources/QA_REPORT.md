# Imagegen Full HD QA Report

Updated: 2026-07-07 20:01:18 Asia/Seoul

## Scope

- Contract file: `realapp/assets/imagegen_sources/full_hd_p0_contract.json`
- Final manifest: `realapp/assets/ASSET_MANIFEST.md`
- Contact sheet: `realapp/assets/imagegen_sources/QA_CONTACT_SHEET.png`
- Total contract entries: 72
- Final selected assets produced or verified under `realapp/assets/images/`

## Result

`PASS full_hd_asset_validation entries=72`

## Status Counts

- Existing baseline: 11
- Generated: 44
- Generated derivative: 10
- Upgraded: 7

## Resolution Counts

- 1024x1024: 1
- 1080x1620: 23
- 1080x1920: 14
- 1920x1080: 21
- 2048x2048: 13

## Distortion Prevention

- Each imagegen prompt included a target aspect intent: 9:16, 16:9, 2:3, or 1:1.
- Final assets were created through `process_generated_assets.py`, which preserves aspect ratio.
- Non-alpha backgrounds use cover resize plus safe crop.
- Alpha/cutout assets use contain resize plus transparent padding after chroma-key extraction when needed.
- Element card and wide derivatives were generated as separate 2:3 and 16:9 compositions; vertical originals were not stretched into landscape.

## QA Checks Performed

- File existence for every contract entry.
- Exact pixel dimensions with Pillow; a 1px mismatch fails validation.
- Alpha-channel requirement for symbols, guardians, overlays, frames, and badges.
- Prompt existence under `realapp/assets/imagegen_sources/prompts/`.
- Forbidden monetization wording scan in prompt files.
- Contact sheet visual review for obvious mismap, stretching, broken crop, heavy blur, and missing safe areas.

## Raw Candidate Handling

- Card batch candidates: 22 raw files inspected; 18 selected, 4 excluded as unrelated generated images.
- History/settings/element batch candidates: 19 raw files inspected; 16 selected, 3 excluded as unrelated generated images.
- Excluded raw files were not copied into `realapp/assets/images/` and are not listed in `ASSET_MANIFEST.md`.

## Verification Commands

```bash
python realapp/assets/imagegen_sources/tools/validate_full_hd_assets.py
python realapp/assets/imagegen_sources/tools/make_contact_sheet.py
```

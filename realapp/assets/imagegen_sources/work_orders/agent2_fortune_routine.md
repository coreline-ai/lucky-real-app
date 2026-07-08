# Agent 2 Work Order: Fortune And Routine Panels

Scope: prompt specs only. Do not generate images, do not edit image files, and do not edit `realapp/assets/ASSET_MANIFEST.md`.

## Owned Prompt Files

| ID | Asset | Final app target | Alpha | Prompt file |
|---|---|---:|---|---|
| FORTUNE-001 | Total fortune panel background | 1920x1080 | No | `realapp/assets/imagegen_sources/prompts/FORTUNE-001.md` |
| FORTUNE-002 | Relationship fortune panel background | 1920x1080 | No | `realapp/assets/imagegen_sources/prompts/FORTUNE-002.md` |
| FORTUNE-003 | Work/study flow panel background | 1920x1080 | No | `realapp/assets/imagegen_sources/prompts/FORTUNE-003.md` |
| FORTUNE-004 | Condition flow panel background | 1920x1080 | No | `realapp/assets/imagegen_sources/prompts/FORTUNE-004.md` |
| ROUTINE-001 | Wood routine panel background | 1920x1080 | No | `realapp/assets/imagegen_sources/prompts/ROUTINE-001.md` |
| ROUTINE-002 | Fire routine panel background | 1920x1080 | No | `realapp/assets/imagegen_sources/prompts/ROUTINE-002.md` |
| ROUTINE-003 | Earth routine panel background | 1920x1080 | No | `realapp/assets/imagegen_sources/prompts/ROUTINE-003.md` |
| ROUTINE-004 | Metal routine panel background | 1920x1080 | No | `realapp/assets/imagegen_sources/prompts/ROUTINE-004.md` |
| ROUTINE-005 | Water routine panel background | 1920x1080 | No | `realapp/assets/imagegen_sources/prompts/ROUTINE-005.md` |
| ROUTINE-006 | Routine completion badge | 1024x1024 | Yes | `realapp/assets/imagegen_sources/prompts/ROUTINE-006.md` |

## Shared Production Contract

- Panel backgrounds are horizontal 16:9 assets designed for `1920x1080` final output.
- `ROUTINE-006` is a square `1024x1024` alpha cutout; generate it on a flat uniform `#00ff00` chroma-key background, then key to transparency.
- Generate the largest clean master available, then create final derivatives by ratio-preserving cover crop for backgrounds or contain resize plus transparent padding for cutouts.
- Never stretch a mismatched ratio to the target size.
- Preserve Flutter UI safe areas: fortune panels need broad calm fields for titles, summaries, and score cards; routine panels need broad calm fields for checklist rows and completion controls.
- All prompt specs require no text, no watermark, no personal data, no birthdate/time, no names, no monetization cues, and no gambling-pack or casino style.

## Suggested Final Asset Names

These names are handoff suggestions for the producer/integration worker, not files created by this work order.

| ID | Suggested final path |
|---|---|
| FORTUNE-001 | `realapp/assets/images/backgrounds/fortune_total_panel_bg_1920x1080_v1.png` |
| FORTUNE-002 | `realapp/assets/images/backgrounds/fortune_relationship_panel_bg_1920x1080_v1.png` |
| FORTUNE-003 | `realapp/assets/images/backgrounds/fortune_work_study_panel_bg_1920x1080_v1.png` |
| FORTUNE-004 | `realapp/assets/images/backgrounds/fortune_condition_panel_bg_1920x1080_v1.png` |
| ROUTINE-001 | `realapp/assets/images/backgrounds/routine_wood_panel_bg_1920x1080_v1.png` |
| ROUTINE-002 | `realapp/assets/images/backgrounds/routine_fire_panel_bg_1920x1080_v1.png` |
| ROUTINE-003 | `realapp/assets/images/backgrounds/routine_earth_panel_bg_1920x1080_v1.png` |
| ROUTINE-004 | `realapp/assets/images/backgrounds/routine_metal_panel_bg_1920x1080_v1.png` |
| ROUTINE-005 | `realapp/assets/images/backgrounds/routine_water_panel_bg_1920x1080_v1.png` |
| ROUTINE-006 | `realapp/assets/images/effects/routine_completion_badge_1024_v1.png` |

## Handoff Checks

- Confirm every prompt file includes the target ratio and final output size.
- Confirm every prompt file includes the shared no-text/no-watermark/no-personal-data/no-monetization/no-gambling constraints.
- Confirm panel prompts explicitly leave UI-safe negative space for Flutter-rendered text or checklists.
- Confirm `ROUTINE-006` specifies flat chroma-key background and alpha-ready final output.
- Leave `ASSET_MANIFEST.md` for the QA/integration agent after assets are actually produced.

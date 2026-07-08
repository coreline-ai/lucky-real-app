# Agent 3 Guardians Full HD Work Order

Scope: prompt/spec preparation only. Do not generate images in this slice.

## Ownership

Owned prompt files:

- `realapp/assets/imagegen_sources/prompts/GUARD-WOOD-YANG-V2.md`
- `realapp/assets/imagegen_sources/prompts/GUARD-WOOD-YIN.md`
- `realapp/assets/imagegen_sources/prompts/GUARD-FIRE-YANG-V2.md`
- `realapp/assets/imagegen_sources/prompts/GUARD-FIRE-YIN.md`
- `realapp/assets/imagegen_sources/prompts/GUARD-EARTH-YANG-V2.md`
- `realapp/assets/imagegen_sources/prompts/GUARD-EARTH-YIN.md`
- `realapp/assets/imagegen_sources/prompts/GUARD-METAL-YANG-V2.md`
- `realapp/assets/imagegen_sources/prompts/GUARD-METAL-YIN.md`
- `realapp/assets/imagegen_sources/prompts/GUARD-WATER-YANG-V2.md`
- `realapp/assets/imagegen_sources/prompts/GUARD-WATER-YIN.md`

Do not edit:

- Existing `GUARD-*-YANG.md` v1 prompt files
- `realapp/assets/ASSET_MANIFEST.md`
- Any image files
- Prompt files outside the Agent 3 list above

## Shared Output Contract

- All guardians are square 1:1 assets designed for 2048x2048 final output.
- Final app assets must be 2048x2048 transparent PNG or alpha-capable WebP.
- Source images must use a perfectly flat chroma-key background for alpha removal.
- Final cutouts must preserve full body visibility with generous padding.
- No crop-critical edges: head, feet, accessories, ribbons, halos, glow, wave crests, and ornaments must remain safely inside the frame.
- Existing 1024x1024 yang files are retained as v1 assets and must not be counted as Full HD replacements.
- Upgrade assets use v2 final image names; new yin assets use v1 final image names unless the integration owner chooses a different manifest convention.

## Chroma-Key Assignments

| Asset id | Prompt file | Status | Key color | Reason |
|---|---|---|---|---|
| GUARD-WOOD-YANG | GUARD-WOOD-YANG-V2.md | Upgrade | #ff00ff magenta | Wood subject is green |
| GUARD-WOOD-YIN | GUARD-WOOD-YIN.md | New | #ff00ff magenta | Wood subject is green |
| GUARD-FIRE-YANG | GUARD-FIRE-YANG-V2.md | Upgrade | #00ff00 green | Subject is red/orange |
| GUARD-FIRE-YIN | GUARD-FIRE-YIN.md | New | #00ff00 green | Subject is red/orange |
| GUARD-EARTH-YANG | GUARD-EARTH-YANG-V2.md | Upgrade | #00ff00 green | Subject is ochre/clay |
| GUARD-EARTH-YIN | GUARD-EARTH-YIN.md | New | #00ff00 green | Subject is ivory/clay |
| GUARD-METAL-YANG | GUARD-METAL-YANG-V2.md | Upgrade | #00ff00 green | Subject is silver/white |
| GUARD-METAL-YIN | GUARD-METAL-YIN.md | New | #00ff00 green | Subject is silver/pearl |
| GUARD-WATER-YANG | GUARD-WATER-YANG-V2.md | Upgrade | #00ff00 green | Avoid blue key for blue subject |
| GUARD-WATER-YIN | GUARD-WATER-YIN.md | New | #00ff00 green | Avoid blue key for blue subject |

## Expected Image Paths For Later Production

| Asset id | Master candidate | Final app cutout |
|---|---|---|
| GUARD-WOOD-YANG | `realapp/assets/imagegen_sources/masters/guardian_wood_yang_master_v2.png` | `realapp/assets/images/guardians/guardian_wood_yang_idle_2048_v2.png` |
| GUARD-WOOD-YIN | `realapp/assets/imagegen_sources/masters/guardian_wood_yin_master_v1.png` | `realapp/assets/images/guardians/guardian_wood_yin_idle_2048_v1.png` |
| GUARD-FIRE-YANG | `realapp/assets/imagegen_sources/masters/guardian_fire_yang_master_v2.png` | `realapp/assets/images/guardians/guardian_fire_yang_idle_2048_v2.png` |
| GUARD-FIRE-YIN | `realapp/assets/imagegen_sources/masters/guardian_fire_yin_master_v1.png` | `realapp/assets/images/guardians/guardian_fire_yin_idle_2048_v1.png` |
| GUARD-EARTH-YANG | `realapp/assets/imagegen_sources/masters/guardian_earth_yang_master_v2.png` | `realapp/assets/images/guardians/guardian_earth_yang_idle_2048_v2.png` |
| GUARD-EARTH-YIN | `realapp/assets/imagegen_sources/masters/guardian_earth_yin_master_v1.png` | `realapp/assets/images/guardians/guardian_earth_yin_idle_2048_v1.png` |
| GUARD-METAL-YANG | `realapp/assets/imagegen_sources/masters/guardian_metal_yang_master_v2.png` | `realapp/assets/images/guardians/guardian_metal_yang_idle_2048_v2.png` |
| GUARD-METAL-YIN | `realapp/assets/imagegen_sources/masters/guardian_metal_yin_master_v1.png` | `realapp/assets/images/guardians/guardian_metal_yin_idle_2048_v1.png` |
| GUARD-WATER-YANG | `realapp/assets/imagegen_sources/masters/guardian_water_yang_master_v2.png` | `realapp/assets/images/guardians/guardian_water_yang_idle_2048_v2.png` |
| GUARD-WATER-YIN | `realapp/assets/imagegen_sources/masters/guardian_water_yin_master_v1.png` | `realapp/assets/images/guardians/guardian_water_yin_idle_2048_v1.png` |

## Production Acceptance Checks

- [ ] Prompt file exists for every Agent 3 guardian.
- [ ] Prompt explicitly says square 1:1 and designed for 2048x2048 final output.
- [ ] Prompt requires a perfectly flat chroma-key background.
- [ ] Prompt requires full body visibility, generous padding, and no crop-critical edges.
- [ ] Prompt forbids text, watermark, personal data, commercial cues, and frightening imagery.
- [ ] Wood guardians use #ff00ff magenta key.
- [ ] Non-wood guardians use #00ff00 green key.
- [ ] Water guardians do not use a blue key color.
- [ ] Final app cutouts are exactly 2048x2048 and have alpha after image production.
- [ ] No existing v1 yang prompt, v1 image, manifest entry, or unrelated prompt is overwritten by this slice.

## Handoff Notes

- Agent 3 has prepared prompt specs only; image generation, alpha extraction, pixel validation, contact sheet QA, and manifest integration remain downstream tasks.
- If an image generator returns a non-square or tightly cropped source, regenerate rather than stretching or accepting a cropped cutout.
- If chroma-key fringe remains after alpha removal, regenerate or repair from the master before manifest integration.

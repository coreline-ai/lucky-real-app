# Agent 1 Work Order: Brand, Splash, Onboarding, Home

Scope: prompt specs only. Do not generate images from this work order, do not edit image files, and do not edit `realapp/assets/ASSET_MANIFEST.md`.

## Owned Prompt Files

| Asset ID | Prompt path | Final app contract | Alpha |
|---|---|---:|---|
| BRAND-002 | `realapp/assets/imagegen_sources/prompts/BRAND-002.md` | 2048x2048, 1:1 | yes |
| SPLASH-002 | `realapp/assets/imagegen_sources/prompts/SPLASH-002.md` | 1080x1920, 9:16 | no |
| SPLASH-003 | `realapp/assets/imagegen_sources/prompts/SPLASH-003.md` | 2048x2048, 1:1 | yes |
| ONB-004 | `realapp/assets/imagegen_sources/prompts/ONB-004.md` | 1080x1920, 9:16 | no |
| HOME-004 | `realapp/assets/imagegen_sources/prompts/HOME-004.md` | 1080x1620, 2:3 | yes |
| HOME-005 | `realapp/assets/imagegen_sources/prompts/HOME-005.md` | 1920x1080, 16:9 | no |
| HOME-006 | `realapp/assets/imagegen_sources/prompts/HOME-006.md` | 1920x1080, 16:9 | no |

## Production Rules Captured In Prompts

- Every prompt states the exact final resolution and target aspect ratio.
- Every prompt says the composition is designed for that aspect ratio, with generous safe margins and no crop-critical subject near edges.
- Every prompt forbids baked text, watermark, personal data, birth date/time, names, portraits, monetization cues, ads, subscription, price tags, paid-card-pack presentation, and gambling-pack style.
- Alpha assets use a perfectly flat solid #ff00ff chroma-key background and explicitly forbid #ff00ff in the subject.
- Alpha assets require no shadows, gradients, texture, reflections, floor plane, lighting variation, matte fringe, or halo in the chroma-key background.
- Non-alpha panel/background assets explicitly forbid stretching or distortion from another aspect ratio.

## Handoff Notes For Producer/QA

- Final alpha files must be produced by chroma-key removal and verified for an actual alpha channel.
- If imagegen returns the wrong aspect ratio, regenerate instead of stretching.
- Final crops must preserve UI safe areas and must not cut off important visual motifs.
- Manifest updates belong to the QA/integration owner, not Agent 1.


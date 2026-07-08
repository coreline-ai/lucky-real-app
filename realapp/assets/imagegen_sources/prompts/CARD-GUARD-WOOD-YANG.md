# CARD-GUARD-WOOD-YANG Prompt Spec

Asset contract:
- Asset ID: CARD-GUARD-WOOD-YANG
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is opaque reward card art.
- Role: card art for the wood yang guardian, used in free collection and reward flows.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque guardian reward card art, vertical 2:3
Primary request: create a card illustration for the wood yang sprout guardian, representing growth, planning, and bright vitality
Scene/backdrop: jade grove card world with young branches, dew, leaf-vein patterns, and gentle morning light
Subject: elegant non-human sprout guardian with leaf crown and small branch staff, placed in the upper third and partly framed by side foliage
Style/medium: high-end mobile card illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical 2:3 card art designed for 1080x1620 final output; full subject silhouette visible, no cropping; central safe area stays quiet for Flutter text and badges
Safe area: keep x=18% to 82% and y=38% to 74% low-detail and free of the guardian face, staff, seals, readable marks, or bright focal effects
Lighting/mood: fresh, lively, hopeful, friendly but not childish
Color palette: emerald, fresh green, pale jade, warm gold highlights
Materials/textures: leaves, dew, soft bark, jade, hanji grain, silk edge glow
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, non-human spirit form, no realistic human face, no animal mascot
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, scary spirit, dense clutter, readable symbols
```

Post-processing and QA:
- Keep the artwork opaque.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Confirm the guardian is not cropped and the central overlay area remains usable.

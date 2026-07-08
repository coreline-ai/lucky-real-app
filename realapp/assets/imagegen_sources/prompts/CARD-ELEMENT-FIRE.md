# CARD-ELEMENT-FIRE Prompt Spec

Asset contract:
- Asset ID: CARD-ELEMENT-FIRE
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is opaque card art.
- Role: fire-element reward card art for the free card collection.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque mobile reward card art, vertical 2:3
Primary request: create a fire-element card illustration representing vitality, expression, warmth, and joyful momentum
Scene/backdrop: calm sunset lantern atmosphere with abstract flame petals, ember motes, and a soft horizon glow
Subject: elegant fire energy crest and lantern-flame motif arranged around the upper and side edges, no character face
Style/medium: high-end mobile card illustration, Korean-inspired fantasy wellness, painterly 3D hybrid finish
Composition/framing: vertical 2:3 card art designed for 1080x1620 final output; fire detail stays around borders and corners while the central safe area remains quiet for Flutter text and badges
Safe area: keep x=18% to 82% and y=32% to 72% low-detail, softly luminous, and free of focal flames, seals, readable marks, or high-contrast sparks
Lighting/mood: warm, lively, encouraging, safe, not explosive
Color palette: coral, warm red, amber, soft gold, muted plum shadow
Materials/textures: silk lantern glow, ember dust, brushed gold, warm hanji grain
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, no human face, no animals, no aggressive flames
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, flashy arcade glow, fire hazard realism, horror, readable symbols
```

Post-processing and QA:
- Keep the artwork opaque.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Check that Flutter title, count badge, or progress badge can sit over the central safe area.

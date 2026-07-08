# CARD-ELEMENT-EARTH Prompt Spec

Asset contract:
- Asset ID: CARD-ELEMENT-EARTH
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is opaque card art.
- Role: earth-element reward card art for the free card collection.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque mobile reward card art, vertical 2:3
Primary request: create an earth-element card illustration representing stability, grounding, care, and steady rhythm
Scene/backdrop: warm mountain-and-ceramic atmosphere with gentle terraced shapes, clay texture, and soft mineral glow
Subject: elegant earth energy crest, mountain ridge, and pottery motif arranged around the upper and side edges, no character face
Style/medium: high-end mobile card illustration, Korean-inspired fantasy wellness, painterly 3D hybrid finish
Composition/framing: vertical 2:3 card art designed for 1080x1620 final output; earth textures support the border and corners while the central safe area remains clean for Flutter text and badges
Safe area: keep x=18% to 82% and y=32% to 72% low-detail, matte, and free of focal objects, seals, readable marks, or high-contrast cracks
Lighting/mood: stable, warm, reassuring, grounded
Color palette: ochre, warm clay, muted gold, soft beige, moss green accents
Materials/textures: pottery glaze, mineral dust, mountain stone, hanji grain, woven silk
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, no human face, no animals, no heavy mud or decay
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, dusty clutter, cracked disaster imagery, readable symbols
```

Post-processing and QA:
- Keep the artwork opaque.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Check that Flutter title, count badge, or progress badge can sit over the central safe area.

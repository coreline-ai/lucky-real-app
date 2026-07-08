# CARD-ELEMENT-WATER Prompt Spec

Asset contract:
- Asset ID: CARD-ELEMENT-WATER
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is opaque card art.
- Role: water-element reward card art for the free card collection.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque mobile reward card art, vertical 2:3
Primary request: create a water-element card illustration representing recovery, flow, reflection, and adaptive calm
Scene/backdrop: moonlit spring atmosphere with soft waves, mist, ripples, and quiet star reflections
Subject: elegant water energy crest, wave ribbon, and moon-spring motif arranged around the upper and side edges, no character face
Style/medium: high-end mobile card illustration, Korean-inspired fantasy wellness, painterly 3D hybrid finish
Composition/framing: vertical 2:3 card art designed for 1080x1620 final output; water detail frames the edges while the central safe area stays peaceful for Flutter text and badges
Safe area: keep x=18% to 82% and y=32% to 72% low-detail, misty, and free of focal waves, seals, readable marks, or high-contrast foam
Lighting/mood: cool, restful, reflective, hopeful
Color palette: deep blue, moonlit cyan, soft navy, pale silver, tiny jade highlights
Materials/textures: water ripple, mist, moonstone, silk, hanji grain
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, no human face, no animals, no storm or danger imagery
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, drowning imagery, gloomy fear tone, readable symbols
```

Post-processing and QA:
- Keep the artwork opaque.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Check that Flutter title, count badge, or progress badge can sit over the central safe area.

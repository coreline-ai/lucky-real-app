# CARD-ELEMENT-WOOD Prompt Spec

Asset contract:
- Asset ID: CARD-ELEMENT-WOOD
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is opaque card art.
- Role: wood-element reward card art for the free card collection.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque mobile reward card art, vertical 2:3
Primary request: create a wood-element card illustration representing growth, planning, renewal, and gentle expansion
Scene/backdrop: quiet jade grove atmosphere with abstract leaf veins, young branches, dew, and soft starlight
Subject: elegant wood energy crest and sprout motif arranged around the upper and side edges, no character face
Style/medium: high-end mobile card illustration, Korean-inspired fantasy wellness, painterly 3D hybrid finish
Composition/framing: vertical 2:3 card art designed for 1080x1620 final output; visual energy frames the card edges while the central safe area stays clear for Flutter text and badges
Safe area: keep x=18% to 82% and y=32% to 72% low-detail, softly lit, and free of focal subjects, seals, readable marks, or high-contrast branches
Lighting/mood: fresh morning light, calm, hopeful, restorative
Color palette: emerald, fresh green, pale jade, soft teal, tiny warm gold highlights
Materials/textures: leaves, dew, soft bark, jade, hanji grain
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, no human face, no animals, no dense forest clutter
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, neon green overload, scary forest, readable symbols
```

Post-processing and QA:
- Keep the artwork opaque.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Check that Flutter title, count badge, or progress badge can sit over the central safe area.

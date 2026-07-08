# CARD-ELEMENT-METAL Prompt Spec

Asset contract:
- Asset ID: CARD-ELEMENT-METAL
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is opaque card art.
- Role: metal-element reward card art for the free card collection.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque mobile reward card art, vertical 2:3
Primary request: create a metal-element card illustration representing clarity, focus, refinement, and precise judgment
Scene/backdrop: quiet silver workshop atmosphere with frost-light, polished metal arcs, and subtle constellation geometry
Subject: elegant metal energy crest, blade-light glint, and frost-bell motif arranged around the upper and side edges, no weapon violence
Style/medium: high-end mobile card illustration, Korean-inspired fantasy wellness, painterly 3D hybrid finish
Composition/framing: vertical 2:3 card art designed for 1080x1620 final output; reflective details stay on edges and corners while the central safe area remains calm for Flutter text and badges
Safe area: keep x=18% to 82% and y=32% to 72% low-detail, matte-silver, and free of focal blades, seals, readable marks, or harsh contrast
Lighting/mood: crisp, composed, clean, quietly luminous
Color palette: silver, pearl white, pale gold, cool gray, faint jade accent
Materials/textures: brushed metal, frost, mother-of-pearl, silk, hanji grain
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, no human face, no animals, no violent weapon scene
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, chrome clutter, harsh sci-fi UI, readable symbols
```

Post-processing and QA:
- Keep the artwork opaque.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Check that Flutter title, count badge, or progress badge can sit over the central safe area.

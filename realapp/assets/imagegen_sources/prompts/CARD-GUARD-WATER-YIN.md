# CARD-GUARD-WATER-YIN Prompt Spec

Asset contract:
- Asset ID: CARD-GUARD-WATER-YIN
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is opaque reward card art.
- Role: card art for the water yin guardian, used in free collection and reward flows.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque guardian reward card art, vertical 2:3
Primary request: create a card illustration for the water yin moon-spring guardian, representing recovery, reflection, and quiet emotional flow
Scene/backdrop: still moon-spring card world with soft ripples, mist, pale lotus-like light shapes, and star reflections
Subject: elegant non-human moon-spring guardian with gentle water veil, moonstone crest, and calm seated or floating pose, placed in the upper third and side-framed by ripple arcs
Style/medium: high-end mobile card illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical 2:3 card art designed for 1080x1620 final output; full subject silhouette visible, no cropping; central safe area stays quiet for Flutter text and badges
Safe area: keep x=18% to 82% and y=38% to 74% low-detail and free of the guardian face, water veil, seals, readable marks, or high-contrast foam
Lighting/mood: restful, reflective, tender, safe, hopeful
Color palette: moonlit cyan, soft navy, deep blue, pale silver, tiny jade highlights
Materials/textures: still water, mist, moonstone, silk, hanji grain
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, non-human spirit form, no realistic human face, no animal mascot
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, drowning imagery, storm danger, gloomy fear tone, readable symbols
```

Post-processing and QA:
- Keep the artwork opaque.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Confirm the guardian is not cropped and the central overlay area remains usable.

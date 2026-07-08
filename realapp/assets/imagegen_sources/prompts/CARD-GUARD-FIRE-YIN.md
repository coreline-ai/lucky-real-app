# CARD-GUARD-FIRE-YIN Prompt Spec

Asset contract:
- Asset ID: CARD-GUARD-FIRE-YIN
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is opaque reward card art.
- Role: card art for the fire yin guardian, used in free collection and reward flows.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque guardian reward card art, vertical 2:3
Primary request: create a card illustration for the fire yin lantern guardian, representing gentle warmth, expression, and steady inner light
Scene/backdrop: quiet evening lantern card world with ember dust, silk glow, and soft coral haze
Subject: elegant non-human lantern guardian with small ember crown, warm lamp core, and flowing silk ribbon, placed in the upper third and side-framed by lantern arcs
Style/medium: high-end mobile card illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical 2:3 card art designed for 1080x1620 final output; full subject silhouette visible, no cropping; central safe area stays quiet for Flutter text and badges
Safe area: keep x=18% to 82% and y=38% to 74% low-detail and free of the guardian face, lantern core, seals, readable marks, or high-contrast sparks
Lighting/mood: gentle, warm, intimate, safe, reassuring
Color palette: coral, rose red, amber, peach gold, muted violet shadows
Materials/textures: lantern paper, silk, ember dust, brushed gold, hanji grain
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, non-human spirit form, no realistic human face, no animal mascot
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, flashy arcade glow, fire hazard realism, horror, readable symbols
```

Post-processing and QA:
- Keep the artwork opaque.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Confirm the guardian is not cropped and the central overlay area remains usable.

# CARD-GUARD-METAL-YIN Prompt Spec

Asset contract:
- Asset ID: CARD-GUARD-METAL-YIN
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is opaque reward card art.
- Role: card art for the metal yin guardian, used in free collection and reward flows.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque guardian reward card art, vertical 2:3
Primary request: create a card illustration for the metal yin frost-bell guardian, representing refinement, listening, and quiet clarity
Scene/backdrop: moonlit silver card world with frost mist, pearl glow, brushed metal patterns, and soft bell resonance
Subject: elegant non-human frost-bell guardian with small silver bell halo, pearl mask-like face shape, and soft metal ribbons, placed in the upper third and side-framed by frost arcs
Style/medium: high-end mobile card illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical 2:3 card art designed for 1080x1620 final output; full subject silhouette visible, no cropping; central safe area stays quiet for Flutter text and badges
Safe area: keep x=18% to 82% and y=38% to 74% low-detail and free of the guardian face, bell halo, seals, readable marks, or harsh reflections
Lighting/mood: refined, quiet, lucid, cool, reassuring
Color palette: pearl white, silver, cool gray, pale gold, faint blue accent
Materials/textures: frost, brushed metal, mother-of-pearl, silk ribbon, hanji grain
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, non-human spirit form, no realistic human face, no animal mascot, no violent weapon scene
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, battle-card aggression, chrome clutter, readable symbols
```

Post-processing and QA:
- Keep the artwork opaque.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Confirm the guardian is not cropped and the central overlay area remains usable.

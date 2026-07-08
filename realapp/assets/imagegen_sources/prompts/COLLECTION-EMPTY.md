# COLLECTION-EMPTY Prompt Spec

Asset contract:
- Asset ID: COLLECTION-EMPTY
- Final app output: 1920x1080, horizontal 16:9.
- Transparency: Not required. This is an opaque empty-state illustration.
- Role: empty collection illustration shown before the user has many cards.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque collection empty-state illustration, horizontal 16:9
Primary request: create a warm empty collection scene for the Ohaeng Guardians card archive before many cards are unlocked
Scene/backdrop: calm archive shelf with five subtle elemental alcoves, a few soft blank card silhouettes, folded silk, hanji texture, and quiet starlight
Subject: inviting empty display space that suggests future free discoveries without showing store packs, commerce objects, or scarcity pressure
Style/medium: high-end mobile app illustration, Korean-inspired fantasy wellness, painterly 3D hybrid finish
Composition/framing: horizontal 16:9 panel background designed for 1920x1080 final output; leave a large clean center-left safe area for Flutter empty-state text and CTA; keep decorative cards and shelves around edges
Safe area: keep x=18% to 62% and y=24% to 72% low-detail, softly lit, and free of focal objects, seals, readable marks, or bright badge shapes
Lighting/mood: welcoming, calm, hopeful, gentle first-step energy
Color palette: deep navy, warm ivory, muted jade, soft gold, coral and sky-blue elemental accents
Materials/textures: hanji paper, silk, jade, brushed metal, soft wood, starlight dust
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 16:9 master; final derivative must be exactly 1920x1080 without stretching
Constraints: no chroma-key background, no alpha requirement, no watermark, no human face, no animals, no privacy data, no app UI baked into the image
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, empty sadness, horror, clutter, readable symbols
```

Post-processing and QA:
- Keep the illustration opaque.
- Final derivative must be exactly 1920x1080.
- Preserve the 16:9 ratio; if the generated source is not 16:9, regenerate rather than stretching.
- Confirm Flutter empty-state copy and CTA can sit over the center-left safe area.

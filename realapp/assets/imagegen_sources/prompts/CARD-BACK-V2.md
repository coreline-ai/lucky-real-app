# CARD-BACK-V2 Prompt Spec

Asset contract:
- Asset ID: CARD-BACK
- Version intent: Full HD V2 upgrade prompt for `card_back_1080x1620_v2.png`
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Not required. This is an opaque full-card design.
- Role: unrevealed card back for free collection and reward flows.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: opaque mobile collectible card back, vertical 2:3
Primary request: create a friendly unrevealed card back design for Ohaeng Guardians cards
Scene/backdrop: full-card decorative design with no external scene and no chroma-key background
Subject: centered five-elements circular crest, subtle guardian aura, restrained border, soft protective pattern
Style/medium: high-end mobile card UI illustration, Korean-inspired fantasy wellness, painterly 3D hybrid finish
Composition/framing: vertical 2:3 card back designed for 1080x1620 final output; symmetrical silhouette; keep the center calm enough for optional Flutter lock or status badge overlay
Safe area: keep x=22% to 78% and y=34% to 68% low-detail, with a gentle matte glow rather than busy symbols or high-contrast marks
Lighting/mood: calm mystery, safe anticipation, warm discovery, not gambling-like
Color palette: deep navy, muted jade, soft gold, silver, small coral and sky-blue accents
Materials/textures: silk, hanji paper grain, jade glow, brushed metal, subtle constellation dust
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: no watermark, no readable symbols that resemble letters or numbers, no commerce marks, no tier or rarity marks, no card-pack commerce framing
Avoid: playing-card gambling deck styling, random-draw machine cues, store-pack cues, scarcity pressure, flashy arcade lighting, horror, clutter, aggressive contrast
```

Post-processing and QA:
- Keep the card back opaque; do not perform chroma-key or alpha removal.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- Confirm there is no baked text and that an optional Flutter badge remains readable over the calm central area.

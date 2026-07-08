# CARD-FRAME-COMMON-V2 Prompt Spec

Asset contract:
- Asset ID: CARD-FRAME-COMMON
- Version intent: Full HD V2 upgrade prompt for `card_frame_common_1080x1620_v2.png`
- Final app output: 1080x1620, vertical 2:3.
- Transparency: Required. Generate on flat chroma-key, then remove the chroma-key to alpha.
- Role: reusable common card frame overlay for guardian, element, and reward cards.

Image generation prompt:
```text
Use case: stylized-concept
Asset type: transparent-compatible mobile collectible card frame, vertical 2:3
Primary request: create a clean common Ohaeng Guardians card frame for a warm five-elements wellness app
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for background removal
Subject: ornate but restrained vertical card border, subtle five-element motifs, soft rounded inner corners, calm reward-card polish
Style/medium: high-end mobile game UI asset, Korean-inspired decorative frame, painterly 3D hybrid finish, polished fantasy wellness
Composition/framing: vertical 2:3 card frame designed for 1080x1620 final output; frame occupies the outer border only; keep a clear central safe area for Flutter-rendered card art, text, and badges
Safe area: keep x=18% to 82% and y=25% to 74% open, simple, and low-detail; do not place symbols, crests, seals, faces, readable marks, or bright focal effects inside this area
Lighting/mood: elegant, calm, collectible, reassuring, not aggressive or sales-like
Color palette: soft gold, muted jade, deep navy, subtle silver, tiny coral and sky-blue five-element accents
Materials/textures: silk trim, jade inlay, brushed metal, hanji paper edge texture, faint starlight particles on the border only
Text: no text, no letters, no numbers, no UI labels, no logos
Resolution intent: generate the highest available 2:3 master; final derivative must be exactly 1080x1620 without stretching
Constraints: one uniform #00ff00 background outside the frame; no shadow on the chroma-key background; no floor plane; no reflections; no #00ff00 inside the frame artwork; crisp frame edges for alpha extraction
Avoid: store-pack cues, random-draw machine cues, gambling table cues, rarity pressure, commerce marks, tier labels, neon arcade-prize styling, clutter, horror, occult fear, watermark
```

Post-processing and QA:
- Remove the #00ff00 chroma-key background to alpha.
- Final file must be RGBA or equivalent alpha-capable PNG/WebP.
- Final derivative must be exactly 1080x1620.
- Preserve the 2:3 ratio; if the generated source is not 2:3, regenerate rather than stretching.
- After alpha removal, verify the central safe area remains visually quiet and usable under Flutter text and badges.

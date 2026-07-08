# GUARD-FIRE-YANG-V2

Asset id: GUARD-FIRE-YANG
Status: Full HD upgrade from existing yang v1
Final app output: 2048x2048 transparent cutout
Required source shape: square 1:1, designed for 2048x2048 final output
Chroma-key color: pure green #00ff00

## Imagegen Prompt

Use case: stylized-concept
Asset type: square 1:1 transparent character cutout for mobile app guardian
Primary request: create an upgraded fire-element yang guardian spirit representing expression, courage, and warm vitality
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for alpha removal
Subject: elegant non-human solar flame guardian, full body visible, lantern-like glowing core, ember hair shape, flowing flame ribbons, open heroic posture, safe warm energy, friendly but not childish
Style/medium: high-quality mobile game character illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: centered 3/4 view, generous transparent-safe padding, full body including flame tips and ribbons fully inside the frame, no crop-critical edges, crisp readable silhouette
Lighting/mood: bright, warm, encouraging, energetic but gentle
Color palette: coral, warm red, orange gold, soft plum shadow, pale amber highlights
Materials/textures: flame ribbon, lantern glass, glowing silk, ember particles
Chroma-key requirements: the background must be one perfectly uniform #00ff00 field with no gradients, shadows, floor plane, texture, reflections, or lighting variation; do not use #00ff00 anywhere in the subject, highlights, particles, or rim light
Text: no letters, no numbers, no UI labels, no watermark
Safety constraints: no personal data, no birth details, no names, no commercial cues, no frightening imagery
Resolution intent: generate the highest-detail square master available; final selected cutout must be true 2048x2048 and must not be accepted as a simple enlargement of a 1024 source
Avoid: destructive fire, realistic human face, plastic toy look, clutter, background scenery, cast shadow, contact shadow, reflection, cropped flame tips, cropped feet, muddy key-color edges

## Post-Processing Contract

- Remove the #00ff00 chroma-key background into alpha.
- Preserve aspect ratio with contain resize, then pad transparently to exactly 2048x2048.
- Save the upgraded master candidate as `realapp/assets/imagegen_sources/masters/guardian_fire_yang_master_v2.png`.
- Save the final app cutout as `realapp/assets/images/guardians/guardian_fire_yang_idle_2048_v2.png`.
- Reject if any body part, flame tip, ribbon, ember, glow edge, or silhouette detail touches a crop-critical edge.
- Reject if green fringe remains after alpha removal.

# GUARD-EARTH-YANG-V2

Asset id: GUARD-EARTH-YANG
Status: Full HD upgrade from existing yang v1
Final app output: 2048x2048 transparent cutout
Required source shape: square 1:1, designed for 2048x2048 final output
Chroma-key color: pure green #00ff00

## Imagegen Prompt

Use case: stylized-concept
Asset type: square 1:1 transparent character cutout for mobile app guardian
Primary request: create an upgraded earth-element yang guardian spirit representing stability, care, and grounded strength
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for alpha removal
Subject: elegant non-human mountain guardian, full body visible, sturdy rounded silhouette, ceramic chest plate, small floating stone halo, warm caring presence, steady protective posture
Style/medium: high-quality mobile game character illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: centered 3/4 view, generous transparent-safe padding, full body including stone halo and feet fully inside the frame, no crop-critical edges, crisp readable silhouette
Lighting/mood: warm, stable, reassuring, grounded
Color palette: ochre, clay, warm gold, beige, muted umber, ivory highlights
Materials/textures: ceramic glaze, mountain stone, soil grain, soft woven cloth, subtle celadon crackle without saturated green
Chroma-key requirements: the background must be one perfectly uniform #00ff00 field with no gradients, shadows, floor plane, texture, reflections, or lighting variation; do not use #00ff00 anywhere in the subject, highlights, particles, or rim light
Text: no letters, no numbers, no UI labels, no watermark
Safety constraints: no personal data, no birth details, no names, no commercial cues, no frightening imagery
Resolution intent: generate the highest-detail square master available; final selected cutout must be true 2048x2048 and must not be accepted as a simple enlargement of a 1024 source
Avoid: aggressive stone monster, realistic human face, plastic toy look, clutter, background scenery, cast shadow, contact shadow, reflection, cropped halo, cropped feet, muddy key-color edges

## Post-Processing Contract

- Remove the #00ff00 chroma-key background into alpha.
- Preserve aspect ratio with contain resize, then pad transparently to exactly 2048x2048.
- Save the upgraded master candidate as `realapp/assets/imagegen_sources/masters/guardian_earth_yang_master_v2.png`.
- Save the final app cutout as `realapp/assets/images/guardians/guardian_earth_yang_idle_2048_v2.png`.
- Reject if any body part, stone halo, ceramic edge, glow edge, or silhouette detail touches a crop-critical edge.
- Reject if green fringe remains after alpha removal.

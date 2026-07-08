# GUARD-WATER-YIN

Asset id: GUARD-WATER-YIN
Status: New Full HD guardian asset
Final app output: 2048x2048 transparent cutout
Required source shape: square 1:1, designed for 2048x2048 final output
Chroma-key color: pure green #00ff00, deliberately not blue because the subject is blue

## Imagegen Prompt

Use case: stylized-concept
Asset type: square 1:1 transparent character cutout for mobile app guardian
Primary request: create a water-element yin guardian spirit representing moonlit rest, intuition, quiet flow, and emotional recovery
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for alpha removal
Subject: elegant non-human moon-spring guardian, full body visible, small crescent basin core, mist-like lower body, gentle droplet ornaments, calm listening posture, friendly but not childish
Style/medium: high-quality mobile game character illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: centered 3/4 view, generous transparent-safe padding, full body including crescent basin and mist curves fully inside the frame, no crop-critical edges, crisp readable silhouette
Lighting/mood: moonlit, serene, restorative, quiet, trustworthy
Color palette: midnight blue, soft cyan, indigo, silver, pearl highlights; avoid saturated green on the subject
Materials/textures: still water, mist, moon pearl, translucent silk, faint ripple highlights
Chroma-key requirements: the background must be one perfectly uniform #00ff00 field with no gradients, shadows, floor plane, texture, reflections, or lighting variation; do not use #00ff00 anywhere in the subject, highlights, particles, or rim light
Text: no letters, no numbers, no UI labels, no watermark
Safety constraints: no personal data, no birth details, no names, no commercial cues, no frightening imagery
Resolution intent: generate the highest-detail square master available; final selected cutout must be true 2048x2048
Avoid: flood danger, realistic human face, plastic toy look, clutter, background scenery, cast shadow, contact shadow, reflection, cropped crescent basin, cropped mist curve, muddy key-color edges

## Post-Processing Contract

- Remove the #00ff00 chroma-key background into alpha.
- Preserve aspect ratio with contain resize, then pad transparently to exactly 2048x2048.
- Save the master candidate as `realapp/assets/imagegen_sources/masters/guardian_water_yin_master_v1.png`.
- Save the final app cutout as `realapp/assets/images/guardians/guardian_water_yin_idle_2048_v1.png`.
- Reject if any body part, crescent basin, mist curve, droplet ornament, glow edge, or silhouette detail touches a crop-critical edge.
- Reject if green fringe remains after alpha removal.

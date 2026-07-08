# GUARD-WATER-YANG-V2

Asset id: GUARD-WATER-YANG
Status: Full HD upgrade from existing yang v1
Final app output: 2048x2048 transparent cutout
Required source shape: square 1:1, designed for 2048x2048 final output
Chroma-key color: pure green #00ff00, deliberately not blue because the subject is blue

## Imagegen Prompt

Use case: stylized-concept
Asset type: square 1:1 transparent character cutout for mobile app guardian
Primary request: create an upgraded water-element yang guardian spirit representing flow, resilience, and bright intuition
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for alpha removal
Subject: elegant non-human wave guardian, full body visible, flowing water cloak, moon pearl core, arcing wave crest, dynamic but gentle posture, friendly but not childish
Style/medium: high-quality mobile game character illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: centered 3/4 view, generous transparent-safe padding, full body including wave crest and cloak edges fully inside the frame, no crop-critical edges, crisp readable silhouette
Lighting/mood: calm, flowing, hopeful, refreshing, resilient
Color palette: deep blue, moonlit cyan, indigo, silver, pearl highlights; avoid saturated green on the subject
Materials/textures: water ripple, mist, moon pearl, translucent silk, soft foam highlights
Chroma-key requirements: the background must be one perfectly uniform #00ff00 field with no gradients, shadows, floor plane, texture, reflections, or lighting variation; do not use #00ff00 anywhere in the subject, highlights, particles, or rim light
Text: no letters, no numbers, no UI labels, no watermark
Safety constraints: no personal data, no birth details, no names, no commercial cues, no frightening imagery
Resolution intent: generate the highest-detail square master available; final selected cutout must be true 2048x2048 and must not be accepted as a simple enlargement of a 1024 source
Avoid: flood danger, realistic human face, plastic toy look, clutter, background scenery, cast shadow, contact shadow, reflection, cropped wave crest, cropped cloak edge, muddy key-color edges

## Post-Processing Contract

- Remove the #00ff00 chroma-key background into alpha.
- Preserve aspect ratio with contain resize, then pad transparently to exactly 2048x2048.
- Save the upgraded master candidate as `realapp/assets/imagegen_sources/masters/guardian_water_yang_master_v2.png`.
- Save the final app cutout as `realapp/assets/images/guardians/guardian_water_yang_idle_2048_v2.png`.
- Reject if any body part, wave crest, cloak edge, pearl detail, glow edge, or silhouette detail touches a crop-critical edge.
- Reject if green fringe remains after alpha removal.

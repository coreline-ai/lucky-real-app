# GUARD-WOOD-YANG-V2

Asset id: GUARD-WOOD-YANG
Status: Full HD upgrade from existing yang v1
Final app output: 2048x2048 transparent cutout
Required source shape: square 1:1, designed for 2048x2048 final output
Chroma-key color: pure magenta #ff00ff, chosen to avoid the green wood subject

## Imagegen Prompt

Use case: stylized-concept
Asset type: square 1:1 transparent character cutout for mobile app guardian
Primary request: create an upgraded wood-element yang guardian spirit representing growth, planning, and bright vitality
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for alpha removal
Subject: elegant non-human sprout guardian, full body visible, leaf crown, small branch staff, jade glow, confident gentle posture, friendly but not childish
Style/medium: high-quality mobile game character illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: centered 3/4 view, generous transparent-safe padding, full body including leaf tips and staff fully inside the frame, no crop-critical edges, crisp readable silhouette
Lighting/mood: soft luminous, lively, hopeful, reassuring
Color palette: emerald, fresh green, pale jade, dew highlights, restrained warm gold accents
Materials/textures: leaves, dew, soft bark, polished jade, subtle hanji grain on cloth details
Chroma-key requirements: the background must be one perfectly uniform #ff00ff field with no gradients, shadows, floor plane, texture, reflections, or lighting variation; do not use #ff00ff anywhere in the subject, highlights, particles, or rim light
Text: no letters, no numbers, no UI labels, no watermark
Safety constraints: no personal data, no birth details, no names, no commercial cues, no frightening imagery
Resolution intent: generate the highest-detail square master available; final selected cutout must be true 2048x2048 and must not be accepted as a simple enlargement of a 1024 source
Avoid: realistic human face, plastic toy look, clutter, background scenery, cast shadow, contact shadow, reflection, cropped head, cropped feet, cropped staff, muddy key-color edges

## Post-Processing Contract

- Remove the #ff00ff chroma-key background into alpha.
- Preserve aspect ratio with contain resize, then pad transparently to exactly 2048x2048.
- Save the upgraded master candidate as `realapp/assets/imagegen_sources/masters/guardian_wood_yang_master_v2.png`.
- Save the final app cutout as `realapp/assets/images/guardians/guardian_wood_yang_idle_2048_v2.png`.
- Reject if any body part, leaf tip, staff tip, glow edge, or silhouette detail touches a crop-critical edge.
- Reject if magenta fringe remains after alpha removal.

# GUARD-METAL-YANG-V2

Asset id: GUARD-METAL-YANG
Status: Full HD upgrade from existing yang v1
Final app output: 2048x2048 transparent cutout
Required source shape: square 1:1, designed for 2048x2048 final output
Chroma-key color: pure green #00ff00

## Imagegen Prompt

Use case: stylized-concept
Asset type: square 1:1 transparent character cutout for mobile app guardian
Primary request: create an upgraded metal-element yang guardian spirit representing clarity, focus, and refined courage
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for alpha removal
Subject: elegant non-human silver guardian, full body visible, crescent armor motifs, crystal bell core, curved light fins suggesting precision without violence, poised focused posture
Style/medium: high-quality mobile game character illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: centered 3/4 view, generous transparent-safe padding, full body including crescent tips and light fins fully inside the frame, no crop-critical edges, crisp readable silhouette
Lighting/mood: clear, elegant, calm, focused, brave without aggression
Color palette: silver white, pale gold, cool gray, pearl, deep navy accents
Materials/textures: brushed metal, frost, crystal, silk, polished mother-of-pearl
Chroma-key requirements: the background must be one perfectly uniform #00ff00 field with no gradients, shadows, floor plane, texture, reflections, or lighting variation; do not use #00ff00 anywhere in the subject, highlights, particles, or rim light
Text: no letters, no numbers, no UI labels, no watermark
Safety constraints: no personal data, no birth details, no names, no commercial cues, no frightening imagery
Resolution intent: generate the highest-detail square master available; final selected cutout must be true 2048x2048 and must not be accepted as a simple enlargement of a 1024 source
Avoid: violent weapon pose, realistic human face, plastic toy look, clutter, background scenery, cast shadow, contact shadow, reflection, cropped crescent tip, cropped light fin, muddy key-color edges

## Post-Processing Contract

- Remove the #00ff00 chroma-key background into alpha.
- Preserve aspect ratio with contain resize, then pad transparently to exactly 2048x2048.
- Save the upgraded master candidate as `realapp/assets/imagegen_sources/masters/guardian_metal_yang_master_v2.png`.
- Save the final app cutout as `realapp/assets/images/guardians/guardian_metal_yang_idle_2048_v2.png`.
- Reject if any body part, crescent tip, light fin, crystal detail, glow edge, or silhouette detail touches a crop-critical edge.
- Reject if green fringe remains after alpha removal.

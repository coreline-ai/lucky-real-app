# GUARD-WOOD-YIN

Asset id: GUARD-WOOD-YIN
Status: New Full HD guardian asset
Final app output: 2048x2048 transparent cutout
Required source shape: square 1:1, designed for 2048x2048 final output
Chroma-key color: pure magenta #ff00ff, chosen to avoid the green wood subject

## Imagegen Prompt

Use case: stylized-concept
Asset type: square 1:1 transparent character cutout for mobile app guardian
Primary request: create a wood-element yin guardian spirit representing quiet growth, shade, patience, and gentle recovery
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for alpha removal
Subject: elegant non-human forest-shade guardian, full body visible, soft leaf mantle, curved root-like lower body, small moonlit seed charm, calm protective posture, friendly but not childish
Style/medium: high-quality mobile game character illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: centered 3/4 view, generous transparent-safe padding, full body including leaf mantle and root curves fully inside the frame, no crop-critical edges, crisp readable silhouette
Lighting/mood: soft moonlit glow, calm, restorative, trustworthy
Color palette: deep forest green, teal shadow, pale jade, muted mint, tiny warm pearl highlights
Materials/textures: leaf veins, moss-like softness without saturated key color, dewdrops, smooth jade, subtle silk ribbon
Chroma-key requirements: the background must be one perfectly uniform #ff00ff field with no gradients, shadows, floor plane, texture, reflections, or lighting variation; do not use #ff00ff anywhere in the subject, highlights, particles, or rim light
Text: no letters, no numbers, no UI labels, no watermark
Safety constraints: no personal data, no birth details, no names, no commercial cues, no frightening imagery
Resolution intent: generate the highest-detail square master available; final selected cutout must be true 2048x2048
Avoid: realistic human face, plastic toy look, clutter, background scenery, cast shadow, contact shadow, reflection, cropped head, cropped feet, cropped leaf mantle, muddy key-color edges

## Post-Processing Contract

- Remove the #ff00ff chroma-key background into alpha.
- Preserve aspect ratio with contain resize, then pad transparently to exactly 2048x2048.
- Save the master candidate as `realapp/assets/imagegen_sources/masters/guardian_wood_yin_master_v1.png`.
- Save the final app cutout as `realapp/assets/images/guardians/guardian_wood_yin_idle_2048_v1.png`.
- Reject if any body part, leaf mantle, root curve, charm, glow edge, or silhouette detail touches a crop-critical edge.
- Reject if magenta fringe remains after alpha removal.

# GUARD-EARTH-YIN

Asset id: GUARD-EARTH-YIN
Status: New Full HD guardian asset
Final app output: 2048x2048 transparent cutout
Required source shape: square 1:1, designed for 2048x2048 final output
Chroma-key color: pure green #00ff00

## Imagegen Prompt

Use case: stylized-concept
Asset type: square 1:1 transparent character cutout for mobile app guardian
Primary request: create an earth-element yin guardian spirit representing quiet care, storage, patience, and steady nourishment
Scene/backdrop: perfectly flat solid #00ff00 chroma-key background for alpha removal
Subject: elegant non-human ceramic guardian, full body visible, rounded porcelain-and-clay form, small bowl-shaped charm, soft layered earth robes, calm nurturing posture, friendly but not childish
Style/medium: high-quality mobile game character illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: centered 3/4 view, generous transparent-safe padding, full body including bowl charm and robe hem fully inside the frame, no crop-critical edges, crisp readable silhouette
Lighting/mood: soft, warm, safe, grounded, restorative
Color palette: ivory, clay beige, warm ochre, soft terracotta, pale gold highlights, muted umber shadows
Materials/textures: porcelain glaze, clay, soft woven cloth, soil grain, subtle hanji paper detail
Chroma-key requirements: the background must be one perfectly uniform #00ff00 field with no gradients, shadows, floor plane, texture, reflections, or lighting variation; do not use #00ff00 anywhere in the subject, highlights, particles, or rim light
Text: no letters, no numbers, no UI labels, no watermark
Safety constraints: no personal data, no birth details, no names, no commercial cues, no frightening imagery
Resolution intent: generate the highest-detail square master available; final selected cutout must be true 2048x2048
Avoid: aggressive stone monster, realistic human face, plastic toy look, clutter, background scenery, cast shadow, contact shadow, reflection, cropped charm, cropped robe hem, muddy key-color edges

## Post-Processing Contract

- Remove the #00ff00 chroma-key background into alpha.
- Preserve aspect ratio with contain resize, then pad transparently to exactly 2048x2048.
- Save the master candidate as `realapp/assets/imagegen_sources/masters/guardian_earth_yin_master_v1.png`.
- Save the final app cutout as `realapp/assets/images/guardians/guardian_earth_yin_idle_2048_v1.png`.
- Reject if any body part, bowl charm, robe hem, glow edge, or silhouette detail touches a crop-critical edge.
- Reject if green fringe remains after alpha removal.

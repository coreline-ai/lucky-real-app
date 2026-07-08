# Agent 5 Work Order: History, Settings, Errors, Element Derivatives

## Scope

Create imagegen prompt specs only. Do not generate images in this slice. Do not edit `realapp/assets/ASSET_MANIFEST.md`, existing `ELEMENT-BG-*.md` prompt files, or prompt files outside the Agent 5 owned list.

Owned prompt specs created:

- `HISTORY-001.md`: vertical 9:16, final `1080x1920`
- `HISTORY-002.md`: horizontal 16:9, final `1920x1080`
- `SETTINGS-001.md`: vertical 9:16, final `1080x1920`
- `SETTINGS-002.md`: horizontal 16:9, final `1920x1080`
- `SETTINGS-004.md`: horizontal 16:9, final `1920x1080`
- `ERROR-ENGINE.md`: horizontal 16:9, final `1920x1080`

## Global Prompt Contract

- No image text, no UI labels, no watermark, no logos.
- No personal data, birth dates, birth times, names, IDs, or readable documents.
- No monetization cues: no ads, paid plans, premium badges, price tags, purchase buttons, subscription imagery, or card-pack sales framing.
- No fear-based warning imagery: no curses, skulls, red danger panels, panic symbols, threatening warnings, or deterministic bad-fate imagery.
- Preserve Flutter text safe areas. Image content must leave low-detail negative space for headers, body text, CTAs, calendar cells, settings rows, and bottom navigation.
- Final derivatives must use ratio-preserving resize plus safe crop or padding. Never stretch, squeeze, or mark an upscaled-only asset as Full HD.

## Element Derivative Output Contract

Use the existing five vertical element backgrounds as style references only. Do not modify their prompt files in this slice.

Required derivative outputs for each element:

- Card derivative: vertical 2:3 card background, designed for `1080x1620` final output.
- Horizontal derivative: horizontal 16:9 panel background, designed for `1920x1080` final output.

For 2:3 card derivatives, a ratio-preserving crop from an approved high-resolution vertical master is acceptable only if the result keeps a clean center for Flutter card contents and does not crop important motifs. For 16:9 horizontal derivatives, prefer regeneration or outpainting/recomposition from the original prompt direction; a narrow vertical background should not be stretched or severely cropped into landscape.

## Element Derivative Prompt Specs

### ELEMENT-BG-WOOD card derivative

Use case: stylized-concept
Asset type: reusable wood-element card background, vertical 2:3 card art, designed for 1080x1620 final output
Primary request: create a wood-element card background representing growth, planning, renewal, and gentle expansion
Scene/backdrop: misty jade grove atmosphere with abstract leaf veins, young branches, dew, and soft starlight
Subject: elemental wood energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical 2:3, clear low-detail center for Flutter card art and labels, softly decorated border zones, safe top and bottom
Lighting/mood: fresh morning light, calm, hopeful, not scary
Color palette: emerald, fresh green, pale jade, soft teal, tiny warm gold highlights
Materials/textures: leaves, dew, soft bark, jade, hanji grain
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: dense jungle clutter, neon overload, scary forest, readable symbols, animal mascots, human faces

### ELEMENT-BG-WOOD horizontal derivative

Use case: stylized-concept
Asset type: reusable wood-element panel background, horizontal 16:9 panel background, designed for 1920x1080 final output
Primary request: create a wide wood-element panel background for routine, fortune, or settings panels
Scene/backdrop: expansive misty jade grove with abstract leaf-vein patterns, young branches, dew, and soft starlight
Subject: elemental wood energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: horizontal 16:9, broad clean center-left area for Flutter text and controls, decorative energy kept to the edges
Lighting/mood: fresh morning light, calm, hopeful, not scary
Color palette: emerald, fresh green, pale jade, soft teal, tiny warm gold highlights
Materials/textures: leaves, dew, soft bark, jade, hanji grain
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: stretched portrait crop, dense jungle clutter, neon overload, scary forest, readable symbols, animal mascots, human faces

### ELEMENT-BG-FIRE card derivative

Use case: stylized-concept
Asset type: reusable fire-element card background, vertical 2:3 card art, designed for 1080x1620 final output
Primary request: create a fire-element card background representing expression, vitality, warmth, and courageous movement
Scene/backdrop: soft lantern glow, coral flame ribbons, warm sunset haze, and subtle constellation sparks on paper texture
Subject: elemental fire energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical 2:3, calm center safe area for Flutter card contents, flame motion kept elegant and away from text zones
Lighting/mood: warm, lively, encouraging, not dangerous, not scary
Color palette: coral, vermilion, warm gold, soft peach, deep muted navy accents
Materials/textures: lantern light, silk, ember particles, hanji paper, subtle ink
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: destructive fire, emergency warning look, smoke disaster, aggressive red screens, readable symbols, human faces

### ELEMENT-BG-FIRE horizontal derivative

Use case: stylized-concept
Asset type: reusable fire-element panel background, horizontal 16:9 panel background, designed for 1920x1080 final output
Primary request: create a wide fire-element panel background for energetic but calm app content
Scene/backdrop: horizontal lantern-lit paper landscape with coral flame ribbons, warm glow, and subtle constellation sparks
Subject: elemental fire energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: horizontal 16:9, generous low-detail text safe area in the center and lower third, decorative fire kept soft at edges
Lighting/mood: warm, lively, encouraging, not dangerous, not scary
Color palette: coral, vermilion, warm gold, soft peach, deep muted navy accents
Materials/textures: lantern light, silk, ember particles, hanji paper, subtle ink
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: stretched portrait crop, destructive fire, emergency warning look, smoke disaster, aggressive red screens, readable symbols, human faces

### ELEMENT-BG-EARTH card derivative

Use case: stylized-concept
Asset type: reusable earth-element card background, vertical 2:3 card art, designed for 1080x1620 final output
Primary request: create an earth-element card background representing stability, grounding, care, and steady organization
Scene/backdrop: warm clay-toned paper landscape with soft mountain silhouettes, ceramic glaze patterns, and subtle golden dust
Subject: elemental earth energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical 2:3, stable calm center for Flutter card contents, softly layered top and bottom decorative bands
Lighting/mood: grounded, warm, safe, patient, not heavy or gloomy
Color palette: ochre, warm earth gold, beige, muted terracotta, soft jade accents
Materials/textures: clay, ceramic glaze, mountain stone, hanji grain, silk
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: barren desert, cracked disaster ground, muddy clutter, warning signage, readable symbols, human faces

### ELEMENT-BG-EARTH horizontal derivative

Use case: stylized-concept
Asset type: reusable earth-element panel background, horizontal 16:9 panel background, designed for 1920x1080 final output
Primary request: create a wide earth-element panel background for stable routine and reflection content
Scene/backdrop: calm horizontal clay-and-mountain landscape with ceramic glaze patterns, soft golden dust, and paper texture
Subject: elemental earth energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: horizontal 16:9, spacious central and lower text safe area, mountain and ceramic motifs held near the edges
Lighting/mood: grounded, warm, safe, patient, not heavy or gloomy
Color palette: ochre, warm earth gold, beige, muted terracotta, soft jade accents
Materials/textures: clay, ceramic glaze, mountain stone, hanji grain, silk
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: stretched portrait crop, barren desert, cracked disaster ground, muddy clutter, warning signage, readable symbols, human faces

### ELEMENT-BG-METAL card derivative

Use case: stylized-concept
Asset type: reusable metal-element card background, vertical 2:3 card art, designed for 1080x1620 final output
Primary request: create a metal-element card background representing clarity, focus, discernment, and clean decisions
Scene/backdrop: refined silver-white paper field with brushed metal arcs, frost-like geometry, pale gold rim light, and subtle star points
Subject: elemental metal energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical 2:3, crisp but quiet center for Flutter card contents, elegant edge highlights with no harsh glare
Lighting/mood: clear, focused, serene, trustworthy, not cold or threatening
Color palette: silver white, pearl, pale gold, mist blue, restrained deep navy accents
Materials/textures: brushed metal, frost, pearl, hanji paper, silk sheen
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: weapons, sharp threat imagery, clinical sterility, harsh glare, readable symbols, human faces

### ELEMENT-BG-METAL horizontal derivative

Use case: stylized-concept
Asset type: reusable metal-element panel background, horizontal 16:9 panel background, designed for 1920x1080 final output
Primary request: create a wide metal-element panel background for focus, judgment, and clean settings content
Scene/backdrop: horizontal silver-white paper field with brushed metal arcs, frost-like geometry, pale gold rim light, and subtle star points
Subject: elemental metal energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: horizontal 16:9, clean center-left text safe area, decorative metallic forms kept restrained along edges
Lighting/mood: clear, focused, serene, trustworthy, not cold or threatening
Color palette: silver white, pearl, pale gold, mist blue, restrained deep navy accents
Materials/textures: brushed metal, frost, pearl, hanji paper, silk sheen
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: stretched portrait crop, weapons, sharp threat imagery, clinical sterility, harsh glare, readable symbols, human faces

### ELEMENT-BG-WATER card derivative

Use case: stylized-concept
Asset type: reusable water-element card background, vertical 2:3 card art, designed for 1080x1620 final output
Primary request: create a water-element card background representing recovery, flow, rest, and emotional clarity
Scene/backdrop: moonlit blue paper atmosphere with soft ripples, mist, quiet reflected starlight, and subtle ink gradients
Subject: elemental water energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical 2:3, serene low-detail center for Flutter card contents, gentle wave detail around the frame edges
Lighting/mood: restful, flowing, gentle, hopeful, not cold or ominous
Color palette: deep blue, moon blue, pale cyan, silver white, small jade highlights
Materials/textures: water ripple, mist, moonlight, hanji paper, subtle ink
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: storm disaster, drowning imagery, dark omen, harsh black water, readable symbols, human faces

### ELEMENT-BG-WATER horizontal derivative

Use case: stylized-concept
Asset type: reusable water-element panel background, horizontal 16:9 panel background, designed for 1920x1080 final output
Primary request: create a wide water-element panel background for recovery, reflection, and quiet routine content
Scene/backdrop: expansive moonlit blue paper landscape with soft ripples, mist, reflected starlight, and subtle ink gradients
Subject: elemental water energy only, no character, no text, no readable symbols
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: horizontal 16:9, wide calm center and lower text safe area, gentle wave motion placed around edges
Lighting/mood: restful, flowing, gentle, hopeful, not cold or ominous
Color palette: deep blue, moon blue, pale cyan, silver white, small jade highlights
Materials/textures: water ripple, mist, moonlight, hanji paper, subtle ink
Text: no text
Constraints: no watermark, no UI text, no personal data, no monetization cues, no fear-based warning imagery
Avoid: stretched portrait crop, storm disaster, drowning imagery, dark omen, harsh black water, readable symbols, human faces

## QA Notes for Integration

- Confirm final pixel dimensions exactly: `1080x1920`, `1920x1080`, or `1080x1620` as assigned.
- Confirm no visible text-like artifacts, dates, names, labels, watermarks, warning icons, payment cues, or personal-data stand-ins.
- Confirm Flutter overlays remain readable in the reserved safe areas.
- Reject any derivative made by stretching a vertical source into horizontal or by upscaling a low-resolution asset without meaningful regeneration.

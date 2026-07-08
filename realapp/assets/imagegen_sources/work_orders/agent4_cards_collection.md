# Agent 4 Work Order: Cards, Collection, Rewards Prompt Specs

Status: prompt-spec slice complete; no images generated.

## Scope

Create production-ready image generation prompt specs for the Agent 4 card, collection, and reward-card assets only.

Do not edit:
- `realapp/assets/ASSET_MANIFEST.md`
- existing V1 prompt files `CARD-FRAME-COMMON.md` and `CARD-BACK.md`
- any image files
- prompt files outside the Agent 4 owned list

## Source Documents Read

- `realapp/docs/11-parallel-full-hd-imagegen-goal-prompt.md`
- `realapp/docs/10-full-hd-asset-inventory.md`
- `realapp/docs/07-imagegen-asset-plan.md`
- `realapp/docs/01-product-spec.md`
- `realapp/docs/02-ux-ia.md`

## Prompt Files Created

| Asset ID | Prompt path | Final output | Alpha |
|---|---|---:|---|
| CARD-FRAME-COMMON | `realapp/assets/imagegen_sources/prompts/CARD-FRAME-COMMON-V2.md` | 1080x1620 | Yes, after chroma-key removal |
| CARD-BACK | `realapp/assets/imagegen_sources/prompts/CARD-BACK-V2.md` | 1080x1620 | No |
| CARD-ELEMENT-WOOD | `realapp/assets/imagegen_sources/prompts/CARD-ELEMENT-WOOD.md` | 1080x1620 | No |
| CARD-ELEMENT-FIRE | `realapp/assets/imagegen_sources/prompts/CARD-ELEMENT-FIRE.md` | 1080x1620 | No |
| CARD-ELEMENT-EARTH | `realapp/assets/imagegen_sources/prompts/CARD-ELEMENT-EARTH.md` | 1080x1620 | No |
| CARD-ELEMENT-METAL | `realapp/assets/imagegen_sources/prompts/CARD-ELEMENT-METAL.md` | 1080x1620 | No |
| CARD-ELEMENT-WATER | `realapp/assets/imagegen_sources/prompts/CARD-ELEMENT-WATER.md` | 1080x1620 | No |
| CARD-GUARD-WOOD-YANG | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-WOOD-YANG.md` | 1080x1620 | No |
| CARD-GUARD-WOOD-YIN | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-WOOD-YIN.md` | 1080x1620 | No |
| CARD-GUARD-FIRE-YANG | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-FIRE-YANG.md` | 1080x1620 | No |
| CARD-GUARD-FIRE-YIN | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-FIRE-YIN.md` | 1080x1620 | No |
| CARD-GUARD-EARTH-YANG | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-EARTH-YANG.md` | 1080x1620 | No |
| CARD-GUARD-EARTH-YIN | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-EARTH-YIN.md` | 1080x1620 | No |
| CARD-GUARD-METAL-YANG | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-METAL-YANG.md` | 1080x1620 | No |
| CARD-GUARD-METAL-YIN | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-METAL-YIN.md` | 1080x1620 | No |
| CARD-GUARD-WATER-YANG | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-WATER-YANG.md` | 1080x1620 | No |
| CARD-GUARD-WATER-YIN | `realapp/assets/imagegen_sources/prompts/CARD-GUARD-WATER-YIN.md` | 1080x1620 | No |
| COLLECTION-EMPTY | `realapp/assets/imagegen_sources/prompts/COLLECTION-EMPTY.md` | 1920x1080 | No |

## Shared Production Rules

- All card assets are vertical 2:3 and designed for exact 1080x1620 final output.
- `CARD-FRAME-COMMON-V2.md` is the only Agent 4 card prompt that requires chroma-key generation and alpha removal.
- Card backs, element cards, guardian reward cards, and collection empty art are opaque and should not use chroma-key extraction.
- No prompt asks for baked text, letters, numbers, labels, logos, or personal data.
- Every card prompt reserves a low-detail central safe area for Flutter-rendered text, count/progress badges, and state badges.
- The visual direction stays in warm Ohaeng wellness fantasy and avoids store-pack, random-draw, gambling, scarcity, or tier-pressure language in the generated image.
- Generated sources with a wrong aspect ratio should be regenerated, not stretched.

## Suggested Output Filenames For Producers

- `realapp/assets/images/cards/card_frame_common_1080x1620_v2.png`
- `realapp/assets/images/cards/card_back_1080x1620_v2.png`
- `realapp/assets/images/cards/card_element_wood_1080x1620_v1.png`
- `realapp/assets/images/cards/card_element_fire_1080x1620_v1.png`
- `realapp/assets/images/cards/card_element_earth_1080x1620_v1.png`
- `realapp/assets/images/cards/card_element_metal_1080x1620_v1.png`
- `realapp/assets/images/cards/card_element_water_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_wood_yang_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_wood_yin_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_fire_yang_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_fire_yin_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_earth_yang_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_earth_yin_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_metal_yang_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_metal_yin_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_water_yang_1080x1620_v1.png`
- `realapp/assets/images/cards/card_guard_water_yin_1080x1620_v1.png`
- `realapp/assets/images/collection/collection_empty_1920x1080_v1.png`

## Handoff QA Checklist

- Verify prompt files exist before generation.
- Generate at the requested aspect ratio; reject sources that are not 2:3 for cards or 16:9 for collection.
- Produce final derivatives with exact pixel dimensions.
- Verify alpha only for `card_frame_common_1080x1620_v2.png`.
- Confirm no image contains baked text, numbers, personal information, store UI, commerce labels, or gambling/random-draw visual cues.
- Confirm central safe areas remain usable under Flutter overlays.
- Leave `ASSET_MANIFEST.md` for the QA/integration agent.

# APK Asset Optimization Report

Updated: 2026-07-08T01:48:32.525Z

## Summary

- Active runtime assets: 55
- Folder-registered PNG candidates before optimization: 79
- Unused PNG candidates excluded from APK bundle: 24 (63.6 MiB)
- Active PNG source size: 168.3 MiB
- Active WebP bundle size: 17.8 MiB
- WebP conversion savings on active assets: 150.5 MiB
- Estimated image bundle savings: 214.1 MiB
- Dimension verification: PASS

## Runtime Policy

- Flutter runtime paths use `.webp` derivatives listed individually in `realapp/pubspec.yaml`.
- PNG files remain as source/reference assets and are not registered for the APK bundle.
- Every WebP derivative must keep the same width and height as its PNG source.

## Largest Excluded PNG Candidates

| Size | Asset |
|---:|---|
| 4.4 MiB | `assets/images/guardians/guardian_water_yin_idle_2048_v1.png` |
| 4.3 MiB | `assets/images/guardians/guardian_earth_yin_idle_2048_v1.png` |
| 3.5 MiB | `assets/images/cards/card_guardian_water_yin_1080x1620_v1.png` |
| 3.5 MiB | `assets/images/cards/card_guardian_wood_yin_1080x1620_v1.png` |
| 3.5 MiB | `assets/images/cards/card_guardian_metal_yin_1080x1620_v1.png` |
| 3.4 MiB | `assets/images/guardians/guardian_metal_yin_idle_2048_v1.png` |
| 3.4 MiB | `assets/images/guardians/guardian_wood_yin_idle_2048_v1.png` |
| 3.3 MiB | `assets/images/cards/card_guardian_earth_yin_1080x1620_v1.png` |
| 3.2 MiB | `assets/images/history/history_calendar_bg_1080x1920_v1.png` |
| 3.2 MiB | `assets/images/cards/card_guardian_fire_yin_1080x1620_v1.png` |
| 3.2 MiB | `assets/images/backgrounds/fortune_work_study_bg_1920x1080_v1.png` |
| 3.1 MiB | `assets/images/guardians/guardian_fire_yin_idle_2048_v1.png` |

## Verification Failures

None.

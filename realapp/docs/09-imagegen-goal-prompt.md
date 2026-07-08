# Imagegen Asset Production GOAL Prompt

아래 프롬프트를 새 GOAL에 그대로 넣으면, 분석된 에셋 목록을 실제 고해상도 앱 에셋으로 생성하고 프로젝트에 정리하는 작업을 지시할 수 있다.

```text
realapp/docs/07-imagegen-asset-plan.md를 기준으로 오행가디언즈 Flutter 앱에 사용할 실제 고해상도 이미지 에셋을 생성해줘.

목표:
- GPT 이미지젠 스킬을 사용해서 앱 구현에 필요한 첫 배치 에셋을 실제 파일로 만든다.
- 생성된 에셋은 반드시 workspace 안의 realapp/assets/ 아래에 저장한다.
- $CODEX_HOME/generated_images 등에만 남기지 말고, 최종 선택본을 프로젝트 폴더로 복사/이동한다.
- 이미지 생성 프롬프트와 산출물 목록도 함께 문서화한다.
- 최고 해상도 생성이 불가능한 경우에도 세로 배경/공유 템플릿은 반드시 Full HD 1080x1920 앱용 파생본을 만든다.

반드시 참고할 문서:
- realapp/docs/07-imagegen-asset-plan.md
- realapp/docs/01-product-spec.md
- realapp/docs/02-ux-ia.md
- realapp/docs/04-flutter-architecture.md
- realapp/docs/05-qa-privacy-safety.md

우선 생성할 첫 배치 20개:
1. BRAND-001 앱 아이콘 심볼
2. SPLASH-001 시작 화면 배경
3. HOME-001 기본 홈 배경
4. ONB-001 오늘의 수호신 소개 배경
5. ONB-002 오행 루틴 소개 배경
6. ONB-003 도감/기록 소개 배경
7. ELEMENT-BG-WOOD 목 배경
8. ELEMENT-BG-FIRE 화 배경
9. ELEMENT-BG-EARTH 토 배경
10. ELEMENT-BG-METAL 금 배경
11. ELEMENT-BG-WATER 수 배경
12. GUARD-WOOD-YANG 목 양 수호신
13. GUARD-FIRE-YANG 화 양 수호신
14. GUARD-EARTH-YANG 토 양 수호신
15. GUARD-METAL-YANG 금 양 수호신
16. GUARD-WATER-YANG 수 양 수호신
17. CARD-FRAME-COMMON 일반 카드 프레임
18. CARD-BACK 카드 뒷면
19. SHARE-001 오늘 수호신 공유 템플릿
20. CHEM-002 케미 결과 배경

저장 구조:
- realapp/assets/imagegen_sources/prompts/
- realapp/assets/imagegen_sources/masters/
- realapp/assets/images/backgrounds/
- realapp/assets/images/guardians/
- realapp/assets/images/cards/
- realapp/assets/images/share/
- realapp/assets/images/onboarding/
- realapp/assets/images/app_icon/
- realapp/assets/images/chemistry/

생성 규칙:
- 배경/공유 템플릿은 세로 9:16 기준으로 만든다.
- 배경/공유 템플릿의 앱용 최종본은 1080x1920 이상 또는 정확히 1080x1920 PNG로 저장한다.
- 앱 아이콘은 2048x2048 PNG 앱용 파생본을 만든다.
- 카드류는 1024x1536 PNG 앱용 파생본을 만든다.
- 수호신 캐릭터는 1024x1024 이상 PNG 앱용 파생본을 만든다.
- 수호신 캐릭터와 카드 프레임은 앱 UI 합성을 고려해 투명 배경용으로 만든다.
- 투명 에셋은 imagegen 기본 경로로 생성한 뒤 chroma-key 배경 제거 helper를 사용해 alpha PNG 결과물을 만든다.
- 이미지 안에 한글/영문 텍스트를 넣지 않는다. 모든 문구는 Flutter Text로 렌더링할 예정이다.
- 생년월일, 출생시간, 개인정보가 이미지에 들어가면 안 된다.
- 공포, 저주, 무속 과잉, 도박/가챠/카지노, 유료 카드팩처럼 보이는 표현은 금지한다.
- 스타일은 "고급 모바일 게임 UI + 웰니스 앱 + 동양 판타지" 톤으로 통일한다.
- 오행별 색상 체계를 유지하되, 앱 전체가 한 가지 색만 반복되는 단조로운 팔레트가 되지 않게 한다.

각 에셋마다 해야 할 일:
1. realapp/docs/07-imagegen-asset-plan.md의 기준에 맞춰 최종 이미지젠 프롬프트를 작성한다.
2. 프롬프트를 realapp/assets/imagegen_sources/prompts/<asset-id>.md에 저장한다.
3. imagegen 스킬로 이미지를 생성한다.
4. 결과를 시각적으로 검사한다.
5. 프로젝트 안의 적절한 assets 폴더로 저장한다.
6. 필요한 경우 master 원본과 앱용 파생본을 나눈다.
7. 파일명은 문서의 규칙을 따른다: <screen-or-domain>_<asset-name>_<variant>_<size>_v1.<ext>
8. 생성 결과 목록을 realapp/assets/ASSET_MANIFEST.md에 기록한다.

검증:
- 모든 첫 배치 20개 asset id가 ASSET_MANIFEST.md에 있어야 한다.
- 각 manifest 항목에는 asset id, 파일 경로, 용도, 생성 프롬프트 파일 경로, 해상도, 투명 여부가 있어야 한다.
- 수호신/카드 프레임처럼 투명이 필요한 에셋은 alpha 채널 여부를 확인한다.
- 배경 이미지는 Flutter 텍스트를 올릴 수 있는 여백이 있어야 한다.
- rg로 광고/결제/유료/프리미엄/구독/가격표 같은 수익화성 문구가 이미지 프롬프트에 잘못 들어가지 않았는지 확인한다.
- 생성이 실패하거나 품질이 낮은 에셋은 재생성하고, 폐기된 파일은 manifest에 최종본으로 기록하지 않는다.

완료 조건:
- realapp/assets/ 아래에 첫 배치 20개 최종 에셋이 저장되어 있다.
- realapp/assets/imagegen_sources/prompts/ 아래에 20개 프롬프트 문서가 있다.
- realapp/assets/ASSET_MANIFEST.md가 생성되어 있다.
- 수익화/광고/결제/유료 카드팩 방향의 표현이 없다.
- 최종 답변에는 생성된 파일 경로, 검증 결과, 재생성이 필요한 후보가 있다면 그 목록을 요약한다.
```


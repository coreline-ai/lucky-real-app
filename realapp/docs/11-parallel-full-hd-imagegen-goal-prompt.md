# Parallel Full HD Imagegen GOAL Prompt

아래 프롬프트를 GOAL에 그대로 넣어서 병렬 에이전트 기반 에셋 제작을 지시한다.

```text
오행가디언즈 Flutter 앱의 전체 이미지 에셋을 병렬 에이전트로 생성/정리해줘.

가장 중요한 조건:
- 모든 에셋은 realapp/docs/10-full-hd-asset-inventory.md의 "최종 앱용 해상도"를 반드시 맞춘다.
- 해상도가 맞지 않거나, 이미지가 깨지거나, 찌그러지거나, 인위적으로 늘어난 결과물은 실패로 처리한다.
- 비율이 맞지 않는 이미지를 width/height로 강제 늘려서 저장하지 않는다.
- 최종본은 반드시 비율 보존 리사이즈 + 안전 crop 또는 안전 padding으로 만든다.
- 수호신/심볼/카드 프레임 같은 투명 에셋은 alpha 채널이 반드시 있어야 한다.
- $CODEX_HOME/generated_images에만 남기지 말고 최종 선택본을 realapp/assets/ 아래에 저장한다.

반드시 참고할 문서:
- realapp/docs/10-full-hd-asset-inventory.md
- realapp/docs/07-imagegen-asset-plan.md
- realapp/docs/08-phase1-dev-plan.md
- realapp/docs/01-product-spec.md
- realapp/docs/02-ux-ia.md
- realapp/docs/04-flutter-architecture.md
- realapp/docs/05-qa-privacy-safety.md
- realapp/assets/ASSET_MANIFEST.md

고정 해상도 계약:
- 세로 전체 화면 배경: 1080x1920, 9:16
- 공유/SNS 템플릿: 1080x1920, 9:16
- 가로/패널형 배경: 1920x1080, 16:9
- 2:3 카드형 에셋: 1080x1620, 2:3
- 주요 수호신/심볼 컷아웃: 2048x2048, 1:1, alpha
- 배지/작은 보상 오브젝트: 1024x1024, 1:1, alpha
- 타일/오버레이: 2048x2048, 1:1

절대 금지:
- 원본 비율과 다른 최종 해상도로 단순 stretch/scale 하기
- `sips -z <height> <width>`처럼 결과가 찌그러질 수 있는 방식으로 무비판 처리하기
- 1024x1024 수호신을 2048x2048로 단순 확대만 하고 고해상도 통과로 기록하기
- 1024x1536 카드를 1080x1620으로 단순 확대만 하고 고해상도 통과로 기록하기
- 이미지 안에 한글/영문 UI 텍스트를 굽기
- 생년월일, 출생시간, 개인정보를 이미지 안에 넣기
- 광고/결제/유료/프리미엄/구독/가격표/카드팩 구매처럼 보이는 표현
- 공포, 저주, 무속 과잉, 도박/가챠/카지노 분위기

비율/해상도 처리 규칙:
1. 이미지젠 프롬프트 단계에서 목표 비율을 명확히 쓴다.
   - 9:16 에셋: "vertical 9:16 mobile background, designed for 1080x1920 final output"
   - 16:9 에셋: "horizontal 16:9 panel background, designed for 1920x1080 final output"
   - 2:3 에셋: "vertical 2:3 card art/frame, designed for 1080x1620 final output"
   - 1:1 에셋: "square 1:1 cutout/symbol, designed for 2048x2048 final output"
2. 생성 결과의 원본 비율이 목표 비율과 크게 다르면 최종본으로 쓰지 말고 재생성한다.
3. 최종 파생본 생성 시 비율 보존 resize를 먼저 한다.
4. 배경은 비율 보존 cover resize 후 중앙 또는 안전영역 기준 crop으로 맞춘다.
5. 카드/프레임/수호신/심볼은 비율 보존 contain resize 후 투명 padding으로 맞춘다.
6. 텍스트 safe area가 잘리는 crop은 실패로 처리한다.
7. 캐릭터의 머리/발/무기/장식이 잘리는 crop은 실패로 처리한다.
8. 결과 픽셀 크기는 검증 스크립트로 확인한다. 육안 확인만으로 통과시키지 않는다.

저장 구조:
- realapp/assets/imagegen_sources/prompts/
- realapp/assets/imagegen_sources/masters/
- realapp/assets/images/backgrounds/
- realapp/assets/images/guardians/
- realapp/assets/images/cards/
- realapp/assets/images/collection/
- realapp/assets/images/share/
- realapp/assets/images/onboarding/
- realapp/assets/images/app_icon/
- realapp/assets/images/chemistry/
- realapp/assets/images/history/
- realapp/assets/images/settings/
- realapp/assets/images/effects/
- realapp/assets/images/errors/

파일명 규칙:
- <screen-or-domain>_<asset-name>_<variant>_<size>_v<version>.png
- 기존 파일을 덮어쓰지 않는다. 새 고해상도 교체본은 `_v2` 또는 정확한 새 size 표기를 사용한다.
- 예: guardian_wood_yang_idle_2048_v2.png
- 예: card_frame_common_1080x1620_v2.png
- 예: fortune_total_panel_bg_1920x1080_v1.png

작업 방식:
- 병렬 작업자는 동시에 작업해도 되지만, 각자 소유한 asset id와 폴더만 편집한다.
- 다른 작업자의 파일을 삭제, 이동, 덮어쓰기, 되돌리기 하지 않는다.
- ASSET_MANIFEST.md 최종 통합은 QA/통합 에이전트가 한다.
- 공통 해상도 검증 스크립트 또는 체크 결과는 통합 에이전트가 최종 실행한다.

병렬 에이전트 구성:

Agent 0: Asset Producer Coordinator
목표:
- realapp/docs/10-full-hd-asset-inventory.md를 기준으로 P0 missing + Upgrade 대상을 최종 작업표로 확정한다.
- 각 에이전트별 asset id, 목표 해상도, alpha 필요 여부, 저장 경로를 할당한다.
- 공통 품질 규칙과 파일명 규칙을 유지한다.
소유 경로:
- realapp/docs/11-parallel-full-hd-imagegen-goal-prompt.md는 읽기 전용
- 임시 작업표가 필요하면 realapp/assets/imagegen_sources/work_orders/ 아래에만 작성
금지:
- 최종 ASSET_MANIFEST.md 직접 덮어쓰기 금지

Agent 1: Brand, Splash, Onboarding, Home
대상:
- BRAND-002 2048x2048 alpha
- SPLASH-002 1080x1920
- SPLASH-003 2048x2048 alpha
- ONB-004 1080x1920
- HOME-004 1080x1620 alpha
- HOME-005 1920x1080
- HOME-006 1920x1080
소유 경로:
- realapp/assets/imagegen_sources/prompts/BRAND-002.md
- realapp/assets/imagegen_sources/prompts/SPLASH-002.md
- realapp/assets/imagegen_sources/prompts/SPLASH-003.md
- realapp/assets/imagegen_sources/prompts/ONB-004.md
- realapp/assets/imagegen_sources/prompts/HOME-004.md
- realapp/assets/imagegen_sources/prompts/HOME-005.md
- realapp/assets/imagegen_sources/prompts/HOME-006.md
- realapp/assets/images/app_icon/
- realapp/assets/images/backgrounds/
- realapp/assets/images/onboarding/
- realapp/assets/images/effects/
검수:
- 세로 배경은 1080x1920.
- 홈 카드 프레임은 1080x1620 alpha.
- 로딩 입자는 2048x2048 alpha.

Agent 2: Fortune and Routine Panels
대상:
- FORTUNE-001 1920x1080
- FORTUNE-002 1920x1080
- FORTUNE-003 1920x1080
- FORTUNE-004 1920x1080
- ROUTINE-001 1920x1080
- ROUTINE-002 1920x1080
- ROUTINE-003 1920x1080
- ROUTINE-004 1920x1080
- ROUTINE-005 1920x1080
- ROUTINE-006 1024x1024 alpha
소유 경로:
- realapp/assets/imagegen_sources/prompts/FORTUNE-*.md
- realapp/assets/imagegen_sources/prompts/ROUTINE-*.md
- realapp/assets/images/backgrounds/
- realapp/assets/images/effects/
검수:
- 패널형 배경은 반드시 1920x1080.
- 루틴 완료 배지는 1024x1024 alpha.
- 체크리스트와 Flutter 텍스트를 올릴 빈 공간을 확보한다.

Agent 3: Guardians Full HD Upgrade
대상:
- GUARD-WOOD-YANG 2048x2048 alpha Upgrade
- GUARD-WOOD-YIN 2048x2048 alpha
- GUARD-FIRE-YANG 2048x2048 alpha Upgrade
- GUARD-FIRE-YIN 2048x2048 alpha
- GUARD-EARTH-YANG 2048x2048 alpha Upgrade
- GUARD-EARTH-YIN 2048x2048 alpha
- GUARD-METAL-YANG 2048x2048 alpha Upgrade
- GUARD-METAL-YIN 2048x2048 alpha
- GUARD-WATER-YANG 2048x2048 alpha Upgrade
- GUARD-WATER-YIN 2048x2048 alpha
소유 경로:
- realapp/assets/imagegen_sources/prompts/GUARD-*.md
- realapp/assets/imagegen_sources/masters/guardian_*_v2.png
- realapp/assets/images/guardians/
검수:
- 최종본은 모두 2048x2048.
- alpha 채널 필수.
- 캐릭터가 잘리면 실패.
- 기존 1024 파일은 삭제하지 말고 새 v2 파일로 저장한다.

Agent 4: Cards, Collection, Rewards
대상:
- CARD-FRAME-COMMON 1080x1620 alpha Upgrade
- CARD-BACK 1080x1620 Upgrade
- CARD-ELEMENT-WOOD/FIRE/EARTH/METAL/WATER 각 1080x1620
- CARD-GUARD-<element>-<yin-yang> 10종 각 1080x1620
- COLLECTION-EMPTY 1920x1080
소유 경로:
- realapp/assets/imagegen_sources/prompts/CARD-*.md
- realapp/assets/imagegen_sources/prompts/COLLECTION-EMPTY.md
- realapp/assets/images/cards/
- realapp/assets/images/collection/
검수:
- 카드형은 반드시 1080x1620.
- 카드 중앙 텍스트 영역 확보.
- 카드 프레임 alpha 필수.
- 기존 1024x1536 파일은 삭제하지 말고 새 v2 파일로 저장한다.

Agent 5: History, Settings, Errors, Element Derivatives
대상:
- HISTORY-001 1080x1920
- HISTORY-002 1920x1080
- SETTINGS-001 1080x1920
- SETTINGS-002 1920x1080
- SETTINGS-004 1920x1080
- ERROR-ENGINE 1920x1080
- ELEMENT-BG-WOOD 카드형 1080x1620 + 가로형 1920x1080
- ELEMENT-BG-FIRE 카드형 1080x1620 + 가로형 1920x1080
- ELEMENT-BG-EARTH 카드형 1080x1620 + 가로형 1920x1080
- ELEMENT-BG-METAL 카드형 1080x1620 + 가로형 1920x1080
- ELEMENT-BG-WATER 카드형 1080x1620 + 가로형 1920x1080
소유 경로:
- realapp/assets/imagegen_sources/prompts/HISTORY-*.md
- realapp/assets/imagegen_sources/prompts/SETTINGS-*.md
- realapp/assets/imagegen_sources/prompts/ERROR-ENGINE.md
- realapp/assets/imagegen_sources/prompts/ELEMENT-BG-*.md
- realapp/assets/images/history/
- realapp/assets/images/settings/
- realapp/assets/images/errors/
- realapp/assets/images/backgrounds/
검수:
- 세로형은 1080x1920.
- 가로형은 1920x1080.
- 카드형 파생본은 1080x1620.
- 기존 세로 오행 배경에서 단순 찌그러뜨린 파생본 금지. 비율 보존 crop 또는 재생성.

Agent 6: QA and Integration
목표:
- 모든 병렬 에이전트 산출물을 통합 검수한다.
- ASSET_MANIFEST.md를 최종 업데이트한다.
- 해상도, alpha, 파일 존재, prompt 존재, 금지 문구, 시각 QA를 통과시킨다.
소유 경로:
- realapp/assets/ASSET_MANIFEST.md
- realapp/assets/imagegen_sources/QA_REPORT.md
검증 필수:
1. 모든 P0 missing + Upgrade 대상이 manifest에 있다.
2. 각 manifest 항목에 asset id, 파일 경로, 용도, prompt 경로, 해상도, alpha 여부, 생성/업그레이드 상태가 있다.
3. 실제 파일 픽셀 크기가 계약과 정확히 일치한다.
4. alpha 필요 에셋은 실제 alpha 채널을 가진다.
5. 이미지 생성 프롬프트에 광고/결제/유료/프리미엄/구독/가격표 문구가 없다.
6. contact sheet를 만들어 육안 QA를 수행한다.
7. 찌그러짐, 비율 왜곡, 심한 업스케일 블러, 잘린 캐릭터, 텍스트 안전 영역 부족이 있으면 실패 처리하고 재생성을 요청한다.

권장 검증 스크립트 조건:
- Python Pillow로 모든 PNG의 pixelWidth/pixelHeight를 검사한다.
- alpha 필요 목록은 mode가 RGBA/LA이거나 transparency info가 있어야 한다.
- 크기 불일치가 1px라도 있으면 실패한다.
- 1024x1024 수호신 v1 파일과 1024x1536 카드 v1 파일은 새 기준 통과로 세지 않는다.

최종 완료 조건:
- realapp/assets/ 아래에 P0 신규/업그레이드 최종 에셋이 모두 저장되어 있다.
- 모든 최종 에셋은 realapp/docs/10-full-hd-asset-inventory.md의 해상도 계약과 정확히 일치한다.
- 수호신/심볼/프레임/배지는 alpha 채널이 검증되어 있다.
- 찌그러짐, 깨짐, 비율 왜곡, 과도한 블러가 있는 파일은 최종 manifest에 없다.
- 각 에셋의 prompt 파일이 realapp/assets/imagegen_sources/prompts/ 아래에 있다.
- ASSET_MANIFEST.md와 QA_REPORT.md가 업데이트되어 있다.
- 최종 답변에는 생성 완료 수, 재생성 수, 실패/보류 파일, 검증 명령 결과를 요약한다.
```


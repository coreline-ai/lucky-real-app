# GPT 이미지젠 에셋 제작 계획

작성일: 2026-07-07  
대상: 오행가디언즈 Flutter 앱  
목표: 각 화면에 적용할 배경, 캐릭터, 카드, 공유 이미지, 보상 에셋을 최고 해상도 기준으로 정의한다.

## 원칙

- 이미지젠은 래스터 에셋에 사용한다: 배경, 캐릭터, 카드 일러스트, 공유 카드, 도감 이미지, 스플래시 비주얼.
- 단순 UI 아이콘, 탭 아이콘, 체크박스, 화살표, 설정 아이콘은 가능하면 Flutter Material Symbols, Cupertino Icons, lucide 계열, 또는 SVG/vector로 처리한다.
- 이미지젠 결과물은 앱에서 바로 쓰지 않고 **마스터 원본 -> 검수 -> 크롭/리사이즈 -> Flutter asset 등록** 순서로 사용한다.
- 모든 프로젝트 적용 에셋은 `$CODEX_HOME/generated_images`에 방치하지 않고 `realapp/assets/` 아래로 복사한다.
- 기존 에셋을 덮어쓰지 않는다. 새 버전은 `-v2`, `-v3`처럼 버전명으로 저장한다.
- 투명 PNG가 필요한 캐릭터/카드 오브젝트는 기본적으로 단색 chroma-key 배경으로 생성한 뒤 로컬 배경 제거를 거친다.
- 텍스트가 들어가는 UI는 이미지 안에 굽지 않는다. 앱에서 Flutter Text로 렌더링한다. 예외는 앱 아이콘처럼 텍스트가 없는 심볼성 이미지다.

## 스타일 방향

오행가디언즈의 비주얼은 전통 만세력의 상징성을 유지하되, 무겁고 공포스러운 점술 톤이 아니라 따뜻한 판타지 웰니스 톤이어야 한다.

공통 스타일:

- 장르: 고급 모바일 게임 UI + 웰니스 앱 + 동양 판타지
- 분위기: 차분함, 신뢰감, 신비로움, 매일 돌아오고 싶은 포근함
- 재질: 은은한 종이 질감, 비단, 옥, 먹 번짐, 빛 입자, 별자리, 절기 패턴
- 피해야 할 것: 공포스러운 귀신, 과도한 무속 이미지, 종교적 특정성, 부적 난무, 어두운 저주 톤, 도박/과금형 카드팩 분위기

오행 색상 기준:

| 오행 | 키 컬러 | 보조 질감 |
|---|---|---|
| 목 | 녹색, 청록, 새싹빛 | 나뭇결, 잎맥, 이슬 |
| 화 | 산호, 붉은빛, 금빛 | 불꽃, 등불, 노을 |
| 토 | 황토, 금갈색, 베이지 | 흙결, 산맥, 도자기 |
| 금 | 은색, 백색, 옅은 금속광 | 금속, 서리, 검광 |
| 수 | 남색, 하늘색, 청색 | 물결, 안개, 달빛 |

## 해상도 기준

생성 마스터는 실제 표시 크기보다 크게 만든다. Flutter에는 사용처별로 WebP/PNG를 내보낸다.

| 에셋 유형 | 마스터 권장 | 앱 내보내기 |
|---|---:|---:|
| 세로 전체 배경 | 2160x3840 또는 2484x4416 | 1080x1920, 1440x2560 |
| 가로/태블릿 배경 | 3840x2160 | 1920x1080, 2560x1440 |
| 카드 일러스트 | 2048x3072 | 512x768, 1024x1536 |
| 수호신 캐릭터 컷아웃 | 2048x2048 | 512, 1024, 1536 PNG/WebP |
| 공유 카드 템플릿 | 2160x3840 | 1080x1920 |
| 앱 아이콘 원본 | 2048x2048 | iOS/Android icon set |
| 스플래시 심볼 | 2048x2048 | 512, 1024 PNG |
| 배지/보상 메달 | 1024x1024 | 128, 256, 512 PNG/WebP |

Flutter 등록 권장:

```text
realapp/assets/
  imagegen_sources/
    prompts/
    masters/
  images/
    backgrounds/
    guardians/
    cards/
    collection/
    share/
    onboarding/
    app_icon/
```

## 공통 이미지젠 프롬프트 스키마

이미지 생성 시 아래 구조를 기본으로 사용한다.

```text
Use case: stylized-concept
Asset type: <screen/background/guardian/card/share template>
Primary request: <무엇을 만들지>
Scene/backdrop: <환경>
Subject: <주요 피사체>
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: <세로/정방형/카드형, 안전 영역>
Lighting/mood: soft luminous, calm, hopeful, not scary
Color palette: <오행 색상>
Materials/textures: silk, jade, paper grain, subtle ink, starlight particles
Text: no text
Constraints: high resolution, clean usable negative space, mobile app safe area, no watermark
Avoid: horror, occult fear, realistic human faces, brand logos, UI text, clutter, gambling pack style
```

투명 컷아웃이 필요한 경우:

```text
Create the requested subject on a perfectly flat solid #00ff00 chroma-key background for background removal.
The background must be one uniform color with no shadows, gradients, texture, reflections, floor plane, or lighting variation.
Keep the subject fully separated from the background with crisp edges and generous padding.
Do not use #00ff00 anywhere in the subject.
No cast shadow, no contact shadow, no reflection, no watermark, and no text.
```

## 화면별 필수 에셋

### 1. 앱 아이콘 / 브랜드

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| BRAND-001 | 앱 아이콘 심볼 | iOS/Android 앱 아이콘 | 2048x2048 | platform icon set |
| BRAND-002 | 스플래시 심볼 | 시작 화면 중앙 심볼 | 2048x2048 | PNG/WebP |
| BRAND-003 | 오행 로고 마크 | 설정/공유 카드 워터마크성 마크 | 2048x2048 | PNG/SVG 후보 |
| BRAND-004 | 브랜드 패턴 타일 | 배경 보조 패턴 | 2048x2048 | WebP tile |

프롬프트 방향:

- 다섯 오행이 하나의 원형 수호 문장처럼 합쳐진 심볼.
- 텍스트 없음.
- 도박 카드팩 느낌이 아니라 신뢰감 있는 웰니스 판타지.

### 2. 스플래시 / 로딩

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| SPLASH-001 | 시작 화면 배경 | 앱 실행 첫 화면 | 2160x3840 | WebP |
| SPLASH-002 | 계산 중 배경 | 만세력 계산/오늘 생성 중 | 2160x3840 | WebP |
| SPLASH-003 | 빛 입자 오버레이 | 로딩 애니메이션 레이어 | 2048x2048 | PNG/WebP alpha |

프롬프트 방향:

- 새벽 하늘, 은은한 오행 빛, 종이 질감.
- UI 텍스트가 들어갈 중앙 영역은 비워둔다.

### 3. 온보딩

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| ONB-001 | 오늘의 수호신 소개 배경 | 온보딩 1 | 2160x3840 | WebP |
| ONB-002 | 오행 루틴 소개 배경 | 온보딩 2 | 2160x3840 | WebP |
| ONB-003 | 도감/기록 소개 배경 | 온보딩 3 | 2160x3840 | WebP |
| ONB-004 | 첫 수호신 공개 연출 | 온보딩 완료 | 2160x3840 | WebP |

프롬프트 방향:

- 각 화면은 같은 세계관이지만 피사체가 다르다.
- ONB-001: 수호신 실루엣과 별빛 문.
- ONB-002: 다섯 오행 길이 하루 루틴 카드로 이어짐.
- ONB-003: 카드 도감과 캘린더가 조용히 쌓이는 장면.
- ONB-004: 중앙 카드가 열리며 빛나는 연출.

### 4. 홈 / 오늘 화면

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| HOME-001 | 기본 홈 배경 | 오늘 화면 기본 | 2160x3840 | WebP |
| HOME-002 | 아침 버전 배경 | 오전 홈 | 2160x3840 | WebP |
| HOME-003 | 저녁 버전 배경 | 저녁 홈 | 2160x3840 | WebP |
| HOME-004 | 오늘 수호신 카드 프레임 | 수호신 카드 컨테이너 | 2048x3072 | PNG/WebP |
| HOME-005 | 오행 밸런스 패널 배경 | 차트 뒤 장식 | 2048x1024 | WebP |
| HOME-006 | 루틴 CTA 배경 | 루틴 시작 카드 | 2048x1024 | WebP |

프롬프트 방향:

- 상단은 날짜/수호신 영역, 하단은 루틴 카드가 들어갈 안전 영역.
- 배경은 내용보다 뒤로 물러나야 한다.
- 노치/상태바/하단 네비게이션 영역을 고려해 가장자리 장식은 약하게.

### 5. 운세 화면

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| FORTUNE-001 | 총운 배경 | 총운 카드 | 2048x1536 | WebP |
| FORTUNE-002 | 관계운 배경 | 관계 흐름 카드 | 2048x1536 | WebP |
| FORTUNE-003 | 일/학업 흐름 배경 | 집중/성과 카드 | 2048x1536 | WebP |
| FORTUNE-004 | 컨디션 흐름 배경 | 회복 카드 | 2048x1536 | WebP |
| FORTUNE-005 | 주간 회고 리포트 커버 | 무료 리포트 | 2160x3840 | WebP |
| FORTUNE-006 | 월간 오행 리포트 커버 | 무료 리포트 | 2160x3840 | WebP |

프롬프트 방향:

- 총운: 오행이 균형 잡힌 원형 문양.
- 관계운: 두 개의 빛줄기가 부드럽게 만남.
- 일/학업: 금/목 기반의 정돈된 책상과 별자리.
- 컨디션: 수/토 기반의 휴식과 안정.

### 6. 루틴 화면

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| ROUTINE-001 | 목 루틴 배경 | 성장/계획 루틴 | 2048x1536 | WebP |
| ROUTINE-002 | 화 루틴 배경 | 표현/활력 루틴 | 2048x1536 | WebP |
| ROUTINE-003 | 토 루틴 배경 | 안정/정리 루틴 | 2048x1536 | WebP |
| ROUTINE-004 | 금 루틴 배경 | 집중/판단 루틴 | 2048x1536 | WebP |
| ROUTINE-005 | 수 루틴 배경 | 회복/흐름 루틴 | 2048x1536 | WebP |
| ROUTINE-006 | 루틴 완료 배지 | 완료 보상 | 1024x1024 | PNG/WebP alpha |
| ROUTINE-007 | 7일 챌린지 커버 | 무료 챌린지 | 2160x3840 | WebP |
| ROUTINE-008 | 30일 챌린지 커버 | 무료 챌린지 | 2160x3840 | WebP |

프롬프트 방향:

- 루틴 배경은 실제 행동을 직접적으로 암시하되 인물 얼굴은 피한다.
- 체크리스트와 텍스트가 올라갈 공간을 비워둔다.

### 7. 수호신 캐릭터

MVP 최소 10종: 오행별 음/양 2종씩.

| ID | 에셋 | 오행 | 성향 | 마스터 | 출력 |
|---|---|---|---|---:|---|
| GUARD-WOOD-YANG | 새싹 수호신 | 목 | 양 | 2048x2048 | PNG/WebP alpha |
| GUARD-WOOD-YIN | 숲그늘 수호신 | 목 | 음 | 2048x2048 | PNG/WebP alpha |
| GUARD-FIRE-YANG | 태양불꽃 수호신 | 화 | 양 | 2048x2048 | PNG/WebP alpha |
| GUARD-FIRE-YIN | 등불 수호신 | 화 | 음 | 2048x2048 | PNG/WebP alpha |
| GUARD-EARTH-YANG | 산맥 수호신 | 토 | 양 | 2048x2048 | PNG/WebP alpha |
| GUARD-EARTH-YIN | 도자기 수호신 | 토 | 음 | 2048x2048 | PNG/WebP alpha |
| GUARD-METAL-YANG | 검광 수호신 | 금 | 양 | 2048x2048 | PNG/WebP alpha |
| GUARD-METAL-YIN | 서리종 수호신 | 금 | 음 | 2048x2048 | PNG/WebP alpha |
| GUARD-WATER-YANG | 파도 수호신 | 수 | 양 | 2048x2048 | PNG/WebP alpha |
| GUARD-WATER-YIN | 달샘 수호신 | 수 | 음 | 2048x2048 | PNG/WebP alpha |

표정/포즈 변형:

| ID suffix | 용도 |
|---|---|
| `idle` | 기본 상태 |
| `happy` | 루틴 완료 |
| `thinking` | 운세 계산/조언 |
| `reward` | 카드 획득 |

프롬프트 방향:

- 귀엽지만 너무 유아적이지 않게.
- 사람 얼굴이 아니라 정령/수호신 형태.
- 게임 캐릭터처럼 선명한 실루엣.
- 앱 UI 위에 놓기 쉬운 정면 3/4 구도.

### 8. 카드 / 도감

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| CARD-FRAME-COMMON | 일반 카드 프레임 | 카드 UI | 2048x3072 | PNG/WebP |
| CARD-FRAME-RARE | 레어 카드 프레임 | 카드 UI | 2048x3072 | PNG/WebP |
| CARD-FRAME-SPECIAL | 스페셜 카드 프레임 | 카드 UI | 2048x3072 | PNG/WebP |
| CARD-BACK | 카드 뒷면 | 카드 미공개 상태 | 2048x3072 | WebP |
| CARD-PACK-DAILY | 오늘의 수호 팩 | 무료 보상 묶음 | 2048x2048 | PNG/WebP alpha |
| CARD-PACK-ELEMENT | 오행 균형 팩 | 무료 보상 묶음 | 2048x2048 | PNG/WebP alpha |
| CARD-PACK-SEASON | 시즌 기운 팩 | 무료 이벤트 | 2048x2048 | PNG/WebP alpha |
| COLLECTION-EMPTY | 빈 도감 일러스트 | 빈 상태 | 2048x1536 | WebP |
| COLLECTION-COMPLETE | 도감 완료 일러스트 | 완료 상태 | 2160x3840 | WebP |

카드 일러스트 세트:

- 오행 카드 5종
- 십간 카드 10종
- 십이지 카드 12종
- 수호신 카드 10종
- 루틴 연속 달성 카드 5종
- 케미 카드 5종

프롬프트 방향:

- 카드 안에 텍스트를 넣지 않는다.
- 카드 프레임은 Flutter 텍스트/배지를 올릴 중앙 공간을 확보한다.
- 유료 팩/가챠/카지노 느낌 금지.

### 9. 케미 / 궁합

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| CHEM-001 | 케미 입력 배경 | 상대 등록 화면 | 2160x3840 | WebP |
| CHEM-002 | 케미 결과 배경 | 결과 화면 | 2160x3840 | WebP |
| CHEM-003 | 친구 케미 카드 | 공유 이미지 | 2160x3840 | WebP |
| CHEM-004 | 연인 케미 카드 | 공유 이미지 | 2160x3840 | WebP |
| CHEM-005 | 가족 케미 카드 | 공유 이미지 | 2160x3840 | WebP |
| CHEM-006 | 동료 케미 카드 | 공유 이미지 | 2160x3840 | WebP |
| CHEM-007 | 케미 보완 루틴 배경 | 함께 하기 좋은 루틴 | 2048x1536 | WebP |

프롬프트 방향:

- 두 사람의 관계를 직접 인물로 표현하지 말고, 두 수호신/두 빛/두 오행이 만나는 상징으로 표현한다.
- 공유 카드에는 텍스트가 들어갈 큰 빈 영역을 남긴다.
- 생년월일시를 이미지 안에 직접 넣지 않는다.

### 10. 기록 / 캘린더

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| HISTORY-001 | 기록 캘린더 배경 | 캘린더 화면 | 2160x3840 | WebP |
| HISTORY-002 | 빈 기록 일러스트 | 기록 없음 | 2048x1536 | WebP |
| HISTORY-003 | 주간 회고 배경 | 주간 리포트 | 2160x3840 | WebP |
| HISTORY-004 | 감정 체크 배경 | 감정 기록 | 2048x1536 | WebP |
| HISTORY-005 | 월간 흐름 배경 | 월간 리포트 | 2160x3840 | WebP |

프롬프트 방향:

- 달력, 별자리, 종이 기록, 오행 잉크가 어우러지는 차분한 화면.
- 텍스트/날짜는 Flutter UI로 올리므로 이미지에는 숫자를 넣지 않는다.

### 11. 설정 / 마이

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| SETTINGS-001 | 마이 페이지 배경 | 프로필/설정 | 2160x3840 | WebP |
| SETTINGS-002 | 데이터 삭제 안내 일러스트 | 개인정보/삭제 화면 | 2048x1536 | WebP |
| SETTINGS-003 | 알림 설정 일러스트 | 알림 설정 | 2048x1536 | WebP |
| SETTINGS-004 | 엔터테인먼트 고지 일러스트 | 안전 안내 | 2048x1536 | WebP |

프롬프트 방향:

- 신뢰, 안전, 투명성을 상징하는 밝은 톤.
- 경고/위협 이미지는 피한다.

### 12. 공유 이미지 템플릿

공유 이미지는 SNS 세로형 9:16을 기본으로 한다.

| ID | 에셋 | 용도 | 마스터 | 출력 |
|---|---|---|---:|---|
| SHARE-001 | 오늘 수호신 공유 템플릿 | SNS/메신저 | 2160x3840 | WebP |
| SHARE-002 | 오늘 운세 공유 템플릿 | SNS/메신저 | 2160x3840 | WebP |
| SHARE-003 | 루틴 완료 공유 템플릿 | SNS/메신저 | 2160x3840 | WebP |
| SHARE-004 | 케미 결과 공유 템플릿 | SNS/메신저 | 2160x3840 | WebP |
| SHARE-005 | 카드 획득 공유 템플릿 | SNS/메신저 | 2160x3840 | WebP |

공유 템플릿 안전 영역:

- 상단 15%: 앱 심볼/날짜/수호신 자리
- 중앙 55%: 일러스트와 핵심 메시지
- 하단 30%: Flutter 텍스트, QR/링크, 안내 문구

이미지 자체에는 텍스트를 넣지 않는다. 모든 문구는 Flutter에서 합성한다.

## 오행별 배경 세트

앱 전체에서 반복 재사용할 오행 마스터 배경 5종을 만든다.

| ID | 에셋 | 용도 |
|---|---|---|
| ELEMENT-BG-WOOD | 목 배경 | 루틴, 카드, 운세, 공유 |
| ELEMENT-BG-FIRE | 화 배경 | 루틴, 카드, 운세, 공유 |
| ELEMENT-BG-EARTH | 토 배경 | 루틴, 카드, 운세, 공유 |
| ELEMENT-BG-METAL | 금 배경 | 루틴, 카드, 운세, 공유 |
| ELEMENT-BG-WATER | 수 배경 | 루틴, 카드, 운세, 공유 |

각 배경은 세로형 2160x3840, 카드형 2048x3072, 가로형 3840x2160 파생본을 만든다.

## 앱 내보내기 형식

| 용도 | 포맷 | 이유 |
|---|---|---|
| 배경 | WebP | 용량 절감 |
| 캐릭터 컷아웃 | PNG 또는 WebP alpha | 투명 필요 |
| 카드 프레임 | PNG 또는 WebP alpha | UI 합성 필요 |
| 공유 템플릿 | WebP | 배경 이미지 |
| 앱 아이콘 | PNG source -> platform icons | iOS/Android 빌드 |
| 작은 배지 | PNG/WebP alpha | 선명한 투명 가장자리 |

## 파일명 규칙

```text
<screen-or-domain>_<asset-name>_<variant>_<size>_v<version>.<ext>
```

예시:

```text
home_bg_morning_1440x2560_v1.webp
guardian_wood_yang_idle_1024_v1.webp
card_frame_special_1024x1536_v1.webp
share_today_guardian_1080x1920_v1.webp
```

## 생성 순서

1. 브랜드/스타일 파일럿 3종 생성: 앱 아이콘, 홈 배경, 목 수호신.
2. 스타일 승인 후 오행 배경 5종 생성.
3. 수호신 10종 기본 포즈 생성.
4. 홈/온보딩/운세/루틴 화면 배경 생성.
5. 카드 프레임/카드팩/도감 에셋 생성.
6. 케미/공유 템플릿 생성.
7. 설정/빈 상태/오류 상태 보조 일러스트 생성.
8. 모든 에셋을 Flutter 표시 크기로 리사이즈하고 시각 QA.

## 시각 QA 체크리스트

- [ ] 3x 모바일 화면에서도 흐릿하지 않다.
- [ ] 노치, 상태바, 하단 네비게이션에 핵심 피사체가 가려지지 않는다.
- [ ] Flutter 텍스트를 올렸을 때 가독성이 유지된다.
- [ ] 동일 오행의 배경/카드/수호신이 같은 색 체계를 공유한다.
- [ ] 앱 전체가 한 가지 색만 반복하는 단조로운 팔레트로 보이지 않는다.
- [ ] 공포/저주/무속 과잉 톤이 없다.
- [ ] 도박/가챠/과금형 카드팩처럼 보이지 않는다.
- [ ] 공유 이미지에 생년월일시, 출생 시간, 개인정보가 이미지 자체로 박혀 있지 않다.
- [ ] 텍스트 오탈자 리스크를 피하기 위해 이미지 안에 글자가 없다.
- [ ] 배경 제거가 필요한 에셋은 투명 가장자리에 chroma-key fringe가 없다.

## 첫 배치 이미지젠 작업 목록

MVP 개발 전 가장 먼저 생성할 20개:

1. `BRAND-001` 앱 아이콘 심볼
2. `SPLASH-001` 시작 화면 배경
3. `HOME-001` 기본 홈 배경
4. `ONB-001` 오늘의 수호신 소개 배경
5. `ONB-002` 오행 루틴 소개 배경
6. `ONB-003` 도감/기록 소개 배경
7. `ELEMENT-BG-WOOD` 목 배경
8. `ELEMENT-BG-FIRE` 화 배경
9. `ELEMENT-BG-EARTH` 토 배경
10. `ELEMENT-BG-METAL` 금 배경
11. `ELEMENT-BG-WATER` 수 배경
12. `GUARD-WOOD-YANG` 목 양 수호신
13. `GUARD-FIRE-YANG` 화 양 수호신
14. `GUARD-EARTH-YANG` 토 양 수호신
15. `GUARD-METAL-YANG` 금 양 수호신
16. `GUARD-WATER-YANG` 수 양 수호신
17. `CARD-FRAME-COMMON` 일반 카드 프레임
18. `CARD-BACK` 카드 뒷면
19. `SHARE-001` 오늘 수호신 공유 템플릿
20. `CHEM-002` 케미 결과 배경

## 샘플 프롬프트

### 홈 배경

```text
Use case: stylized-concept
Asset type: mobile app home background, vertical 9:16
Primary request: a calm premium background for a Korean-inspired five-elements daily guardian app
Scene/backdrop: dawn sky with subtle five-element light streams, paper grain, silk-like depth, faint constellation patterns
Subject: no central character, abstract guardian energy only
Style/medium: premium mobile app illustration, painterly 3D hybrid, Korean-inspired fantasy wellness
Composition/framing: vertical composition, soft empty center for app cards and text, safe space at top and bottom
Lighting/mood: soft luminous dawn, hopeful, trustworthy, not scary
Color palette: balanced green, coral, earth gold, silver white, deep blue accents
Materials/textures: hanji paper grain, silk, jade glow, subtle ink
Text: no text
Constraints: high resolution, clean negative space, mobile app safe area, no watermark
Avoid: horror, occult fear, realistic human faces, brand logos, UI text, clutter, gambling card pack style
```

### 목 수호신 컷아웃

```text
Use case: stylized-concept
Asset type: transparent character cutout for mobile app guardian
Primary request: a wood-element guardian spirit representing growth, planning, and gentle vitality
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for background removal
Subject: small elegant forest sprout guardian, non-human spirit, soft leaf crown, jade glow, friendly but not childish
Style/medium: premium mobile game character illustration, painterly 3D hybrid
Composition/framing: centered 3/4 view, full body, generous padding, crisp silhouette
Lighting/mood: soft luminous, calm, hopeful
Color palette: emerald, fresh green, pale jade, small warm highlights
Materials/textures: leaves, dew, soft bark, jade
Text: no text
Constraints: one uniform #ff00ff background, no shadow, no floor, no reflections, subject fully separated from background
Avoid: human face realism, scary spirit, animal mascot, #ff00ff in subject, watermark, text
```

### 카드 프레임

```text
Use case: stylized-concept
Asset type: mobile collectible card frame
Primary request: a premium free collectible guardian card frame for a five-elements wellness RPG app
Scene/backdrop: transparent-compatible frame design, no text
Subject: ornate but restrained card border with five-element motifs, empty center for app-rendered illustration and text
Style/medium: high-end mobile game UI asset, Korean-inspired decorative frame, polished fantasy wellness
Composition/framing: vertical card 2:3 ratio, clear inner safe area, readable border silhouette
Lighting/mood: elegant, calm, rewarding, not casino-like
Color palette: soft gold, jade, deep navy, subtle silver
Materials/textures: silk, jade, brushed metal, hanji paper
Text: no text
Constraints: no price, no premium label, no gambling pack feeling, no watermark
Avoid: casino, loot box, neon gambling, clutter, text
```

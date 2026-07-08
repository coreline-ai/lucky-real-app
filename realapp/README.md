# 🔮 오행가디언즈 realapp

`realapp`은 `lucky-real-app` 모노레포의 Flutter 스마트폰 앱입니다. 만세력/오행 계산 결과를 **오늘의 수호신, 운세, 루틴, 카드 도감, 시장관찰, 케미**로 바꿔 매일 가볍게 사용할 수 있게 만드는 무료·오프라인 우선 앱입니다.

<p>
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.44.5-02569B?style=flat-square&logo=flutter&logoColor=white">
  <img alt="Dart" src="https://img.shields.io/badge/Dart-3.12.2-0175C2?style=flat-square&logo=dart&logoColor=white">
  <img alt="Offline First" src="https://img.shields.io/badge/Offline--First-Drift%20SQLite-6F42C1?style=flat-square">
  <img alt="No Ads No IAP" src="https://img.shields.io/badge/No%20Ads%20%2F%20No%20IAP-Free%20MVP-2EA44F?style=flat-square">
</p>

## 대표 화면

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/realapp-tab-home.png" alt="홈 탭" width="190"><br><b>홈</b></td>
    <td align="center"><img src="docs/screenshots/realapp-tab-fortune.png" alt="운세 탭" width="190"><br><b>운세</b></td>
    <td align="center"><img src="docs/screenshots/realapp-tab-routine.png" alt="루틴 탭" width="190"><br><b>루틴</b></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/realapp-tab-cards.png" alt="도감 탭" width="190"><br><b>도감</b></td>
    <td align="center"><img src="docs/screenshots/realapp-tab-market.png" alt="시장관찰 탭" width="190"><br><b>시장관찰</b></td>
    <td align="center"><img src="docs/screenshots/realapp-tab-chemistry.png" alt="케미 탭" width="190"><br><b>케미</b></td>
  </tr>
</table>

### 현재 실기기 화면

요청 시점의 안드로이드 디바이스 현재 화면 캡쳐입니다.

<p align="center">
  <img src="docs/screenshots/realapp-current-screen.png" alt="안드로이드 디바이스 현재 화면 - 온보딩 기록과 도감" width="220">
</p>

## 주요 기능

| 탭 | 기능 |
|---|---|
| 홈 | 오늘의 수호신, 한 줄 운세, 일진, 오행 밸런스, 공유 |
| 운세 | 총운, 감정, 관계, 일/학업, 컨디션 흐름 |
| 루틴 | 오행별 추천 루틴, 완료 체크, 보상 연결 |
| 도감 | 수호신/오행 카드 수집, 진행률 |
| 시장관찰 | 관심종목, 관찰 준비도, 자기점검 문구 |
| 케미 | 상대 프로필, 관계 타입, 케미 점수, 공유 결과 |

## 라이센스 정보

라이센스 정보는 앱 안의 **설정 > 라이센스** 메뉴에서 확인할 수 있습니다.

## 실행

```bash
flutter pub get
flutter run
```

특정 Android 기기 실행:

```bash
flutter devices
flutter run -d <device-id>
```

## 검증

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## 문서 읽는 순서

1. [docs/README.md](docs/README.md)
2. [docs/01-product-spec.md](docs/01-product-spec.md)
3. [docs/02-ux-ia.md](docs/02-ux-ia.md)
4. [docs/03-domain-data-spec.md](docs/03-domain-data-spec.md)
5. [docs/04-flutter-architecture.md](docs/04-flutter-architecture.md)
6. [docs/05-qa-privacy-safety.md](docs/05-qa-privacy-safety.md)
7. [docs/06-development-roadmap.md](docs/06-development-roadmap.md)
8. [docs/09-engine-gateway-contract.md](docs/09-engine-gateway-contract.md)

> 오행가디언즈는 오락·자기성찰용 앱입니다. 의료, 투자, 법률, 재무 판단을 대신하지 않습니다.

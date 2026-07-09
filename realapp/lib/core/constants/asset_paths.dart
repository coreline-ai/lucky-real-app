import '../domain/five_element.dart';

/// Single source of truth for bundled asset paths.
///
/// Rules (realapp/dev-plan 결정 기록):
/// - All asset path literals live here; widgets never hard-code paths.
/// - Runtime files use WebP derivatives of ASSET_MANIFEST.md PNG sources.
/// - Chemistry/share runtime image assets are registered.
/// - Market instruments are bundled as JSON; market tab uses a dedicated WebP background.
class AssetPaths {
  const AssetPaths._();

  // 브랜드
  static const String appIcon =
      'assets/images/app_icon/brand_app_icon_symbol_2048_v1.webp';
  static const String brandSplashSymbol =
      'assets/images/app_icon/brand_splash_symbol_2048_v1.webp';

  // 하단 탭
  static const String bottomNavBackground =
      'assets/images/navigation/bottom_nav_bg_1080x300_v1.webp';
  static const String bottomNavActiveGlow =
      'assets/images/navigation/bottom_nav_active_glow_240x120_v1.webp';

  // 배경 (세로)
  static const String splashBackground =
      'assets/images/backgrounds/splash_start_bg_1080x1920_v1.webp';
  static const String homeBackground =
      'assets/images/backgrounds/home_bg_default_1080x1920_v1.webp';

  // 온보딩
  static const String onboardingGuardianIntro =
      'assets/images/onboarding/onboarding_guardian_intro_1080x1920_v1.webp';
  static const String onboardingRoutineIntro =
      'assets/images/onboarding/onboarding_routine_intro_1080x1920_v1.webp';
  static const String onboardingCollectionRecord =
      'assets/images/onboarding/onboarding_collection_record_1080x1920_v1.webp';
  static const String onboardingFirstReveal =
      'assets/images/onboarding/onboarding_first_guardian_reveal_1080x1920_v1.webp';

  // 카드 공통 (v2, 1080x1620)
  static const String cardFrame =
      'assets/images/cards/card_frame_common_1080x1620_v2.webp';
  static const String cardBack =
      'assets/images/cards/card_back_1080x1620_v2.webp';
  static const String homeGuardianCardFrame =
      'assets/images/cards/home_guardian_card_frame_1080x1620_v1.webp';

  // 카드 아트 (도감)
  static String elementCardArt(FiveElement element) =>
      'assets/images/cards/card_element_${element.name}_1080x1620_v1.webp';

  /// 수호신 선택 로직은 양(yang)만 사용한다 (결정 기록).
  static String guardianCardArt(FiveElement element) =>
      'assets/images/cards/card_guardian_${element.name}_yang_1080x1620_v1.webp';

  /// 음(yin) 카드 아트 — 2차 해금 보상 전용 (도감 수집 요소, 선택 로직 미편입).
  static String guardianCardArtYin(FiveElement element) =>
      'assets/images/cards/card_guardian_${element.name}_yin_1080x1620_v1.webp';

  // 수호신 일러스트 (v2, 2048 투명)
  static String guardianIdle(FiveElement element) =>
      'assets/images/guardians/guardian_${element.name}_yang_idle_2048_v2.webp';

  // 오행 배경
  static String elementBackground(FiveElement element) =>
      'assets/images/backgrounds/element_bg_${element.name}_1080x1920_v1.webp';

  static String elementCardBackground(FiveElement element) =>
      'assets/images/backgrounds/element_bg_${element.name}_card_1080x1620_v1.webp';

  static String elementWideBackground(FiveElement element) =>
      'assets/images/backgrounds/element_bg_${element.name}_wide_1920x1080_v1.webp';

  // 화면 배너/패널
  static const String fortuneBanner =
      'assets/images/backgrounds/fortune_total_bg_1920x1080_v1.webp';
  static const String fortuneTabBackground = fortuneBanner;

  static const String marketTabBackground =
      'assets/images/backgrounds/market_observation_bg_1080x1920_v1.webp';
  static const String homeBalancePanel =
      'assets/images/backgrounds/home_balance_panel_bg_1920x1080_v1.webp';
  static const String homeRoutineCta =
      'assets/images/backgrounds/home_routine_cta_bg_1920x1080_v1.webp';
  static const String routineTabBackground = homeRoutineCta;

  static String routineBanner(FiveElement element) =>
      'assets/images/backgrounds/routine_${element.name}_bg_1920x1080_v1.webp';

  // 운세 섹션 배경 스트립 (배경 B안: 관계/일·학업/컨디션 3종)
  static const String fortuneRelationshipStrip =
      'assets/images/backgrounds/fortune_relationship_bg_1920x1080_v1.webp';
  static const String fortuneWorkStudyStrip =
      'assets/images/backgrounds/fortune_work_study_bg_1920x1080_v1.webp';
  static const String fortuneConditionStrip =
      'assets/images/backgrounds/fortune_condition_bg_1920x1080_v1.webp';

  // 탭/화면 전용 배경 (배경 B안)
  static const String historyBackground =
      'assets/images/history/history_calendar_bg_1080x1920_v1.webp';
  static const String settingsBackground =
      'assets/images/settings/settings_my_page_bg_1080x1920_v1.webp';

  // 이펙트
  static const String routineCompleteBadge =
      'assets/images/effects/routine_complete_badge_1024_v1.webp';

  // 빈/오류 상태 일러스트
  static const String collectionTabBackground =
      'assets/images/collection/collection_empty_1920x1080_v1.webp';
  static const String collectionEmpty = collectionTabBackground;
  static const String historyEmpty =
      'assets/images/history/history_empty_illustration_1920x1080_v1.webp';
  static const String errorEngine =
      'assets/images/errors/error_engine_illustration_1920x1080_v1.webp';

  // 케미 (2차)
  static const String chemistryResultBackground =
      'assets/images/chemistry/chemistry_result_bg_1080x1920_v1.webp';

  // 공유 템플릿 (2차, 9:16 — 하단 30%가 텍스트 안전 영역)
  static const String shareTodayGuardianTemplate =
      'assets/images/share/share_today_guardian_1080x1920_v1.webp';
  static const String shareChemistryTemplate =
      'assets/images/share/share_chemistry_result_1080x1920_v1.webp';

  // 설정
  static const String settingsDataDelete =
      'assets/images/settings/settings_data_delete_illustration_1920x1080_v1.webp';
  static const String settingsNotice =
      'assets/images/settings/settings_entertainment_notice_1920x1080_v1.webp';
}

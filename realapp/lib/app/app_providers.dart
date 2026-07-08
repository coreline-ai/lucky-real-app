import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/time/app_clock.dart';
import '../data/local/app_database.dart';
import '../data/repositories/card_repository.dart';
import '../data/repositories/chemistry_repository.dart';
import '../data/repositories/daily_fortune_repository.dart';
import '../data/repositories/market_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/record_repository.dart';
import '../data/repositories/routine_repository.dart';
import '../engine/gateway/engine_gateway.dart';
import '../features/cards/application/reward_service.dart';
import '../features/notifications/application/notification_scheduler.dart';

/// 실제 구현은 main()에서 override로 주입한다 (DartEngineGateway + 파일 DB).
/// 테스트는 MockEngineGateway/메모리 DB를 주입한다. 기본값을 두지 않는 이유:
/// override 누락이 조용히 Mock으로 출시되는 사고를 막기 위해서다.
final engineGatewayProvider = Provider<EngineGateway>(
  (ref) => throw UnimplementedError('engineGatewayProvider must be overridden'),
);

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);

final appClockProvider = Provider<AppClock>((ref) => const SystemClock());

/// OS 알림 어댑터. main()에서 실제 구현을 주입하고, 테스트는 페이크를 쓴다.
final notificationPortProvider = Provider<NotificationPort>(
  (ref) =>
      throw UnimplementedError('notificationPortProvider must be overridden'),
);

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => NotificationScheduler(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationPortProvider),
  ),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(appDatabaseProvider)),
);

final cardRepositoryProvider = Provider<CardRepository>(
  (ref) => CardRepository(ref.watch(appDatabaseProvider)),
);

final routineRepositoryProvider = Provider<RoutineRepository>(
  (ref) => RoutineRepository(ref.watch(appDatabaseProvider)),
);

final recordRepositoryProvider = Provider<RecordRepository>(
  (ref) => RecordRepository(ref.watch(appDatabaseProvider)),
);

final chemistryRepositoryProvider = Provider<ChemistryRepository>(
  (ref) => ChemistryRepository(ref.watch(appDatabaseProvider)),
);

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => MarketRepository(ref.watch(appDatabaseProvider)),
);

final rewardServiceProvider = Provider<RewardService>(
  (ref) => RewardService(
    ref.watch(appDatabaseProvider),
    ref.watch(cardRepositoryProvider),
  ),
);

final dailyFortuneRepositoryProvider = Provider<DailyFortuneRepository>(
  (ref) => DailyFortuneRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(engineGatewayProvider),
  ),
);

/// 대표 출생 프로필. null이면 온보딩 필요 상태.
final activeBirthProfileProvider = FutureProvider<BirthProfile?>(
  (ref) => ref.watch(profileRepositoryProvider).getActiveBirthProfile(),
);

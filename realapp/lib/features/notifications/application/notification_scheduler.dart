import 'package:drift/drift.dart';

import '../../../data/local/app_database.dart';

/// 알림 종류 (02 MVP 3종).
enum AppNotificationType {
  morningGuardian(1, 'morning_guardian', '오늘의 수호신 도착', '오늘의 기운을 확인해 보세요.', 8),
  eveningRoutine(
    2,
    'evening_routine',
    '오늘의 오행 루틴',
    '5분이면 충분해요. 오늘 루틴을 체크해 보세요.',
    20,
  ),
  cardUnclaimed(
    3,
    'card_unclaimed',
    '오늘의 카드가 기다려요',
    '도감에서 오늘의 보상을 확인해 보세요.',
    21,
  );

  const AppNotificationType(
    this.notificationId,
    this.key,
    this.title,
    this.body,
    this.defaultHour,
  );

  final int notificationId;
  final String key;
  final String title;
  final String body;
  final int defaultHour;
}

/// OS 알림 플러그인 추상화 — 테스트에서 페이크로 대체한다.
abstract interface class NotificationPort {
  Future<bool> requestPermission();

  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
  });

  Future<void> cancel(int id);
}

/// 다음 발화 시각 계산 (순수 함수, Asia/Seoul 벽시계 기준).
/// 오늘 시각이 이미 지났으면 내일로 넘긴다 (자정 경계 포함).
DateTime nextFireTime(DateTime nowKst, int hour, int minute) {
  var candidate = DateTime(nowKst.year, nowKst.month, nowKst.day, hour, minute);
  if (!candidate.isAfter(nowKst)) {
    candidate = candidate.add(const Duration(days: 1));
  }
  return candidate;
}

/// 알림 설정 저장 + 예약 동기화 (04: 서버 푸시 없음, 로컬 예약만).
class NotificationScheduler {
  NotificationScheduler(this._db, this._port);

  final AppDatabase _db;
  final NotificationPort _port;

  Future<bool> requestPermission() => _port.requestPermission();

  Future<List<NotificationSetting>> settings() async {
    final rows = await _db.select(_db.notificationSettings).get();
    return [
      for (final type in AppNotificationType.values)
        rows.firstWhere(
          (r) => r.type == type.key,
          orElse: () => NotificationSetting(
            type: type.key,
            enabled: false,
            hour: type.defaultHour,
            minute: 0,
          ),
        ),
    ];
  }

  /// 설정 변경 → 저장 + 예약/취소 동기화.
  Future<void> update(
    AppNotificationType type, {
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    final current = (await settings()).firstWhere((s) => s.type == type.key);
    final nextHour = hour ?? current.hour;
    final nextMinute = minute ?? current.minute;

    await _db
        .into(_db.notificationSettings)
        .insertOnConflictUpdate(
          NotificationSettingsCompanion.insert(
            type: type.key,
            enabled: Value(enabled),
            hour: nextHour,
            minute: Value(nextMinute),
          ),
        );

    if (enabled) {
      await _port.scheduleDaily(
        id: type.notificationId,
        title: type.title,
        body: type.body,
        hour: nextHour,
        minute: nextMinute,
        payload: 'type=${type.key}',
      );
    } else {
      await _port.cancel(type.notificationId);
    }
  }

  /// 앱 시작 시 저장된 설정대로 예약 복원 (재부팅 대비).
  Future<void> restoreSchedules() async {
    for (final setting in await settings()) {
      final type = AppNotificationType.values.firstWhere(
        (t) => t.key == setting.type,
      );
      if (setting.enabled) {
        await _port.scheduleDaily(
          id: type.notificationId,
          title: type.title,
          body: type.body,
          hour: setting.hour,
          minute: setting.minute,
          payload: 'type=${type.key}',
        );
      }
    }
  }

  /// 저장 데이터 삭제처럼 설정 테이블을 읽을 수 없게 되는 흐름에서
  /// OS에 남은 예약 알림을 먼저 모두 정리한다.
  Future<void> cancelAll() async {
    for (final type in AppNotificationType.values) {
      await _port.cancel(type.notificationId);
    }
  }
}

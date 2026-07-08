import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ohaeng_guardians/data/local/app_database.dart';
import 'package:ohaeng_guardians/features/notifications/application/notification_scheduler.dart';

class _FakePort implements NotificationPort {
  final scheduled = <int, ({int hour, int minute})>{};
  final cancelled = <int>[];
  bool permission = true;

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
  }) async {
    scheduled[id] = (hour: hour, minute: minute);
  }

  @override
  Future<void> cancel(int id) async {
    scheduled.remove(id);
    cancelled.add(id);
  }
}

void main() {
  group('nextFireTime (자정 경계)', () {
    test('오늘 시각이 남아 있으면 오늘', () {
      final now = DateTime(2026, 7, 8, 7, 30);
      expect(nextFireTime(now, 8, 0), DateTime(2026, 7, 8, 8, 0));
    });

    test('오늘 시각이 지났으면 내일', () {
      final now = DateTime(2026, 7, 8, 8, 0);
      expect(nextFireTime(now, 8, 0), DateTime(2026, 7, 9, 8, 0));
    });

    test('자정 직전 → 다음날 새벽 예약', () {
      final now = DateTime(2026, 7, 8, 23, 59);
      expect(nextFireTime(now, 0, 5), DateTime(2026, 7, 9, 0, 5));
    });

    test('월말 경계에서 날짜가 올바르게 넘어간다', () {
      final now = DateTime(2026, 7, 31, 22, 0);
      expect(nextFireTime(now, 8, 0), DateTime(2026, 8, 1, 8, 0));
    });
  });

  group('NotificationScheduler', () {
    late AppDatabase db;
    late _FakePort port;
    late NotificationScheduler scheduler;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      port = _FakePort();
      scheduler = NotificationScheduler(db, port);
    });

    tearDown(() async {
      await db.close();
    });

    test('기본 설정: 3종 모두 off, 기본 시각 08/20/21시', () async {
      final settings = await scheduler.settings();
      expect(settings, hasLength(3));
      expect(settings.every((s) => !s.enabled), isTrue);
      expect(settings.map((s) => s.hour), containsAll([8, 20, 21]));
    });

    test('켜면 예약, 끄면 취소 — 설정과 예약이 항상 일치', () async {
      await scheduler.update(
        AppNotificationType.morningGuardian,
        enabled: true,
      );
      expect(port.scheduled[1], (hour: 8, minute: 0));

      await scheduler.update(
        AppNotificationType.morningGuardian,
        enabled: false,
      );
      expect(port.scheduled.containsKey(1), isFalse);
      expect(port.cancelled, contains(1));
    });

    test('시간 변경이 저장되고 예약에 반영된다', () async {
      await scheduler.update(
        AppNotificationType.eveningRoutine,
        enabled: true,
        hour: 21,
        minute: 30,
      );
      expect(port.scheduled[2], (hour: 21, minute: 30));

      final saved = (await scheduler.settings()).firstWhere(
        (s) => s.type == 'evening_routine',
      );
      expect(saved.hour, 21);
      expect(saved.minute, 30);
    });

    test('restoreSchedules: 켜진 것만 재예약 (재부팅 대비)', () async {
      await scheduler.update(
        AppNotificationType.morningGuardian,
        enabled: true,
      );
      await scheduler.update(AppNotificationType.cardUnclaimed, enabled: true);
      port.scheduled.clear(); // 재부팅으로 예약 소실 가정

      await scheduler.restoreSchedules();
      expect(port.scheduled.keys, containsAll([1, 3]));
      expect(port.scheduled.containsKey(2), isFalse);
    });

    test('cancelAll: 저장 설정과 무관하게 모든 예약 ID를 취소한다', () async {
      await scheduler.cancelAll();

      expect(port.cancelled, containsAll([1, 2, 3]));
    });
  });
}

import '../application/notification_scheduler.dart';

/// 웹 실행용 알림 스텁.
///
/// 브라우저 데모에서는 OS 로컬 알림 예약을 하지 않는다.
class LocalNotificationPort implements NotificationPort {
  const LocalNotificationPort._();

  static Future<LocalNotificationPort> initialize() async {
    return const LocalNotificationPort._();
  }

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}

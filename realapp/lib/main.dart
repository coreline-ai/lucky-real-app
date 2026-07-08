import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/app_providers.dart';
import 'core/constants/system_ui_styles.dart';
import 'data/local/open_database.dart';
import 'engine/gateway/dart_engine_gateway.dart';
import 'features/notifications/application/notification_scheduler.dart';
import 'features/notifications/infrastructure/local_notification_port.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppSystemUiStyles.lightStatusBar);

  // 엔진 데이터(음양력/절기 테이블) 로드. 스플래시 구간에서 1회만 수행된다.
  final gateway = await DartEngineGateway.load(rootBundle.loadString);
  final database = openAppDatabase();
  final notificationPort = await LocalNotificationPort.initialize();

  // 저장된 알림 설정대로 예약 복원 (재부팅·업데이트 대비).
  await NotificationScheduler(database, notificationPort).restoreSchedules();

  runApp(
    ProviderScope(
      overrides: [
        engineGatewayProvider.overrideWithValue(gateway),
        appDatabaseProvider.overrideWithValue(database),
        notificationPortProvider.overrideWithValue(notificationPort),
      ],
      child: const OhaengGuardiansApp(),
    ),
  );
}

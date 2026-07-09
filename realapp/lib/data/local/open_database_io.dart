import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

/// 앱 문서 디렉터리에 로컬 DB를 연다 (04 오프라인 저장 전략).
AppDatabase openAppDatabase() {
  return AppDatabase(
    LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      return NativeDatabase.createInBackground(
        File('${dir.path}/ohaeng_guardians.db'),
      );
    }),
  );
}

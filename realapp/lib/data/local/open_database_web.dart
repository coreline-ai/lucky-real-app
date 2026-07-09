import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

import 'app_database.dart';

/// 브라우저 실행용 DB.
///
/// 현재 웹 실행은 UI/흐름 확인 목적이므로 새로고침 시 초기화되는 메모리 DB를 사용한다.
/// 영속 저장이 필요해지면 WasmDatabase.open + drift_worker + OPFS/IndexedDB로 승격한다.
AppDatabase openAppDatabase() {
  return AppDatabase(
    LazyDatabase(() async {
      final sqlite = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
      sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
      return WasmDatabase.inMemory(sqlite);
    }),
  );
}

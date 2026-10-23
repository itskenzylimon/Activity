import 'package:quickeydb/quickeydb.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:example/gallery/recipes/database_controller.dart';

Future<QuickeyDBImpl> openBrowserTestDatabase() => QuickeyDB.initialize(
  dbName: 'activity_browser_test',
  dbVersion: 1,
  persist: false,
  dataAccessObjects: [RecordsDao()],
  conflictAlgorithm: ConflictAlgorithm.abort,
  factory: createDatabaseFactoryFfiWeb(
    options: SqfliteFfiWebOptions(
      indexedDbName: 'activity_${DateTime.now().microsecondsSinceEpoch}',
      sqlite3WasmUri: Uri.base.resolve('/.web-assets/sqlite3.wasm'),
      sharedWorkerUri: Uri.base.resolve('/.web-assets/sqflite_sw.js'),
    ),
  ),
);

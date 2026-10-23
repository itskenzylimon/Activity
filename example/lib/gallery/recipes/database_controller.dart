import 'dart:async';
import 'package:activity/activity.dart';
import 'package:quickeydb/quickeydb.dart';
import '../console.dart';

class Record {
  const Record({this.id, required this.title});
  final int? id;
  final String title;
  Map<String, Object?> toMap() => {'id': id, 'title': title};
  factory Record.fromMap(Map<String?, dynamic> row) =>
      Record(id: row['id'] as int?, title: row['title'] as String);
}

class RecordsDao extends DataAccessObject<Record> {
  RecordsDao()
    : super(
        'CREATE TABLE records (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL UNIQUE)',
        converter: Converter<Record?>(
          encode: Record.fromMap,
          decode: (r) => r!.toMap(),
          decodeTable: (r) => r!.toMap(),
        ),
      );
}

class RecordResult {
  const RecordResult(this.id, this.action);
  final int id;
  final String action;
}

/// Application-owned feature. It alone opens/closes the shared database;
/// widgets borrow this controller. Operations are serialized and drained before
/// close. This gallery uses an in-memory SQLite DB and no user secrets.
class RecordsController extends ActiveController {
  RecordsController(this.console, {Future<QuickeyDBImpl> Function()? open})
    : _open = open ?? openDatabase;
  final GalleryConsole console;
  final Future<QuickeyDBImpl> Function() _open;
  final records = ActiveList<Record>([]);
  final draft = ActiveString('');
  final status = ActiveString('Not opened · initialize the sample database');
  final busy = ActiveBool(false);
  final elapsed = ActiveType<Duration?>(null);
  final result = ActiveType<RecordResult?>(null);
  QuickeyDBImpl? _db;
  Future<void> _pending = Future.value();
  Future<void>? _closing;
  @override
  Iterable<ActiveType> get activities => [
    records,
    draft,
    status,
    busy,
    elapsed,
    result,
  ];
  static Future<QuickeyDBImpl> openDatabase() => QuickeyDB.initialize(
    dbName: 'activity_recipe',
    dbVersion: 1,
    persist: false,
    dataAccessObjects: [RecordsDao()],
    conflictAlgorithm: ConflictAlgorithm.abort,
  );
  Future<void> _run(String operation, Future<void> Function() action) {
    if (isDisposed) {
      return Future.error(StateError('RecordsController is disposed'));
    }
    final next = _pending.then((_) async {
      if (isDisposed) return;
      busy(true);
      status('$operation…');
      final watch = Stopwatch()..start();
      try {
        await activeAsync(action, isRunningKey: 'database');
        if (isDisposed) return;
        status('$operation succeeded');
        console.add(
          'Operations',
          'Database $operation succeeded; values omitted',
          elapsed: watch.elapsed,
        );
      } catch (_) {
        if (isDisposed) return;
        status(
          '$operation failed · draft retained. Fix input or refresh and retry.',
        );
        console.add(
          'Errors',
          'Database $operation failed; payload omitted',
          error: true,
          elapsed: watch.elapsed,
        );
      } finally {
        if (!isDisposed) {
          busy(false);
          elapsed(watch.elapsed);
        }
      }
    });
    // Retain a drainable queue; errors handled above never poison subsequent work.
    _pending = next;
    return next;
  }

  Future<void> _ensureOpen() async => _db ??= await _open();
  Future<void> _refresh() async {
    final rows = (await _db!.get<RecordsDao>()!.query().order([
      'id',
    ], 'ASC').toList()).whereType<Record>().toList();
    if (!isDisposed) records.replaceAll(rows);
  }

  Future<void> refresh() => _run('Refresh', () async {
    await _ensureOpen();
    await _refresh();
  });
  Future<void> save({bool rollback = false}) {
    // Capture the draft when the operation is requested, not after queued awaits.
    final title = draft.value.trim();
    return _run(rollback ? 'Rollback demonstration' : 'Save', () async {
      if (title.length < 3) throw ArgumentError('Title needs 3 characters');
      await _ensureOpen();
      await _db!.transaction(() async {
        await _db!.get<RecordsDao>()!.insert({'title': title});
        if (rollback) throw StateError('Demonstrate atomic rollback');
      });
      // Never discard a newer draft typed while saving.
      if (!isDisposed && draft.value.trim() == title) draft('');
      await _refresh();
    });
  }

  Future<void> rename(Record record) => _run('Update', () async {
    await _db!.transaction(
      () => _db!.get<RecordsDao>()!.update(
        Record(id: record.id, title: '${record.title} ✓'),
      ),
    );
    await _refresh();
  });
  Future<void> remove(Record record) => _run('Delete', () async {
    await _db!.transaction(() => _db!.get<RecordsDao>()!.delete(record));
    await _refresh();
  });
  @override
  Future<void> dispose() {
    if (_closing != null) return _closing!;
    final base = super.dispose(); // Reject new work immediately.
    return _closing = () async {
      await _pending;
      await _db?.close();
      await base;
    }();
  }
}

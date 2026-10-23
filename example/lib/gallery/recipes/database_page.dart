import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import '../widgets.dart';
import '../result_terminal.dart';
import 'database_controller.dart';

/// View borrows the app-owned controller. No DB creation or logging in build.
class DatabasePage extends StatefulWidget {
  const DatabasePage({super.key, required this.controller});
  final RecordsController controller;
  @override
  State<DatabasePage> createState() => _DatabasePageState();
}

class _DatabasePageState extends State<DatabasePage> {
  late final input = TextEditingController(text: widget.controller.draft.value);
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GalleryPage(
    'database',
    children: [
      const Text(
        'Local QuickeyDB 3.0.0 integration · real in-memory SQLite, session-only records. The app owns the database and controller; this view borrows them.',
      ),
      DemoCard(
        title: 'Reactive database records',
        description:
            'Initialize, save, refresh, update and delete. Duplicate titles fail with abort conflicts; rollback keeps the draft and database intact.',
        code: '''import 'package:activity/activity.dart';
import 'package:quickeydb/quickeydb.dart';
// Complete Record + RecordsDao + RecordsController: Model / Controller tab.
final db = await QuickeyDB.initialize(
  dbName: 'activity_recipe', dbVersion: 1, persist: false,
  dataAccessObjects: [RecordsDao()], conflictAlgorithm: ConflictAlgorithm.abort,
);
await db.transaction(() async {
  await db.get<RecordsDao>()!.insert({'title': 'Plan'});
});
final rows = await db.get<RecordsDao>()!.query().order(['id'], 'ASC').toList();
// App owner drains pending operations, then closes db. Not a child-view action.
await db.close();''',
        child:
            ActivitySelector<
              RecordsController,
              (List<Record>, String, bool, Duration?, RecordResult?)
            >(
              controller: widget.controller,
              select: (c) => (
                c.records.snapshotValue,
                c.status.value,
                c.busy.value,
                c.elapsed.value,
                c.result.value,
              ),
              builder: (context, state, _) {
                final c = widget.controller;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      key: const ValueKey('database-draft'),
                      controller: input,
                      onChanged: c.draft.call,
                      decoration: const InputDecoration(
                        labelText: 'Record title draft',
                        helperText: 'At least 3 characters; unique titles',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: state.$3 ? null : c.refresh,
                          child: const Text('Initialize / refresh'),
                        ),
                        FilledButton(
                          onPressed: state.$3
                              ? null
                              : () async {
                                  await c.save();
                                  if (mounted && c.draft.value.isEmpty) {
                                    input.clear();
                                  }
                                },
                          child: const Text('Save record'),
                        ),
                        OutlinedButton(
                          onPressed: state.$3
                              ? null
                              : () => c.save(rollback: true),
                          child: const Text('Simulate transaction rollback'),
                        ),
                      ],
                    ),
                    if (state.$3) const LinearProgressIndicator(),
                    if (state.$1.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No records yet. Initialize and save your first record.',
                        ),
                      ),
                    for (final record in state.$1)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(record.title),
                        subtitle: Text('Record ${record.id}'),
                        trailing: IconButton(
                          tooltip: 'Open record ${record.id}',
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () async {
                            final result = await ActivityRouter.of(context)
                                .pushNamed<RecordResult>(
                                  'database-detail',
                                  pathParameters: {'id': '${record.id}'},
                                );
                            if (!c.isDisposed) c.result(result);
                          },
                        ),
                      ),
                    ResultTerminal(
                      status: state.$2,
                      elapsed: state.$4,
                      output: {
                        'records': state.$1.map((r) => r.toMap()).toList(),
                        'draftRetained': c.draft.value.isNotEmpty,
                        'detailResult': state.$5 == null
                            ? null
                            : {'id': state.$5!.id, 'action': state.$5!.action},
                      },
                    ),
                  ],
                );
              },
            ),
      ),
      const Guidance(
        doText:
            'Use fresh query() scopes, await the transaction and publish reactive state after commit. Keep drafts on failure and reject duplicate titles with an explicit conflict policy.',
        dontText:
            'Do not open/close a shared database in build or a child widget. This is plaintext session data; persistent private data needs an application-owned key and tested recovery policy.',
      ),
      const Text(
        'Web uses the matching sqflite_sw.js worker and sqlite3.wasm assets. Memory and persistence differ: persist:false still needs the SQLite worker on web. QuickeyDB currently permits one open global database per isolate; coordinate with other integrations.',
      ),
    ],
  );
}

class RecordDetailPage extends StatelessWidget {
  const RecordDetailPage({
    super.key,
    required this.controller,
    required this.id,
  });
  final RecordsController controller;
  final int? id;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Database / Record ${id ?? 'unknown'}')),
    body: ActivitySelector<RecordsController, (List<Record>, bool, String)>(
      controller: controller,
      select: (c) => (c.records.snapshotValue, c.busy.value, c.status.value),
      builder: (context, state, _) {
        final matches = state.$1.where((r) => r.id == id);
        final record = matches.isEmpty ? null : matches.first;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              record?.title ??
                  'Record unavailable in this session. Refresh or return to the list.',
            ),
            Text(state.$3),
            if (state.$2) const LinearProgressIndicator(),
            if (record != null) ...[
              FilledButton(
                onPressed: state.$2
                    ? null
                    : () async {
                        await controller.rename(record);
                        if (context.mounted &&
                            !controller.status.value.contains('failed')) {
                          ActivityRouter.of(
                            context,
                          ).pop(RecordResult(record.id!, 'updated'));
                        }
                      },
                child: const Text('Update and return typed result'),
              ),
              TextButton(
                onPressed: state.$2
                    ? null
                    : () async {
                        await controller.remove(record);
                        if (context.mounted &&
                            !controller.status.value.contains('failed')) {
                          ActivityRouter.of(
                            context,
                          ).pop(RecordResult(record.id!, 'deleted'));
                        }
                      },
                child: const Text('Delete and return typed result'),
              ),
            ],
            TextButton(
              onPressed: () => ActivityRouter.of(context).goNamed('database'),
              child: const Text('Return to database recipe'),
            ),
          ],
        );
      },
    ),
  );
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../support/browser_database.dart';
import 'package:example/gallery/console.dart';
import 'package:example/gallery/recipes/workbench_controller.dart';
import 'package:example/gallery/recipes/database_controller.dart';
import 'package:example/gallery/recipes/typed_values.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'nullable profile batches populate every wrapper and reset to absence',
    () async {
      final c = OptionalProfileController();
      expect(c.snapshot.values, everyElement(isNull));
      c.populate();
      expect(c.age.value, 28);
      expect(c.score.value, 4.5);
      expect(c.consent.value, isTrue);
      expect(c.seen.value, DateTime.utc(2026, 10, 20));
      expect(c.role.value, 'member');
      c.resetAllActiveTypes();
      expect(c.snapshot.values, everyElement(isNull));
      await c.dispose();
    },
  );

  test(
    'diagnostics are opt-in, bounded and omit controller payloads',
    () async {
      final console = GalleryConsole();
      final controller = WorkbenchController(console);
      console.watch(controller, 'Workbench');
      controller.draft('sensitive draft');
      await Future<void>.delayed(Duration.zero);
      expect(console.value, isEmpty);
      console.configure(true);
      controller.draft('another private value');
      await Future<void>.delayed(Duration.zero);
      expect(console.value.single.message, contains('payload omitted'));
      expect(console.value.single.message, isNot(contains('private')));
      for (var i = 0; i < 100; i++) {
        console.add('Operations', 'Operation $i');
      }
      expect(console.value.length, 80);
      console.configure(false);
      expect(console.value, isEmpty);
      console.dispose();
      await controller.dispose();
    },
  );
  test(
    'latest request wins, cancel ignores response, errors recover and drafts survive',
    () async {
      final console = GalleryConsole();
      final requests = <Completer<List<String>>>[];
      final c = WorkbenchController(
        console,
        fetch: (_, page, fail) {
          final response = Completer<List<String>>();
          requests.add(response);
          return response.future;
        },
      );
      c.draft('preserve this');
      final first = c.load();
      final second = c.load();
      requests[1].complete(['new']);
      await second;
      requests[0].complete(['obsolete']);
      await first;
      expect(c.rows.value, ['new']);
      final canceled = c.load();
      c.cancel();
      requests[2].complete(['canceled']);
      await canceled;
      expect(c.rows.value, ['new']);
      expect(c.status.value, startsWith('Canceled'));
      final failed = c.load(fail: true);
      requests[3].completeError(StateError('service'));
      await failed;
      expect(c.status.value, startsWith('Error'));
      expect(c.draft.value, 'preserve this');
      final retried = c.retry();
      requests[4].complete(['recovered']);
      await retried;
      expect(c.rows.value, ['recovered']);
      final pending = c.load();
      await c.dispose();
      requests[5].complete(['after dispose']);
      await pending;
      expect(c.rows.value, ['recovered']);
      console.dispose();
    },
  );
  test(
    'SQLite save, duplicate rollback, explicit rollback, update, delete and close',
    () async {
      final console = GalleryConsole();
      final c = RecordsController(
        console,
        open: kIsWeb ? openBrowserTestDatabase : null,
      );
      addTearDown(() async {
        await c.dispose();
        console.dispose();
      });
      await c.refresh();
      expect(c.records.value, isEmpty);
      c.draft('First record');
      await c.save();
      expect(c.records.value.single.title, 'First record');
      expect(c.draft.value, isEmpty);
      c.draft('First record');
      await c.save();
      expect(c.status.value, contains('failed'));
      expect(c.draft.value, 'First record');
      expect(c.records.value.length, 1);
      c.draft('Rolled back');
      await c.save(rollback: true);
      await c.refresh();
      expect(c.records.value.length, 1);
      expect(c.draft.value, 'Rolled back');
      await c.rename(c.records.value.single);
      expect(c.records.value.single.title, endsWith('✓'));
      await c.remove(c.records.value.single);
      expect(c.records.value, isEmpty);
      final pending = c.refresh();
      final cleanup = c.dispose();
      expect(identical(cleanup, c.dispose()), isTrue);
      await pending;
      await cleanup;
      await expectLater(c.refresh(), throwsStateError);
    },
  );
}

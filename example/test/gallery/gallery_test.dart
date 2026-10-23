import 'package:example/gallery/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../widget_test.dart' as gallery;
import '../support/browser_assets.dart';
import '../support/tester_helpers.dart';

Future<void> settleIo(WidgetTester tester) async {
  for (var i = 0; i < 150; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
    if (find.byType(LinearProgressIndicator).evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}

void main() {
  configureBrowserAssets();
  reportBrowserFailures();
  testWidgets(
    'recipes retain drafts; source uses real files; mobile dock closes',
    (tester) async {
      await gallery.openGallery(tester);
      await gallery.visit(tester, 'recipes');
      await tester.enterText(
        find.byKey(const ValueKey('recipe-draft')),
        'Keep this draft',
      );
      await tester.tap(find.text('Load first page'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.textContaining('Record 1'), findsOneWidget);
      await gallery.visit(tester, 'values');
      await gallery.visit(tester, 'recipes');
      expect(find.text('Keep this draft'), findsOneWidget);
      await tester.tap(find.text('Model / Controller'));
      await pumpUntil(
        tester,
        () => find
            .textContaining(
              'class WorkbenchController extends ActiveController',
            )
            .evaluate()
            .isNotEmpty,
        reason: 'controller source asset',
      );
      expect(
        find.textContaining(
          'class WorkbenchController extends ActiveController',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('App setup'));
      await pumpUntil(
        tester,
        () => find
            .textContaining('class GalleryShell extends StatefulWidget')
            .evaluate()
            .isNotEmpty,
        reason: 'application source asset',
      );
      expect(
        find.textContaining('class GalleryShell extends StatefulWidget'),
        findsOneWidget,
      );
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Open Activity console'));
      await tester.pumpAndSettle();
      expect(find.byType(DeveloperConsole), findsOneWidget);
      await tester.tap(find.byTooltip('Close console'));
      await tester.pumpAndSettle();
      expect(find.byType(DeveloperConsole), findsNothing);
      expect(tester.takeException(), isNull);
      gallery.routerOf(tester).go('/unknown-gallery-route');
      await tester.pumpAndSettle();
      expect(find.text('Destination unavailable'), findsOneWidget);
      await tester.tap(find.text('Recover to overview'));
      await tester.pumpAndSettle();
      expect(
        find.text('A place to explore.\nA foundation to build on.'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'database UI preserves rollback draft and returns typed route results',
    (tester) async {
      await gallery.openGallery(tester);
      await gallery.visit(tester, 'database');
      await tester.enterText(
        find.byKey(const ValueKey('database-draft')),
        'Gallery record',
      );
      await tester.tap(find.text('Save record'));
      await settleIo(tester);
      expect(find.text('Gallery record'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('database-draft')),
        'Rollback draft',
      );
      await tester.tap(find.text('Simulate transaction rollback'));
      await settleIo(tester);
      expect(find.text('Rollback draft'), findsOneWidget);
      await tester.tap(find.byTooltip('Open record 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update and return typed result'));
      await settleIo(tester);
      expect(find.text('Gallery record ✓'), findsOneWidget);
      expect(find.textContaining('"action": "updated"'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await settleIo(tester);
    },
  );
  test('displayed sources are bundled from the compiled files', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final source = await rootBundle.loadString(
      'lib/gallery/recipes/database_controller.dart',
    );
    expect(source, contains("conflictAlgorithm: ConflictAlgorithm.abort"));
    expect(source, contains('class RecordsDao'));
    expect(source, contains('await _db?.close()'));
  });
}

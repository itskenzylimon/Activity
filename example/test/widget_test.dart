import 'package:flutter/foundation.dart';
import 'support/browser_database.dart';
import 'support/browser_assets.dart';
import 'support/tester_helpers.dart';
import 'package:activity/activity.dart';
import 'package:example/gallery/app.dart';
import 'package:example/gallery/catalog.dart';
import 'package:example/gallery/controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ActivityRouter routerOf(WidgetTester tester) =>
    ActivityRouter.of(tester.element(find.byType(GalleryShell)));
GalleryScope scopeOf(WidgetTester tester) =>
    GalleryScope.of(tester.element(find.byType(GalleryShell)));
Future<void> openGallery(
  WidgetTester tester, {
  Size size = const Size(1440, 1100),
}) async {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(null);
  });
  configureBrowserAssets();
  await tester.binding.setSurfaceSize(size);
  const app = MyApp(openDatabase: kIsWeb ? openBrowserTestDatabase : null);
  if (kIsWeb) {
    await tester.pumpWidget(app);
    await pumpUntil(
      tester,
      () => find.byType(GalleryShell).evaluate().isNotEmpty,
      reason: 'browser gallery startup',
    );
  } else {
    // Host asset-channel file I/O must begin in the real async zone.
    await tester.runAsync(() async {
      await tester.pumpWidget(app);
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (find.byType(GalleryShell).evaluate().isEmpty &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 25));
        await tester.pump();
      }
    });
  }
  await tester.pumpAndSettle();
}

Future<void> visit(WidgetTester tester, String name) async {
  routerOf(tester).goNamed(name);
  await tester.pumpAndSettle();
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  configureBrowserAssets();
  reportBrowserFailures();
  testWidgets('all catalog routes render on desktop and a narrow viewport', (
    tester,
  ) async {
    await openGallery(tester);
    expect(
      find.text('A place to explore.\nA foundation to build on.'),
      findsOneWidget,
    );
    for (final destination in destinations) {
      await visit(tester, destination.id);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Desktop ${destination.id}',
      );
    }
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpAndSettle();
    for (final destination in destinations) {
      await visit(tester, destination.id);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Narrow ${destination.id}',
      );
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets(
    'reactive values, source panels, task CRUD and map operations work',
    (tester) async {
      await openGallery(tester);
      await visit(tester, 'values');
      await tester.tap(find.byKey(const ValueKey('increment')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('counter-value')), findsOneWidget);
      expect(scopeOf(tester).lab.count.value, 1);
      await tester.tap(find.byTooltip('Show source code').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('count.clampTo(0, 100)'), findsOneWidget);
      await visit(tester, 'collections');
      await tester.enterText(
        find.byKey(const ValueKey('task-input')),
        'Ship the gallery',
      );
      await tester.tap(find.text('Add task'));
      await tester.pumpAndSettle();
      expect(scopeOf(tester).lab.tasks.last.title, 'Ship the gallery');
      await reveal(tester, find.byTooltip('Next task page'));
      await tester.tap(find.byTooltip('Next task page'));
      await tester.pumpAndSettle();
      expect(find.text('Ship the gallery'), findsOneWidget);
      await tester.tap(find.byTooltip('Delete Ship the gallery'));
      await tester.pumpAndSettle();
      expect(
        scopeOf(
          tester,
        ).lab.tasks.any((task) => task.title == 'Ship the gallery'),
        isFalse,
      );
      await reveal(tester, find.text('Record update'));
      await tester.tap(find.text('Record update'));
      await tester.pumpAndSettle();
      expect(scopeOf(tester).lab.metrics['updates'], 13);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(null);
    },
  );
  testWidgets('event replay, validator errors and asset configuration work', (
    tester,
  ) async {
    await openGallery(tester);
    await visit(tester, 'events');
    await tester.tap(find.text('Emit sticky'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Attach late subscriber'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Late sticky subscriber → Hello from Activity'),
      findsOneWidget,
    );
    await visit(tester, 'validation');
    await tester.tap(find.text('Fill invalid example'));
    await tester.pumpAndSettle();
    expect(find.text('4 validation errors'), findsOneWidget);
    await tester.tap(find.text('Reset form'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('validate-payload')));
    await tester.pumpAndSettle();
    expect(find.text('Valid payload'), findsOneWidget);
    await visit(tester, 'environment');
    await tester.tap(find.text('Load bundled asset'));
    await pumpUntil(
      tester,
      () => find.textContaining('gallery.example.com').evaluate().isNotEmpty,
      reason: 'real ENV asset',
    );
    expect(find.textContaining('gallery.example.com'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets('nested typed results, async guards and exit confirmation work', (
    tester,
  ) async {
    await openGallery(tester);
    await visit(tester, 'navigation');
    await tester.tap(find.text('Try a fade transition'));
    await tester.pumpAndSettle();
    expect(find.text('Activity transition'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.text('Flutter-native routing and custom transitions'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('open-detail')));
    await tester.pumpAndSettle();
    expect(find.text('Nested details'), findsOneWidget);
    await visit(tester, 'values');
    final shell = tester.widget<GalleryShell>(find.byType(GalleryShell));
    shell.shell.goBranch(destinations.indexWhere((d) => d.id == 'navigation'));
    await tester.pumpAndSettle();
    expect(find.text('Nested details'), findsOneWidget);
    await tester.tap(find.text('Return a typed result'));
    await tester.pumpAndSettle();
    expect(find.text('Selected #42'), findsOneWidget);
    await reveal(tester, find.text('Open guarded account'));
    await tester.tap(find.text('Open guarded account'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
    await tester.pumpAndSettle();
    expect(find.text('The guard redirected you here'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('demo-sign-in')));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Protected account'), findsOneWidget);
    await tester.tap(find.text('Sign out and recheck guard'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
    await tester.pumpAndSettle();
    expect(find.text('The guard redirected you here'), findsOneWidget);
    await visit(tester, 'navigation');
    await tester.tap(find.text('Try exit confirmation'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Unsaved draft');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Editor with an exit guard'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard changes'));
    await tester.pumpAndSettle();
    expect(find.text('Nested destinations & typed results'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets('ICU locale switching, checklist and theme changes work', (
    tester,
  ) async {
    await openGallery(tester);
    await visit(tester, 'localization');
    await tester.tap(find.text('Français'));
    await pumpUntil(
      tester,
      () => find.text('Bonjour Kenzy').evaluate().isNotEmpty,
      reason: 'French localization asset',
    );
    expect(find.text('Bonjour Kenzy'), findsOneWidget);
    expect(find.text('3 tâches'), findsOneWidget);
    await visit(tester, 'guidance');
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();
    expect(find.text('1 of 12 complete'), findsOneWidget);
    await visit(tester, 'settings');
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(scopeOf(tester).settings.theme.value, ThemeMode.dark);
    expect(
      tester
          .widget<SegmentedButton<ThemeMode>>(
            find.byType(SegmentedButton<ThemeMode>),
          )
          .selected,
      {ThemeMode.dark},
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.binding.setSurfaceSize(null);
  });
  testWidgets(
    'widget state, route and preferences restore into a fresh gallery',
    (tester) async {
      await openGallery(tester);
      await visit(tester, 'restoration');
      await tester.tap(find.text('Increment restorable counter'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('restorable-draft')),
        'Retain this draft',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Toggle light / dark theme'));
      await tester.pumpAndSettle();
      final old = routerOf(tester);
      await tester.runAsync(() async {
        await tester.restartAndRestore();
        final deadline = DateTime.now().add(const Duration(seconds: 12));
        while (find.byType(GalleryShell).evaluate().isEmpty &&
            DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 25));
          await tester.pump();
        }
      });
      await tester.pumpAndSettle();
      expect(identical(old, routerOf(tester)), isFalse);
      expect(find.text('Restorable count: 1'), findsOneWidget);
      expect(find.text('Retain this draft'), findsOneWidget);
      expect(scopeOf(tester).settings.theme.value, ThemeMode.dark);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.binding.setSurfaceSize(null);
    },
  );
  testWidgets(
    'shared-key tasks stay busy and temporary controllers dispose safely',
    (tester) async {
      await openGallery(tester);
      await visit(tester, 'async');
      scopeOf(tester).console.configure(true);
      final lab = scopeOf(tester).lab;
      await tester.tap(find.text('Run two with shared key'));
      await tester.pump();
      expect(lab.actively, isTrue);
      await tester.pump(const Duration(milliseconds: 800));
      expect(lab.completed.value, 1);
      expect(lab.actively, isTrue);
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();
      expect(lab.completed.value, 2);
      expect(lab.actively, isFalse);
      await tester.tap(find.text('Simulate failure'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(lab.actively, isFalse);
      expect(
        scopeOf(
          tester,
        ).console.value.any((entry) => entry.message.contains('failed')),
        isTrue,
      );
      await visit(tester, 'lifecycle');
      await tester.tap(find.text('Update count'));
      await tester.pumpAndSettle();
      expect(find.text('Consumer sees count: 1'), findsOneWidget);
      await tester.tap(find.text('Dispose twice'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Same cleanup future: true'), findsOneWidget);
      await tester.tap(find.text('Create fresh controller'));
      await tester.pumpAndSettle();
      expect(find.text('Consumer sees count: 0'), findsOneWidget);
    },
  );
  testWidgets(
    'phone drawer searches destinations and closes after navigation',
    (tester) async {
      await openGallery(tester, size: const Size(390, 844));
      await tester.tap(find.byTooltip('Open navigation'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'ICU');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('nav-localization')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-values')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('nav-localization')));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer).hitTestable(), findsNothing);
      expect(find.text('Bonjour Kenzy'), findsNothing);
      expect(find.text('Hello Kenzy'), findsOneWidget);
    },
  );
}

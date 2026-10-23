import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class Controller extends ActiveController {
  final count = ActiveInt(0, typeName: 'count');
  final title = ActiveString('start');
  final list = ActiveList<int>([1, 2]);
  final map = ActiveMap<String, int>({'a': 1});
  final model = ActiveModel<String>('model');
  @override
  Iterable<ActiveType> get activities => [count, title, list, map, model];
}

class View extends ActiveView<Controller> {
  const View(Controller controller, {super.key})
    : super(activeController: controller);
  @override
  ActiveState<View, Controller> createActivity() => ViewState(activeController);
}

class ViewState extends ActiveState<View, Controller> {
  ViewState(super.activeController);
  @override
  Widget build(BuildContext context) =>
      Text('${activeController.count.value}', textDirection: TextDirection.ltr);
}

void main() {
  late Controller c;
  setUp(() => c = Controller());
  tearDown(() => c.dispose());
  test('same-key tasks stay busy until every operation completes', () async {
    final a = Completer<int>(), b = Completer<int>();
    final first = c.activeAsync(() => a.future, isRunningKey: 'load');
    final second = c.activeAsync(() => b.future, isRunningKey: 'load');
    expect(() => c.activeTasks.clear(), throwsUnsupportedError);
    b.complete(2);
    expect(await second, 2);
    expect(c.actively, isTrue);
    a.complete(1);
    expect(await first, 1);
    expect(c.actively, isFalse);
  });
  test('disposal is idempotent and pending success survives', () async {
    final task = Completer<int>();
    final future = c.activeAsync(() => task.future, isRunningKey: 'load');
    final cleanup = c.dispose();
    expect(identical(cleanup, c.dispose()), isTrue);
    expect(c.isDisposed, isTrue);
    expect(() => c.count(8), throwsStateError);
    expect(c.count.value, 0);
    task.complete(42);
    expect(await future, 42);
    await cleanup;
    expect(c.activeTasks, isEmpty);
    expect(c.actively, isFalse);
  });
  test('disposal preserves original pending error', () async {
    final task = Completer<int>();
    final future = c.activeAsync(() => task.future, isRunningKey: 'load');
    final expectation = expectLater(future, throwsA(isA<FormatException>()));
    await c.dispose();
    task.completeError(const FormatException('original'));
    await expectation;
  });
  test('legacy batch validates every assignment before committing', () {
    expect(
      () => c.activateTypes([
        {c.count: 3},
        {c.title: 10},
      ]),
      throwsArgumentError,
    );
    expect(c.count.value, 0);
  });
  test(
    'typed batch delivers one event list and models register automatically',
    () async {
      final events = Completer<List<ActiveStateChanged>>();
      c.addOnStateChangedListener(events.complete);
      c.activate([c.count.changeTo(7), c.model.changeTo('new')]);
      expect((await events.future).length, 2);
      expect(c.count.value, 7);
      expect(c.model.value, 'new');
    },
  );
  test('dynamic typed batches prevalidate before any mutation', () {
    expect(
      () =>
          c.activate([c.count.changeTo(2), ActiveUpdate<dynamic>(c.title, 3)]),
      throwsArgumentError,
    );
    expect(c.count.value, 0);
  });
  test('identity remains valid in maps after mutation', () {
    final other = ActiveInt(0);
    final lookup = {c.count: 'count', other: 'other'};
    c.count(4);
    expect(lookup[c.count], 'count');
    expect(lookup.length, 2);
    expect(other.equals(0), isTrue);
    expect(other == ActiveInt(0), isFalse);
    expect(c.count.mockValue, 4);
  });
  test('collection reset snapshots survive repeated mutation and resets', () {
    c.list.reset();
    c.list.add(9);
    c.list.reset();
    c.map.reset();
    c.map.addEntry(const MapEntry('b', 2));
    c.map.reset();
    expect(c.list.value, [1, 2]);
    expect(c.map.value, {'a': 1});
    c.list.originalValue.add(99);
    c.resetAllActiveTypes();
    c.list.add(3);
    c.resetAllActiveTypes();
    expect(c.list.value, [1, 2]);
  });
  test(
    'clear snapshots retain previous contents and helper reads old value',
    () async {
      final events = <ActiveStateChanged>[];
      c.addOnStateChangedListener(events.addAll);
      c.list.clear();
      c.map.clear();
      await Future<void>.delayed(Duration.zero);
      expect(events[0].oldValue, [1, 2]);
      expect(events[1].oldValue, {'a': 1});
      final named = [const ActiveStateChanged<int>(2, 1, typeName: 'count')];
      expect(named.oldActiveTypeValue('count'), 1);
    },
  );
  test('self-derived list insertion materializes once', () {
    c.list.addAll(c.list.value.where((v) => v > 0));
    expect(c.list.value, [1, 2, 1, 2]);
    c.list.insertAllAtEnd(c.list.value.where((v) => v == 1));
    expect(c.list.length, 6);
  });
  test('pagination clamps boundaries', () {
    expect(c.list.paginate(pageNumber: 9), isEmpty);
    expect(c.list.paginate(pageSize: 3), [1, 2]);
    expect(() => c.list.paginate(pageSize: 0), throwsArgumentError);
    expect(ActiveList<int>([]).paginate(), isEmpty);
  });
  test(
    'transform, collection, numeric and model helpers notify coherently',
    () {
      c.count.updateValue((v) => v + 3);
      c.count.clampTo(0, 2);
      c.list.replaceAt(0, 8);
      c.list.sort();
      expect(c.count.value, 2);
      expect(c.list.value, [2, 8]);
      expect(c.list.groupBy((v) => v.isEven)[true], [2, 8]);
      expect(c.map.putIfAbsent('a', () => 9), 1);
      c.title.append('!');
      expect(c.title.value, 'start!');
    },
  );
  testWidgets('view rebinds under same key and does not own controller', (
    tester,
  ) async {
    final next = Controller();
    await tester.pumpWidget(View(c));
    c.count(1);
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    await tester.pumpWidget(View(next));
    c.count(2);
    next.count(3);
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);
    final state = tester.state<ViewState>(find.byType(View));
    state.resetActivities();
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(c.isDisposed, isFalse);
    expect(tester.takeException(), isNull);
    await next.dispose();
  });
  testWidgets(
    'Activity scope replaces controller and updates without tracking callback',
    (tester) async {
      final next = Controller();
      final child = Builder(
        builder:
            (context) => Text(
              '${Activity.getActivity<Controller>(context).count.value}',
              textDirection: TextDirection.ltr,
            ),
      );
      await tester.pumpWidget(Activity(c, child: child));
      c.count(5);
      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
      await tester.pumpWidget(Activity(next, child: child));
      expect(find.text('0'), findsOneWidget);
      next.count(6);
      await tester.pumpAndSettle();
      expect(find.text('6'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      next.count(7);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await next.dispose();
    },
  );
  testWidgets('selector ignores unrelated changes and rebinds', (tester) async {
    var builds = 0;
    await tester.pumpWidget(
      ActivitySelector<Controller, int>(
        controller: c,
        select: (c) => c.count.value,
        builder: (_, value, child) {
          builds++;
          return Text('$value', textDirection: TextDirection.ltr);
        },
      ),
    );
    c.title('different');
    await tester.pumpAndSettle();
    expect(builds, 1);
    c.count(1);
    await tester.pumpAndSettle();
    expect(builds, 2);
    await tester.pumpWidget(const SizedBox());
  });
}

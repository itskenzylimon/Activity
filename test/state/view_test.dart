import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;

// === Controllers ===

class TestViewController extends ActiveController {
  final loading = ActiveBool(false, typeName: 'loading');

  void change() => loading.set(!loading.value);

  @override
  Iterable<ActiveType> get activities => [loading];
}

class _TestActiveView extends ActiveController {
  final testActiveView = ActiveString('TestActiveView');

  @override
  Iterable<ActiveType> get activities => [testActiveView];
}

class _TestController extends ActiveController {
  final firstName = ActiveType<String?>(null);
  final lastName = ActiveType<String?>(null);
  final age = ActiveInt(1);

  @override
  Iterable<ActiveType> get activities => [firstName, lastName, age];
}

// === View & State ===

class _MyWidget extends ActiveView<_TestController> {
  final TestViewController testActiveView;
  final _TestActiveView testActiveView2;

  const _MyWidget({
    Key? key,
    required _TestController activeController,
    required this.testActiveView,
    required this.testActiveView2,
  }) : super(key: key, activeController: activeController);

  @override
  ActiveState<_MyWidget, _TestController> createActivity() {
    return _MyWidgetState(activeController);
  }
}

class _MyWidgetState extends ActiveState<_MyWidget, _TestController> {
  _MyWidgetState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Activity<TestViewController>(
        widget.testActiveView,
        onActivityStateChanged: () => math.Random().nextInt(999999).toString(),
        child: Scaffold(
          body: Activity<_TestActiveView>(
            widget.testActiveView2,
            onActivityStateChanged: () => math.Random().nextInt(999999).toString(),
            child: Builder(
              builder: (context) => Center(
                child: Column(
                  children: [
                    Text(activeController.firstName.value ?? ''),
                    Text(activeController.lastName.value ?? ''),
                    Text(activeController.age.value.toString()),
                    Text('${Activity.of<TestViewController>(context).activeController().loading.value}'),
                    Text(Activity.of<_TestActiveView>(context).activeController().testActiveView.value),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// === Tests ===

void main() {
  late _MyWidget mainWidget;
  late _TestController activeController;
  late TestViewController testActiveView;
  late _TestActiveView testActiveView0;

  setUp(() {
    activeController = _TestController();
    testActiveView = TestViewController();
    testActiveView0 = _TestActiveView();

    mainWidget = _MyWidget(
      activeController: activeController,
      testActiveView: testActiveView,
      testActiveView2: testActiveView0,
    );
  });

  testWidgets(
      'Widget updates on single ActiveType update', (tester) async {
    activeController.firstName("John");
    await tester.pumpWidget(mainWidget);

    expect(find.text("John"), findsOneWidget);

    activeController.firstName("Jane");
    await tester.pumpAndSettle();

    expect(find.text("Jane"), findsOneWidget);
  });

  testWidgets(
      'Widget updates when bool ActiveType changes', (tester) async {
    await tester.pumpWidget(mainWidget);
    expect(find.text("false"), findsOneWidget);

    testActiveView.change();
    await tester.pumpAndSettle();

    expect(find.text("true"), findsOneWidget);
  });

  testWidgets(
      'activateTypes - update multiple properties simultaneously', (tester) async {
    const initialFirstName = 'John';
    const initialLastName = 'Doe';
    const initialAge = 88;

    activeController.firstName(initialFirstName);
    activeController.lastName(initialLastName);
    activeController.age(initialAge);

    await tester.pumpWidget(mainWidget);

    expect(find.text(initialFirstName), findsOneWidget);
    expect(find.text(initialLastName), findsOneWidget);
    expect(find.text(initialAge.toString()), findsOneWidget);

    const newFirstName = 'Jane';
    const newLastName = 'Smith';
    const newAge = 42;

    activeController.activateTypes([
      {activeController.firstName: newFirstName},
      {activeController.lastName: newLastName},
      {activeController.age: newAge},
    ]);

    await tester.pumpAndSettle();

    expect(find.text(newFirstName), findsOneWidget);
    expect(find.text(newLastName), findsOneWidget);
    expect(find.text(newAge.toString()), findsOneWidget);
  });

  testWidgets(
      'activateTypes - update initially null properties', (tester) async {
    await tester.pumpWidget(mainWidget);

    const newFirstName = 'Sarah';
    const newLastName = 'Connor';
    const newAge = 35;

    activeController.activateTypes([
      {activeController.firstName: newFirstName},
      {activeController.lastName: newLastName},
      {activeController.age: newAge},
    ]);

    await tester.pumpAndSettle();

    expect(find.text(newFirstName), findsOneWidget);
    expect(find.text(newLastName), findsOneWidget);
    expect(find.text(newAge.toString()), findsOneWidget);
  });

  testWidgets(
      'Widget reflects nested Activity state from controller', (tester) async {
    await tester.pumpWidget(mainWidget);

    expect(find.text(testActiveView0.testActiveView.value), findsOneWidget);
  });

  testWidgets(
      'Widget updates after increment on ActiveInt', (tester) async {
    const int initialAge = 10;
    activeController.age(initialAge);

    await tester.pumpWidget(mainWidget);
    expect(find.text("$initialAge"), findsOneWidget);

    final newAge = activeController.age.increment();
    await tester.pumpAndSettle();

    expect(find.text("$newAge"), findsOneWidget);
  });

  testWidgets(
      'Widget updates after decrement on ActiveInt', (tester) async {
    const int initialAge = 5;
    activeController.age(initialAge);

    await tester.pumpWidget(mainWidget);
    expect(find.text("$initialAge"), findsOneWidget);

    final newAge = activeController.age.decrement();
    await tester.pumpAndSettle();

    expect(find.text("$newAge"), findsOneWidget);
  });

  testWidgets(
      'Multiple nested Activity contexts resolve their respective controllers correctly',
          (tester) async {
        await tester.pumpWidget(mainWidget);

        expect(find.text(testActiveView.loading.value.toString()), findsOneWidget);
        expect(find.text(testActiveView0.testActiveView.value), findsOneWidget);
      });
}

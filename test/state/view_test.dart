import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math' as math;

class TestViewController extends ActiveController {
  final loading = ActiveType<bool>(false, typeName: 'loading');

  void change() => loading(!loading.value);

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
  ActiveState<ActiveView<ActiveController>, _TestController> createActivity() {
    return _MyWidgetState(activeController);
  }
}

class _MyWidgetState extends ActiveState<_MyWidget, _TestController> {
  _MyWidgetState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return Activity<TestViewController>(
      widget.testActiveView,
      onActivityStateChanged: () => math.Random().nextInt(1000000).toString(),
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (outerContext) {
              return Activity(
                widget.testActiveView2,
                onActivityStateChanged: () =>
                    math.Random().nextInt(1000000).toString(),
                child: Builder(builder: (innerContext) {
                  return Center(
                    child: Column(
                      children: [
                        Text(activeController.firstName.value ?? ''),
                        Text(activeController.lastName.value ?? ''),
                        Text(
                          activeController.age.value.toString(),
                        ),
                        Text(
                            '${Activity.of<TestViewController>(outerContext).activeController().loading}'),
                        Text(
                            '${Activity.of<_TestActiveView>(innerContext).activeController().testActiveView}')
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

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
      'ActiveView Test - Finds Correct Text Widget After ActiveType Update',
      (tester) async {
    activeController.firstName("John");
    await tester.pumpWidget(mainWidget);

    expect(find.text("John"), findsOneWidget);

    activeController.firstName("Jane");
    await tester.pumpAndSettle();

    expect(find.text("Jane"), findsOneWidget);
  });

  testWidgets('Active State - Widgets Update on Controller ActiveType Update',
      (tester) async {
    await tester.pumpWidget(mainWidget);

    final text = find.text("false");
    expect(text, findsOneWidget);

    testActiveView.change();

    await tester.pumpAndSettle();

    final textTwo = find.text("true");
    expect(textTwo, findsOneWidget);
  });

  testWidgets('Test [activateTypes] - Update More Than One ActiveTypes - All Widgets Update',
      (tester) async {
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
    const newLastName = 'Doe';
    const newAge = 20;

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
      'Test [activateTypes 2] - Update More Than One Null ActiveTypes update - All Widgets Update',
      (tester) async {
    await tester.pumpWidget(mainWidget);

    const newFirstName = 'Jane';
    const newLastName = 'Doe';
    const newAge = 20;

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

  testWidgets('ActiveView Test - Finds ActiveType Data From Controller',
      (tester) async {
    await tester.pumpWidget(mainWidget);

    expect(find.text(testActiveView0.testActiveView.value), findsOneWidget);
  });

  testWidgets(
      'ActiveView Test - Increment ActiveInt Type - Finds Correct Text Widget After Property Change',
      (tester) async {
    const int initialAge = 10;
    activeController.age(initialAge);
    await tester.pumpWidget(mainWidget);

    expect(find.text("$initialAge"), findsOneWidget);

    final int newAge = activeController.age.increment();
    await tester.pumpAndSettle();

    expect(find.text("$newAge"), findsOneWidget);
  });

  testWidgets(
      'ActiveView Test - Decrement ActiveInt Type - Finds Correct Text Widget After Property Change',
      (tester) async {
    const int initialAge = 10;
    activeController.age(initialAge);
    await tester.pumpWidget(mainWidget);

    expect(find.text("$initialAge"), findsOneWidget);

    final int newAge = activeController.age.decrement();
    await tester.pumpAndSettle();

    expect(find.text("$newAge"), findsOneWidget);
  });
}

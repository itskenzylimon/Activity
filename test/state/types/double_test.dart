import 'package:activity/core/src/controller.dart';
import 'package:activity/core/src/view.dart';
import 'package:activity/core/types/active_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class DoubleTestController extends ActiveController {
  final doubleAmount = ActiveDouble(99.99);

  @override
  Iterable<ActiveType> get activities => [doubleAmount];
}

class DoubleTestView extends ActiveView<DoubleTestController> {
  const DoubleTestView({
    Key? key,
    required DoubleTestController activeController,
  }) : super(key: key, activeController: activeController);

  @override
  ActiveState<ActiveView<ActiveController>, DoubleTestController>
      createActivity() {
    return _DoubleTestViewState(activeController);
  }
}

class _DoubleTestViewState
    extends ActiveState<DoubleTestView, DoubleTestController> {
  _DoubleTestViewState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: Column(
                children: [
                  Text('${activeController.doubleAmount}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('ActiveDouble Test Cases', () {
    late DoubleTestController activeController;
    late DoubleTestView testWidget;

    setUp(() {
      activeController = DoubleTestController();
      testWidget = DoubleTestView(activeController: activeController);
    });

    testWidgets('[doubleAmount] value changes & widget updates',
        (tester) async {
      const double expectedValue = 100.0;

      await tester.pumpWidget(testWidget);

      expect(
          find.text(activeController.doubleAmount.toString()), findsOneWidget);

      activeController.doubleAmount(expectedValue);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
    });

    testWidgets('[add] function on doubleAmount - widget updates',
        (tester) async {
      const double expectedValue = 50.5;
      const double startingValue = 45.45;
      const double addMore = 5.05;

      activeController.doubleAmount(startingValue);

      await tester.pumpWidget(testWidget);

      expect(
          find.text(activeController.doubleAmount.toString()), findsOneWidget);

      final result = activeController.doubleAmount.add(addMore);

      activeController.doubleAmount(result);
      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, equals(expectedValue));
    });

    testWidgets('[subtract] function on doubleAmount - widget updates',
        (tester) async {
      const double expectedValue = 45.45;
      const double startingValue = 50.5;
      const double subtracted = 5.05;

      activeController.doubleAmount(startingValue);

      await tester.pumpWidget(testWidget);

      expect(
          find.text(activeController.doubleAmount.toString()), findsOneWidget);

      final result = activeController.doubleAmount.subtract(subtracted);

      activeController.doubleAmount(result);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, equals(expectedValue));
    });

    testWidgets('[multiply] function on doubleAmount - widget updates',
        (tester) async {
      const double expectedValue = 99.99;
      const double startingValue = 33.33;
      const double multiplier = 3;

      activeController.doubleAmount(startingValue);

      await tester.pumpWidget(testWidget);

      expect(
          find.text(activeController.doubleAmount.toString()), findsOneWidget);

      final result = activeController.doubleAmount.multiply(multiplier);

      activeController.doubleAmount(result);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, equals(expectedValue));
    });

    testWidgets('[divide] function on doubleAmount - widget updates',
        (tester) async {
      const double expectedValue = 33.33;
      const double startingValue = 99.99;
      const double divisor = 3;

      activeController.doubleAmount(startingValue);

      await tester.pumpWidget(testWidget);

      expect(
          find.text(activeController.doubleAmount.toString()), findsOneWidget);

      final result = activeController.doubleAmount.divide(divisor);

      activeController.doubleAmount(result);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, equals(expectedValue));
    });

    test('[round] function on doubleAmount', () {
      const double expectedValue = 100;
      const double startingValue = 99.99;

      activeController.doubleAmount(startingValue);

      final result = activeController.doubleAmount.round();

      expect(result, equals(expectedValue));
    });

    test('[roundToDouble] function on doubleAmount', () {
      const double expectedValue = 50.00;
      const double startingValue = 50.05;

      activeController.doubleAmount(startingValue);

      final result = activeController.doubleAmount.roundToDouble();

      expect(result, equals(expectedValue));
    });

    test(
        '[isNegative] function on doubleAmount - number is negative - returns true',
        () {
      activeController.doubleAmount(-5);
      final result = activeController.doubleAmount.isNegative;
      expect(result, isTrue);
    });

    test(
        '[isNegative] function on doubleAmount - number is not negative - returns true',
        () {
      activeController.doubleAmount(5);
      final result = activeController.doubleAmount.isNegative;
      expect(result, isFalse);
    });

    test('[add] function test - add type int - returns correct double value',
        () {
      const expected = 13;
      final number = ActiveDouble(10);
      final result = number.add(3);

      expect(result, equals(expected));
    });

    test('[add] function test - add type double - returns correct double value',
        () {
      const expected = 5.5;
      final number = ActiveDouble(1.3);
      final result = number.add(4.2);

      expect(result, equals(expected));
    });

    test(
        '[subtract] function test - subtract type double - returns correct double value',
        () {
      const expected = 1.2999999999999998;
      final number = ActiveDouble(5.5);
      final result = number.subtract(4.2);

      expect(result, equals(expected));
    });

    test(
        '[subtract] function test - subtract type int - returns correct double value',
        () {
      const expected = 3.5;
      final number = ActiveDouble(4.5);
      final result = number.subtract(1);

      expect(result, equals(expected));
    });

    test(
        '[multiply] function test - multiply type int - returns correct double value',
        () {
      const expected = 5;
      final number = ActiveDouble(2.5);
      final result = number.multiply(2);

      expect(result, equals(expected));
    });

    test(
        '[multiply] function test - multiply type double - returns correct double value',
        () {
      const expected = 5.5;
      final number = ActiveDouble(2.5);
      final result = number.multiply(2.2);

      expect(result, equals(expected));
    });

    test(
        '[divide] function test - divide type int - returns correct double value',
        () {
      const expected = 4.2;
      final number = ActiveDouble(8.4);
      final result = number.divide(2);

      expect(result, equals(expected));
    });

    test(
        '[mod] function test - other type is int - returns correct double value',
        () {
      const expected = 2;
      final number = ActiveDouble(5);
      final result = number.mod(3);

      expect(result, equals(expected));
    });

    test(
        '[mod] function test - other type is double - returns correct double value',
        () {
      const expected = 1.5;
      final number = ActiveDouble(5);
      final result = number.mod(3.5);

      expect(result, equals(expected));
    });
  });
}

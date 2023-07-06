import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:matcher/src/equals_matcher.dart' as match;

class IntTestController extends ActiveController {
  final count = ActiveInt(100, typeName: 'count');

  @override
  Iterable<ActiveType> get activities => [count];
}

class IntTestView extends ActiveView<IntTestController> {
  const IntTestView({
    Key? key,
    required IntTestController activeController,
  }) : super(key: key, activeController: activeController);

  @override
  ActiveState<ActiveView<ActiveController>, IntTestController> createActivity() {
    return _IntTestViewState(activeController);
  }
}

class _IntTestViewState extends ActiveState<IntTestView, IntTestController> {
  _IntTestViewState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: Column(
                children: [
                  Text('${activeController.count}'),
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
  group('ActiveInt Test Cases', () {
    late IntTestController activeController;
    late IntTestView intTestView;

    setUp(() {
      activeController = IntTestController();
      intTestView = IntTestView(activeController: activeController);
    });

    testWidgets('[count] value changes & widget updates', (tester) async {
      const int expectedValue = 100;

      await tester.pumpWidget(intTestView);

      expect(find.text(activeController.count.toString()), findsOneWidget);

      activeController.count(expectedValue);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
    });

    testWidgets('[add] function on count - widget updates', (tester) async {
      const int expectedValue = 30;
      const int startingValue = 20;
      const int addend = 10;

      activeController.count(startingValue);

      await tester.pumpWidget(intTestView);

      expect(find.text(activeController.count.toString()), findsOneWidget);

      final result = activeController.count.add(addend);

      activeController.count(result);
      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, match.equals(expectedValue));
    });

    testWidgets('[subtract] function on count - widget updates', (tester) async {
      const int expectedValue = 10;
      const int startingValue = 50;
      const int subtrahend = 40;

      activeController.count(startingValue);

      await tester.pumpWidget(intTestView);

      expect(find.text(activeController.count.toString()), findsOneWidget);

      final result = activeController.count.subtract(subtrahend);

      activeController.count(result);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, match.equals(expectedValue));
    });

    testWidgets('[multiply] function on count - widget updates', (tester) async {
      const int expectedValue = 8;
      const int startingValue = 2;
      const int multiplier = 4;

      activeController.count(startingValue);

      await tester.pumpWidget(intTestView);

      expect(find.text(activeController.count.toString()), findsOneWidget);

      final result = activeController.count.multiply(multiplier);

      activeController.count(result);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, match.equals(expectedValue));
    });

    testWidgets('[divide] function on count - widget updates', (tester) async {
      const int expectedValue = 2;
      const int startingValue = 10;
      const int divisor = 5;

      activeController.count(startingValue);

      await tester.pumpWidget(intTestView);

      expect(find.text(activeController.count.toString()), findsOneWidget);

      final result = activeController.count.divide(divisor);

      activeController.count(result.toInt());

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, match.equals(expectedValue));
    });

    test('[isOdd] function test - count is odd - returns true', () {
      activeController.count(27);
      final result = activeController.count.isOdd;
      expect(result, isTrue);
    });

    test('[isOdd] function test - count is not odd - returns false', () {
      activeController.count(12);
      final result = activeController.count.isOdd;
      expect(result, isFalse);
    });

    test('[isEven] function test - count is even - returns true', () {
      activeController.count(12);
      final result = activeController.count.isEven;
      expect(result, isTrue);
    });

    test('[isEven] function test - count is not even - returns true', () {
      activeController.count(9);
      final result = activeController.count.isEven;
      expect(result, isFalse);
    });

    test('[isNegative] function test - count is negative - returns true', () {
      activeController.count(-1);
      final result = activeController.count.isNegative;
      expect(result, isTrue);
    });

    test('[isNegative] function test - count is not negative - returns true', () {
      activeController.count(90);
      final result = activeController.count.isNegative;
      expect(result, isFalse);
    });

    test('[increment] function test - returns increment value', () {
      const int expected = 100;
      activeController.count(99);
      final result = activeController.count.increment();
      expect(result, match.equals(expected));
      expect(activeController.count.value, match.equals(expected));
    });

    test('[decrement] function test - returns decremented value', () {
      const int expected = 99;
      activeController.count(100);
      final result = activeController.count.decrement();
      expect(result, match.equals(expected));
      expect(activeController.count.value, match.equals(expected));
    });

    test('[add] function test - type is int - returns correct int value', () {
      const expected = 100;
      final number = ActiveInt(99);
      final result = number.add(1);

      expect(result, match.equals(expected));
    });

    test('[add] function test - type is double - returns correct double value', () {
      const expected = 100.5;
      final number = ActiveInt(99);
      final result = number.add(1.5);

      expect(result, match.equals(expected));
    });

    test('[subtract] function test - type is int - returns correct int value', () {
      const expected = 99;
      final number = ActiveInt(100);
      final result = number.subtract(1);

      expect(result, match.equals(expected));
    });

    test('[subtract] function test - other is double - returns correct double value', () {
      const expected = 45.9;
      final number = ActiveInt(50);
      final result = number.subtract(4.1);

      expect(result, match.equals(expected));
    });

    test('[multiply] function test - type is int - returns correct int value', () {
      const expected = 200;
      final number = ActiveInt(2);
      final result = number.multiply(100);

      expect(result, match.equals(expected));
    });

    test('[multiply] function test - type is double - returns correct double value', () {
      const expected = 25.0;
      final number = ActiveInt(50);
      final result = number.multiply(0.5);

      expect(result, match.equals(expected));
    });

    test('[divide] function test - returns correct double value', () {
      const expected = 50;
      final number = ActiveInt(100);
      final result = number.divide(2);

      expect(result, match.equals(expected));
    });

    test('[mod] function test - type is int - returns correct int value', () {
      const expected = 2;
      final number = ActiveInt(5);
      final result = number.mod(3);

      expect(result, match.equals(expected));
    });

    test('[mod] function test - type is double - returns correct double value', () {
      const expected = 1.5;
      final number = ActiveInt(5);
      final result = number.mod(3.5);

      expect(result, match.equals(expected));
    });
  });
}
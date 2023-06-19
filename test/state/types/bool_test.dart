import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class BoolTestController extends ActiveController {
  final switchCase = ActiveBool(true, typeName: 'switchCase');

  @override
  Iterable<ActiveType> get activities => [switchCase];
}

class BoolNullTestController extends ActiveController {
  final switchNullCase = ActiveNullableBool();

  @override
  Iterable<ActiveType> get activities => [switchNullCase];
}

class BoolTestView extends ActiveView<BoolTestController> {
  const BoolTestView({
    Key? key,
    required BoolTestController activeController,
  }) : super(key: key, activeController: activeController);

  @override
  ActiveState<ActiveView<ActiveController>, BoolTestController> createActivity() =>
      _BoolTestState(activeController);
}

class _BoolTestState extends ActiveState<BoolTestView, BoolTestController> {
  _BoolTestState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: Column(
                children: [
                  Text('${activeController.switchCase}'),
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
  group('ActiveBool Test Cases', () {
    late BoolTestController activeController;
    late BoolTestView boolTestView;
    setUp(() {
      activeController = BoolTestController();
      boolTestView = BoolTestView(activeController: activeController);
    });

    testWidgets('[switchCase] value changes and widget updates.',
            (tester) async {
      await tester.pumpWidget(boolTestView);

      expect(find.text("true"), findsOneWidget);

      activeController.switchCase(false);

      await tester.pumpAndSettle();

      expect(find.text("false"), findsOneWidget);
    });

    test('[isTrue] - set switchCase to true - returns true', () {
      activeController.switchCase(true);
      expect(activeController.switchCase.isTrue, isTrue);
    });

    test('[isTrue] - set switchCase to false - returns false', () {
      activeController.switchCase(false);
      expect(activeController.switchCase.isTrue, isFalse);
    });

    test('[isFalse] - set switchCase is false - returns true', () {
      activeController.switchCase(false);
      expect(activeController.switchCase.isFalse, isTrue);
    });

    test('[isFalse] - set switchCase is true - returns false', () {
      activeController.switchCase(true);
      expect(activeController.switchCase.isFalse, isFalse);
    });

    test('[setTrue] - set switchCase value to true - returns true', () {
      activeController.switchCase.set(false);
      activeController.switchCase.setTrue();
      expect(activeController.switchCase.isTrue, isTrue);
    });

    test('[setFalse] - set switchCase value to false - returns true', () {
      activeController.switchCase.set(true);
      activeController.switchCase.setFalse();
      expect(activeController.switchCase.isFalse, isTrue);
    });
  });

  group('ActiveNullableBool Test Cases', () {
    late BoolNullTestController activeController;

    setUp(() {
      activeController = BoolNullTestController();
    });

    test('[isTrue] - set switchNullCase to true - returns true', () {
      activeController.switchNullCase(true);
      expect(activeController.switchNullCase.isTrue, isTrue);
    });

    test('[isTrue] - set switchNullCase to false - returns false', () {
      activeController.switchNullCase(false);
      expect(activeController.switchNullCase.isTrue, isFalse);
    });

    test('[isFalse] - set switchNullCase is false - returns true', () {
      activeController.switchNullCase(false);
      expect(activeController.switchNullCase.isFalse, isTrue);
    });

    test('[isFalse] - set switchNullCase is true - returns false', () {
      activeController.switchNullCase(true);
      expect(activeController.switchNullCase.isFalse, isFalse);
    });

    test('[setTrue] - set switchNullCase value to true - returns true', () {
      activeController.switchNullCase.set(false);
      activeController.switchNullCase.setTrue();
      expect(activeController.switchNullCase.isTrue, isTrue);
    });

    test('[setFalse] - set switchNullCase value to false - returns true', () {
      activeController.switchNullCase.set(true);
      activeController.switchNullCase.setFalse();
      expect(activeController.switchNullCase.isFalse, isTrue);
    });

    test('[setNull] - set switchNullCase value to null - returns true', () {
      activeController.switchNullCase.set(false);
      activeController.switchNullCase.setNull();
      expect(activeController.switchNullCase.isNull, isTrue);
    });
  });
}
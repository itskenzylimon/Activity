import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:matcher/src/equals_matcher.dart' as match;

class StringTestController extends ActiveController {
  final country = ActiveString('Kenya');

  @override
  Iterable<ActiveType> get activities => [country];
}

class StringNullableTestController extends ActiveController {
  final country = ActiveNullableString();

  @override
  Iterable<ActiveType> get activities => [country];
}

class StringTestView extends ActiveView<StringTestController> {
  const StringTestView({
    Key? key,
    required StringTestController activeController,
  }) : super(key: key, activeController: activeController);

  @override
  ActiveState<ActiveView<ActiveController>, StringTestController> createActivity() {
    return _StringTestViewState(activeController);
  }
}

class _StringTestViewState
    extends ActiveState<StringTestView, StringTestController> {
  _StringTestViewState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('${activeController.country}'),
              ],
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('ActiveString Test Cases', () {
    late StringTestController activeController;
    late StringTestView testWidget;

    setUp(() {
      activeController = StringTestController();
      testWidget = StringTestView(activeController: activeController);
    });

    testWidgets('string value changes - widget updates', (tester) async {
      const String expectedValue = 'England';

      await tester.pumpWidget(testWidget);

      expect(find.text(activeController.country.value), findsOneWidget);

      activeController.country.set(expectedValue);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue), findsOneWidget);
    });

    test('[isEmpty] function test - value is an empty string - returns true', () {
      activeController.country.set('');
      final result = activeController.country.isEmpty;

      expect(result, isTrue);
    });

    test('[isEmpty] function test - value is not an empty string - returns false', () {
      activeController.country.set('England');
      final result = activeController.country.isEmpty;

      expect(result, isFalse);
    });

    test('[isNotEmpty] function test - value is an empty string - returns false', () {
      activeController.country.set('');
      final result = activeController.country.isNotEmpty;

      expect(result, isFalse);
    });

    test('[isNotEmpty] function test - value is not an empty string - returns true', () {
      activeController.country.set('England');
      final result = activeController.country.isNotEmpty;

      expect(result, isTrue);
    });

    test('[length] function test - returns correct int value', () {
      const int expectedValue = 5;
      const String nameValue = 'Kenya';

      activeController.country.set(nameValue);
      final result = activeController.country.length;

      expect(result, match.equals(expectedValue));
    });

    test('[contains] function test - finds matching string - returns true', () {
      const String nameValue = 'England';
      activeController.country.set(nameValue);

      final result = activeController.country.contains('l');

      expect(result, isTrue);
    });

    test('[contains] function test - no matching string - returns false', () {
      const String nameValue = 'Sudan';
      activeController.country(nameValue);

      final result = activeController.country.contains('Y');

      expect(result, isFalse);
    });

    test('[substring] function test - only pass start index value - returns correct substring',
            () {
          const String nameValue = 'Uganda';
          const String expectedValue = 'ganda';
          activeController.country(nameValue);

          final result = activeController.country.substring(1);

          expect(result, match.equals(expectedValue));
        });

    test(
        '[substring] function test - pass start and end index value - returns correct substring',
            () {
          const String nameValue = 'England';
          const String expectedValue = 'gla';
          activeController.country(nameValue);

          final result = activeController.country.substring(2, 5);

          expect(result, match.equals(expectedValue));
        });
  });

  group('ActiveNullableString Test Cases', () {
    late StringNullableTestController activeController;

    setUp(() {
      activeController = StringNullableTestController();
    });

    test('[isEmpty] function test - value is null - returns true', () {
      activeController.country.set(null);
      final result = activeController.country.isEmpty;

      expect(result, isTrue);
    });

    test('[isNotEmpty] function test - value is null - returns false', () {
      activeController.country.set(null);
      final result = activeController.country.isNotEmpty;

      expect(result, isFalse);
    });

    test('[length] function test - value is null - returns 0', () {
      const int expectedValue = 0;
      activeController.country.set(null);
      final result = activeController.country.length;

      expect(result, match.equals(expectedValue));
    });

    test('[contains] function test - value is null - returns false', () {
      activeController.country.set(null);
      final result = activeController.country.contains('Tanzania');

      expect(result, isFalse);
    });

    test('[substring] function test - value is null - returns null', () {
      activeController.country.set(null);
      final result = activeController.country.substring(1);

      expect(result, isNull);
    });
  });
}
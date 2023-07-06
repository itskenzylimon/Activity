import 'package:activity/activity.dart';
import 'package:activity/core/src/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:matcher/src/equals_matcher.dart' as match;

class TypeTestController extends ActiveController {
  final ActiveType<String?> country = ActiveType(null);
  final ActiveType<int> population = ActiveType(1);

  @override
  Iterable<ActiveType> get activities => [country, population];
}

class TypeTestView extends ActiveView<TypeTestController> {
  const TypeTestView({
    Key? key,
    required TypeTestController activeController,
  }) : super(key: key, activeController: activeController);

  @override
  ActiveState<ActiveView<ActiveController>, TypeTestController> createActivity() {
    return _MyWidgetState(activeController);
  }
}

class _MyWidgetState extends ActiveState<TypeTestView, TypeTestController> {
  _MyWidgetState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: Column(
                children: [
                  Text(activeController.country.value ?? ''),
                  Text(activeController.population.toString()),
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
  late TypeTestController activeController;
  late TypeTestView testWidget;

  setUp(() {
    activeController = TypeTestController();
    testWidget = TypeTestView(activeController: activeController);
  });

  group('ActiveType Creation Test Cases', () {
    test('Create Null ActiveType - Value is Null', () {
      final population = ActiveType<int?>(null);
      expect(population.value, isNull);
    });

    test('Create ActiveType - passed value equals property value', () {
      const expectedValue = 10;
      final population = ActiveType<int>(expectedValue);
      expect(population.value, match.equals(expectedValue));
    });

    test('Create ActiveType - set optional typeName', () {
      const expectedValue = 'population';
      final population = ActiveType<int>(10, typeName: expectedValue);
      expect(population.typeName, match.equals(expectedValue));
    });
  });

  group('ActiveType Equality Test Cases', () {
    test('equals - other is same value - are equal', () {
      final languages = ActiveType<int>(45);
      const int newLanguages = 45;

      expect(languages.equals(newLanguages), isTrue);
    });

    test('equals - other is different value - are not equal', () {
      final languages = ActiveType<int>(12);
      const int newLanguages = 3;

      expect(languages.equals(newLanguages), isFalse);
    });

    test('equals - other is ActiveType with same value - are equal', () {
      final languages = ActiveType<int>(6);
      final newLanguages = ActiveType<int>(6);

      expect(languages.equals(newLanguages), isTrue);
    });

    test(
        'equals - other is ActiveType with different value - are not equal',
            () {
          final languages = ActiveType<int>(30);
          final newLanguages = ActiveType<int>(5);

          expect(languages.equals(newLanguages), isFalse);
        });

    test('equals - other is ActiveType with same value - are equal', () {
      final languages = ActiveType<int>(99);
      const double newLanguages = 99.0;

      expect(languages.equals(newLanguages), isTrue);
    });

    test('equality - other is ActiveType with same value - are equal', () {
      final languages = ActiveType<int>(64);
      final newLanguages = ActiveType<int>(64);

      expect(languages == newLanguages, isTrue);
    });

    test(
        'equality - other is ActiveType with different value - are not equal',
            () {
          final languages = ActiveType<int>(46);
          final newLanguages = ActiveType<int>(64);

          expect(languages == newLanguages, isFalse);
        });

    test(
        'equality - other is same as ActiveType generic type argument with same value - are equal',
            () {
          final languages = ActiveType<int>(3);
          const int newLanguages = 3;

          // ignore: unrelated_type_equality_checks
          expect(languages == newLanguages, isTrue);
        });

    test(
        'equality - other is same as ActiveType generic type argument with different value - are not equal',
            () {
          final languages = ActiveType<int>(10);
          const int newLanguages = 5;

          // ignore: unrelated_type_equality_checks
          expect(languages == newLanguages, isFalse);
        });

    test(
        'equality - other is not ActiveType or generic type argument - are not equal',
            () {
          final languages = ActiveType<int>(45);
          const String newLanguages = '40';

          // ignore: unrelated_type_equality_checks
          expect(languages == newLanguages, isFalse);
        });

    test('isNull - value is null - returns true', () {
      final nullName = ActiveType<String?>(null);
      expect(nullName.isNull, isTrue);
    });

    test('isNull - value is not null - returns false', () {
      final nullName = ActiveType<String>('John Doe');
      expect(nullName.isNull, isFalse);
    });

    test('isNotNull - value is not null - returns true', () {
      final nullName = ActiveType<String>('John Doe');
      expect(nullName.isNotNull, isTrue);
    });

    test('isNotNull - value is null - returns false', () {
      final nullName = ActiveType<String?>(null);
      expect(nullName.isNotNull, isFalse);
    });

    test(
        'set - property not assigned to activeController - throws ActiveTypeNotAssignedException',
            () {
          final property = ActiveType<String?>(null);

          expect(() => property('John Doe'),
              throwsA(isA<ActiveTypeNotAssignedException>()));
        });
  });

  group('ActiveType Original Value Test Cases', () {
    test(
        'setOriginalToCurrent - update original value - reset sets value to updated original ',
            () {
          const String expectedValue = 'John Doe';
          final country = ActiveType<String?>(expectedValue, typeName: 'country');
          country.setActiveController(activeController);

          expect(country.value, match.equals(expectedValue));

          country('Jane Doe');

          expect(country.value, match.equals('Jane Doe'));

          country.reset();

          expect(country.value, match.equals(expectedValue));
        });

    test(
        'setOriginalToCurrent - update original value - reset sets value to original null value',
            () {
          const String expectedValue = 'John Doe';
          final country = ActiveType<String?>(null, typeName: 'country');
          country.setActiveController(activeController);
          country(expectedValue);

          expect(country.value, match.equals(expectedValue));

          country.reset();

          expect(country.isNull, isTrue);
        });

    test(
        'setAsOriginal - argument is false - original not set to current value',
            () {
          const String expected = 'John Doe';
          final country = ActiveType<String?>(expected);
          country.setActiveController(activeController);

          country('Jane Doe', setAsOriginal: false);

          expect(country.originalValue, match.equals(expected));
        });

    test('setAsOriginal - argument is true - original is set to current value',
            () {
          const String expected = 'Jane Doe';
          final country = ActiveType<String?>('John Doe');
          country.setActiveController(activeController);

          country(expected, setAsOriginal: true);

          expect(country.originalValue, match.equals(expected));
        });
  });

  group('ActiveType Reset Test Cases', () {
    testWidgets('reset - notifyChange is true - UI Updates', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text("1"), findsOneWidget);

      activeController.population(1000000);

      await tester.pumpAndSettle();

      expect(find.text("1000000"), findsOneWidget);

      activeController.population.reset();

      await tester.pumpAndSettle();

      expect(find.text("1"), findsOneWidget);
    });

    testWidgets('reset - notifyChange is false - UI Does Not Update',
            (tester) async {
          await tester.pumpWidget(testWidget);

          expect(find.text("1"), findsOneWidget);

          activeController.population(1000000);

          await tester.pumpAndSettle();

          expect(find.text("1000000"), findsOneWidget);

          activeController.population.reset(notifyChange: false);

          await tester.pumpAndSettle();

          expect(find.text("1000000"), findsOneWidget);
        });
  });
}
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:matcher/src/equals_matcher.dart' as match;

class ListTestController extends ActiveController {
  final countries = ActiveList<String>.empty();

  @override
  Iterable<ActiveType> get activities => [countries];
}

class ListTestView extends ActiveView<ListTestController> {
  const ListTestView({
    Key? key,
    required ListTestController activeController,
  }) : super(key: key, activeController: activeController);

  @override
  ActiveState<ActiveView<ActiveController>, ListTestController> createActivity() {
    return _ListTestWidgetState(activeController);
  }
}

class _ListTestWidgetState extends ActiveState<ListTestView, ListTestController> {
  _ListTestWidgetState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: activeController.countries.value.map((e) => Text(e)).toList(),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('ActiveList Test Cases', () {
    late ListTestController activeController;
    late ListTestView listTestView;
    setUp(() {
      activeController = ListTestController();
      listTestView = ListTestView(activeController: activeController);
    });

    testWidgets('[single entry] new item added to list - widget updates', (tester) async {
      String kenya = 'Kenya';

      await tester.pumpWidget(listTestView);

      expect(find.text(kenya), findsNothing);

      activeController.countries.add(kenya);

      await tester.pumpAndSettle();

      expect(find.text(kenya), findsOneWidget);
    });

    testWidgets('[multiple entries] multiple items added - widget updates', (tester) async {
      String kenya = 'Kenya';
      String england = 'England';

      await tester.pumpWidget(listTestView);

      expect(find.text(kenya), findsNothing);
      expect(find.text(england), findsNothing);

      activeController.countries.addAll([kenya, england]);

      await tester.pumpAndSettle();

      expect(find.text(kenya), findsOneWidget);
      expect(find.text(england), findsOneWidget);
    });

    testWidgets('[remove an entry] add an item - widget updates', (tester) async {
      String kenya = 'Kenya';
      activeController.countries.add(kenya);

      await tester.pumpWidget(listTestView);

      expect(find.text(kenya), findsOneWidget);

      activeController.countries.remove(kenya);

      await tester.pumpAndSettle();

      expect(find.text(kenya), findsNothing);
    });

    testWidgets('[removeAt] - widget updates', (tester) async {
      String kenya = 'Kenya';
      String england = 'England';

      activeController.countries.addAll([kenya, england]);

      await tester.pumpWidget(listTestView);

      expect(find.text(kenya), findsOneWidget);
      expect(find.text(england), findsOneWidget);

      activeController.countries.removeAt(1);

      await tester.pumpAndSettle();

      expect(find.text(kenya), findsOneWidget);
      expect(find.text(england), findsNothing);
    });

    testWidgets('[clear] - remove all items in countries - widget updates', (tester) async {
      String kenya = 'Kenya';
      String england = 'England';

      activeController.countries.addAll([kenya, england]);

      await tester.pumpWidget(listTestView);

      expect(find.text(kenya), findsOneWidget);
      expect(find.text(england), findsOneWidget);

      activeController.countries.clear();

      await tester.pumpAndSettle();

      expect(find.text(kenya), findsNothing);
      expect(find.text(england), findsNothing);
    });

    test('[contains] - when countries contains item - returns true', () {
      String kenya = 'Kenya';
      activeController.countries.add(kenya);
      final result = activeController.countries.contains(kenya);
      expect(result, isTrue);
    });

    test('[contains] - when countries does not contain item - returns true', () {
      String kenya = 'Kenya';
      String england = 'England';

      activeController.countries.add(kenya);

      final result = activeController.countries.contains(england);

      expect(result, isFalse);
    });

    test('[indexOf] - countries contains item - returns correct index', () {
      String kenya = 'Kenya';
      const int expectedIndex = 0;

      activeController.countries.add(kenya);

      final result = activeController.countries.indexOf(kenya);

      expect(result, match.equals(expectedIndex));
    });

    test('[countries[]] - pass valid index value - returns correct value', () {
      String kenya = 'Kenya';

      activeController.countries.add(kenya);

      final result = activeController.countries[0];

      expect(result, match.equals(kenya));
    });

    test(
        'map - generate different type in map function - returns correct values',
            () {
          String kenya = 'Kenya';
          String england = 'England';

          activeController.countries.addAll([kenya, england]);

          final results = activeController.countries.map((country) => country.length).toList();

          expect(results, const TypeMatcher<List<int>>());
        });

    test('[isEmpty] - checks if countries list is empty - returns true', () {
      final emptyList = ActiveList<String>.empty();

      expect(emptyList.isEmpty, isTrue);
    });

    test('[isEmpty] - when list is not empty - returns false', () {
      final genders = ActiveList<String>(['Female']);

      expect(genders.isEmpty, isFalse);
    });

    test('[isNotEmpty] - when list is empty - returns false', () {
      final genders = ActiveList<String>.empty();

      expect(genders.isNotEmpty, isFalse);
    });

    test('[isNotEmpty] - when list is not empty - returns true', () {
      final genders = ActiveList<String>(['Male']);

      expect(genders.isNotEmpty, isTrue);
    });

    test(
        '[reset] function test - starting list is empty - add item - should be empty after reset',
            () {
          final genders = ActiveList<String>.empty();
          genders.setActiveController(activeController);
          genders.add('Female');
          genders.reset();
          expect(genders.isEmpty, isTrue);
        });

    test(
        '[reset] function testing - starting list has data - remove item - only original data after reset',
            () {
          const String country = 'Kenya';
          final data = ActiveList<String>([country]);
          data.setActiveController(activeController);

          expect(data.contains(country), isTrue);

          data.clear();

          expect(data.contains(country), isFalse);

          data.reset();

          expect(data.contains(country), isTrue);
        });

    test('[elementAt] - list is not empty - returns correct object', () {
      const String expected = 'Kenya';
      const int index = 1;
      final list = ActiveList<String>(['England', expected]);

      final result = list.elementAt(index);

      expect(result, match.equals(expected));
    });

    test(
      '[where] - list is not empty - returns items in list matching predicate',
          () {
        const expectedLength = 3;
        final expectedItems = [3, 4, 5];
        final numbers = ActiveList([1, 2, ...expectedItems]);
        final result = numbers.where((x) => x > 2);

        expect(result.length, match.equals(expectedLength));
        expect(result, match.equals(expectedItems));
      },
    );

    test(
      '[firstWhere] - returns first matching item',
          () {
        const expected = 3;
        final numbers = ActiveList([1, 2, 3]);
        final result = numbers.firstWhere((element) => element == expected);

        expect(result, match.equals(expected));
      },
    );

    test(
      '[firstWhere] - no match found - returns result from or Else',
          () {
        const expected = -1;
        final numbers = ActiveList([1, 2, 3]);
        final result = numbers.firstWhere(
              (element) => element == expected,
          orElse: () => expected,
        );

        expect(result, match.equals(expected));
      },
    );

    test(
      '[firstWhereOrNull] - match found - returns first matching item',
          () {
        const expected = 3;
        final numbers = ActiveList([1, 2, 3]);
        final result =
        numbers.firstWhereOrNull((element) => element == expected);

        expect(result, match.equals(expected));
      },
    );

    test(
      '[firstWhereOrNull] - no match found - returns null',
          () {
        const expected = -1;
        final numbers = ActiveList([1, 2, 3]);
        final result =
        numbers.firstWhereOrNull((element) => element == expected);

        expect(result, isNull);
      },
    );

    test(
      '[indexWhere] - match found - returns correct index',
          () {
        const expected = 2;
        final numbers = ActiveList([1, 2, 3]);
        final result = numbers.indexWhere((element) => element == 3);

        expect(result, match.equals(expected));
      },
    );

    test(
      '[indexWhere] - no match found - returns -1',
          () {
        const expected = -1;
        final numbers = ActiveList([1, 2, 3]);
        final result = numbers.indexWhere((element) => element == expected);

        expect(result, match.equals(expected));
      },
    );

    test('[reversed] -  - returns reversed list', () {
      final expected = [3, 2, 1];
      final numbers = ActiveList([1, 2, 3]);
      final reversed = numbers.reversed;
      expect(reversed, match.equals(expected));
    });

    test('[first] - list is not empty - returns first item', () {
      const expected = 1;
      final numbers = ActiveList([1, 2, 3]);
      final first = numbers.first;
      expect(first, match.equals(expected));
    });

    test('[last] - list is not empty - returns last item', () {
      const expected = 3;
      final numbers = ActiveList([1, 2, 3]);
      final last = numbers.last;
      expect(last, match.equals(expected));
    });

    test('[single] - list contains one item - returns item', () {
      const expected = 1;
      final numbers = ActiveList([expected]);
      final single = numbers.single;
      expect(single, match.equals(expected));
    });

    test('[insert] - returns correct item at new index', () {
      const expectedNumber = 10;
      const expectedIndex = 1;
      final numbers = ActiveList([1, 2, 3]);

      numbers.insert(expectedIndex, expectedNumber, notifyChanges: false);

      expect(numbers[expectedIndex], expectedNumber);
    });

    test('[insertAll] - returns correct items at new index', () {
      const expectedNumbers = [10, 11, 12];
      const expectedIndex = 1;
      final numbers = ActiveList([1, 2, 3]);

      numbers.insertAll(expectedIndex, expectedNumbers, notifyChanges: false);

      expect(
        numbers.value.sublist(
          expectedIndex,
          expectedNumbers.length + expectedIndex,
        ),
        expectedNumbers,
      );
    });

    test('[insertAllAtEnd] - returns correct items at end of list', () {
      final expectedNumbers = [10, 11, 12];
      final numbers = ActiveList([1, 2, 3]);
      final initialListLength = numbers.length;

      numbers.insertAllAtEnd(expectedNumbers, notifyChanges: false);

      expect(numbers.value.sublist(initialListLength), expectedNumbers);
    });

    test('[toString] - returns correct string', () {
      final numbers = ActiveList([1, 2, 3]);
      const expected = '[1, 2, 3]';
      expect(numbers.toString(), expected);
    });
  });
}
import 'package:activity/core/src/controller.dart';
import 'package:activity/core/src/view.dart';
import 'package:activity/core/types/active_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class MapTestController extends ActiveController {
  final countryMap = ActiveMap<String, String>.empty();

  @override
  Iterable<ActiveType> get activities => [countryMap];
}

class MapTestView extends ActiveView<MapTestController> {
  const MapTestView({
    Key? key,
    required MapTestController activeController,
  }) : super(key: key, activeController: activeController);

  @override
  ActiveState<ActiveView<ActiveController>, MapTestController>
      createActivity() {
    return _MapTestViewState(activeController);
  }
}

class _MapTestViewState extends ActiveState<MapTestView, MapTestController> {
  _MapTestViewState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: Column(
                children: [
                  ...activeController.countryMap.value.keys
                      .map((e) => Text(e))
                      .toList(),
                  ...activeController.countryMap.value.values
                      .map((e) => Text(e))
                      .toList()
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
  group('ActiveMap Test Cases', () {
    late MapTestController activeController;
    late MapTestView mapTestView;
    setUp(() {
      activeController = MapTestController();
      mapTestView = MapTestView(activeController: activeController);
    });

    testWidgets('[add] function test - widget updates', (tester) async {
      const String expectedKey = 'name';
      const String expectedValue = 'Kenya';

      await tester.pumpWidget(mapTestView);

      expect(find.text(expectedKey), findsNothing);
      expect(find.text(expectedValue), findsNothing);

      activeController.countryMap.add(expectedKey, expectedValue);

      await tester.pumpAndSettle();

      expect(find.text(expectedKey), findsOneWidget);
      expect(find.text(expectedValue), findsOneWidget);
    });

    testWidgets('[addEntry] function test - widget updates', (tester) async {
      const String expectedKey = 'name';
      const String expectedValue = 'Kenya';

      await tester.pumpWidget(mapTestView);

      expect(find.text(expectedKey), findsNothing);
      expect(find.text(expectedValue), findsNothing);

      activeController.countryMap
          .addEntry(const MapEntry(expectedKey, expectedValue));

      await tester.pumpAndSettle();

      expect(find.text(expectedKey), findsOneWidget);
      expect(find.text(expectedValue), findsOneWidget);
    });

    testWidgets('[addEntries] function test - widget updates', (tester) async {
      const String expectedKeyOne = 'name';
      const String expectedValueOne = 'Kenya';
      const String expectedKeyTwo = 'code';
      const String expectedValueTwo = '254';

      await tester.pumpWidget(mapTestView);

      expect(find.text(expectedKeyOne), findsNothing);
      expect(find.text(expectedValueOne), findsNothing);
      expect(find.text(expectedKeyTwo), findsNothing);
      expect(find.text(expectedValueTwo), findsNothing);

      activeController.countryMap.addEntries([
        const MapEntry(expectedKeyOne, expectedValueOne),
        const MapEntry(expectedKeyTwo, expectedValueTwo)
      ]);

      await tester.pumpAndSettle();

      expect(find.text(expectedKeyOne), findsOneWidget);
      expect(find.text(expectedValueOne), findsOneWidget);
      expect(find.text(expectedKeyTwo), findsOneWidget);
      expect(find.text(expectedValueTwo), findsOneWidget);
    });

    testWidgets('[addAll] function test - widget updates', (tester) async {
      const String expectedKeyOne = 'name';
      const String expectedValueOne = 'Kenya';
      const String expectedKeyTwo = 'code';
      const String expectedValueTwo = '254';

      await tester.pumpWidget(mapTestView);

      expect(find.text(expectedKeyOne), findsNothing);
      expect(find.text(expectedValueOne), findsNothing);
      expect(find.text(expectedKeyTwo), findsNothing);
      expect(find.text(expectedValueTwo), findsNothing);

      activeController.countryMap.addAll({
        expectedKeyOne: expectedValueOne,
        expectedKeyTwo: expectedValueTwo,
      });

      await tester.pumpAndSettle();

      expect(find.text(expectedKeyOne), findsOneWidget);
      expect(find.text(expectedValueOne), findsOneWidget);
      expect(find.text(expectedKeyTwo), findsOneWidget);
      expect(find.text(expectedValueTwo), findsOneWidget);
    });

    testWidgets('[update] function test - key will be present - widget updates',
        (tester) async {
      const String keyOne = 'name';
      const String valueOne = 'Kenya';
      const String keyTwo = 'code';
      const String valueTwo = '254';
      const String expectedUpdatedValue = 'England';

      final Map<String, String> countryMap = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      activeController.countryMap.addAll(countryMap);

      await tester.pumpWidget(mapTestView);

      activeController.countryMap
          .update(keyOne, (value) => value = expectedUpdatedValue);

      await tester.pumpAndSettle();

      expect(find.text(expectedUpdatedValue), findsOneWidget);
    });

    testWidgets(
        '[update] using the ifAbsent option - key will not be preset - widget updates',
        (tester) async {
      const String keyOne = 'name';

      const String expectedUpdatedValue = 'Population';

      await tester.pumpWidget(mapTestView);

      activeController.countryMap.update(
        keyOne,
        (value) => value = expectedUpdatedValue,
        ifAbsent: () => expectedUpdatedValue,
      );

      await tester.pumpAndSettle();

      expect(find.text(expectedUpdatedValue), findsOneWidget);
    });

    testWidgets(
        '[updateAll] function test - will updates all values - widget updates',
        (tester) async {
      const String keyOne = 'name';
      const String valueOne = 'Kenya';
      const String keyTwo = 'language';
      const String valueTwo = 'Swahili';
      const String expectedValueOne = 'KENYA';
      const String expectedValueTwo = 'SWAHILI';

      final Map<String, String> countryMap = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      activeController.countryMap.addAll(countryMap);

      await tester.pumpWidget(mapTestView);

      expect(find.text(expectedValueOne), findsNothing);
      expect(find.text(expectedValueTwo), findsNothing);

      activeController.countryMap
          .updateAll((key, value) => value.toUpperCase());

      await tester.pumpAndSettle();

      expect(find.text(expectedValueOne), findsOneWidget);
      expect(find.text(expectedValueTwo), findsOneWidget);
    });

    testWidgets(
        '[remove] function test - key is present - item removed - widget updates',
        (tester) async {
      const String keyOne = 'name';
      const String valueOne = 'Kenya';
      const String keyTwo = 'code';
      const String valueTwo = '254';

      final Map<String, String> countryMap = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      activeController.countryMap.addAll(countryMap);

      await tester.pumpWidget(mapTestView);

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsOneWidget);
      expect(find.text(valueTwo), findsOneWidget);

      activeController.countryMap.remove(keyTwo);

      await tester.pumpAndSettle();

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsNothing);
      expect(find.text(valueTwo), findsNothing);
    });

    testWidgets(
        '[removeWhere] function test - predicate finds match - item removed - widget updates',
        (tester) async {
      const String keyOne = 'name';
      const String valueOne = 'Kenya';
      const String keyTwo = 'code';
      const String valueTwo = '254';

      final Map<String, String> countryMap = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      activeController.countryMap.addAll(countryMap);

      await tester.pumpWidget(mapTestView);

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsOneWidget);
      expect(find.text(valueTwo), findsOneWidget);

      activeController.countryMap
          .removeWhere((key, value) => value == valueTwo);

      await tester.pumpAndSettle();

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsNothing);
      expect(find.text(valueTwo), findsNothing);
    });

    testWidgets('[clear] function test - all items will be removed - widget updates',
        (tester) async {
      const String keyOne = 'name';
      const String valueOne = 'Kenya';
      const String keyTwo = 'code';
      const String valueTwo = '254';

      final Map<String, String> countryMap = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      activeController.countryMap.addAll(countryMap);

      await tester.pumpWidget(mapTestView);

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsOneWidget);
      expect(find.text(valueTwo), findsOneWidget);

      activeController.countryMap.clear();

      await tester.pumpAndSettle();

      expect(find.text(keyOne), findsNothing);
      expect(find.text(valueOne), findsNothing);
      expect(find.text(keyTwo), findsNothing);
      expect(find.text(valueTwo), findsNothing);
    });

    test('[containsKey] function test - has matching key - returns true', () {
      const String key = 'name';
      const String value = 'Kenya';

      activeController.countryMap.add(key, value);

      final result = activeController.countryMap.containsKey(key);

      expect(result, isTrue);
    });

    test('[containsKey] function test - has no matching key - returns false', () {
      const String key = 'name';
      const String value = 'Kenya';
      const String missingKey = 'code';

      activeController.countryMap.add(key, value);

      final result = activeController.countryMap.containsKey(missingKey);

      expect(result, isFalse);
    });

    test('[containsValue] function test - has matching value - returns true', () {
      const String key = 'name';
      const String value = 'Kenya';

      activeController.countryMap.add(key, value);

      final result = activeController.countryMap.containsValue(value);

      expect(result, isTrue);
    });

    test('[containsValue] function test - has no matching value - returns false', () {
      const String key = 'name';
      const String value = 'Kenya';
      const String missingValue = '254';

      activeController.countryMap.add(key, value);

      final result = activeController.countryMap.containsValue(missingValue);

      expect(result, isFalse);
    });

    test('[] operator test - has matching key - returns value', () {
      const String key = 'name';
      const String value = 'Kenya';

      activeController.countryMap.add(key, value);

      final result = activeController.countryMap[key];

      expect(result, equals(value));
    });

    test('[] operator test - has no matching key - returns value', () {
      const String key = 'name';
      const String value = 'Kenya';
      const String missingKey = 'code';

      activeController.countryMap.add(key, value);

      final result = activeController.countryMap[missingKey];

      expect(result, isNull);
    });
    test(
        '[reset] function test - starting map is empty - add item - should be empty after reset',
        () {
      final countryMap = ActiveMap<String, String>.empty();
      countryMap.setActiveController(activeController);
      countryMap.add('name', 'Kenya');

      expect(countryMap.isNotEmpty, isTrue);

      countryMap.reset();

      expect(countryMap.isEmpty, isTrue);
    });

    test(
        '[reset] - starting map has countryMap - add item - only original countryMap after reset',
        () {
      const String key = 'name';
      const String value = 'Kenya';
      const String keyTwo = 'code';
      const String valueTwo = '254';

      final countryMap = ActiveMap<String, String>({key: value});
      countryMap.setActiveController(activeController);

      expect(countryMap.containsKey(key), isTrue);
      expect(countryMap.containsValue(value), isTrue);

      countryMap.add(keyTwo, valueTwo);

      expect(countryMap.containsKey(keyTwo), isTrue);
      expect(countryMap.containsValue(valueTwo), isTrue);

      countryMap.reset();

      expect(countryMap.containsKey(keyTwo), isFalse);
      expect(countryMap.containsValue(valueTwo), isFalse);
      expect(countryMap.containsKey(key), isTrue);
      expect(countryMap.containsValue(value), isTrue);
    });
  });
}

import 'package:activity/activity.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:matcher/src/equals_matcher.dart' as match;

void main() {
  group('ActiveStateChanged Extension Tests', () {
    test(
        '[contains] function test - contains event matching property name - returns true',
        () {
      const String typeName = 'loading';

      final events = <ActiveStateChanged<String>>[];

      ActiveStateChanged<String> activeStateChanged =
      ActiveStateChanged('John Doe', null, typeName: typeName);

      events.add(activeStateChanged);
      final foundEvent = (events.first.typeName == typeName) ? true : false;

      expect(foundEvent, isTrue);
    });

    test(
        '[contains] function test - does not contain event matching property name - returns false',
        () {
      const String typeName = 'loading';
      final List events = <ActiveStateChanged<String>>[];

      final foundEvent = events.contains(typeName);

      expect(foundEvent, isFalse);
    });

    test(
        '[firstForPropertyName] function test - contains event matching property name - returns event',
        () {
      const String typeName = 'loading';
      final event = ActiveStateChanged('John Doe', null, typeName: typeName);
      final events = [event];
      final result = events.firstForPropertyName(typeName);

      expect(result, isNotNull);
      expect(result, match.equals(event));
    });

    test(
        '[firstForPropertyName] function test - does not contain event matching property name - returns null',
        () {
      const String typeName = 'loading';
      final events = <ActiveStateChanged<String>>[];
      final result = events.firstForPropertyName(typeName);

      expect(result, isNull);
    });

    test(
        '[newValueFor] function test - contains event matching property name - returns nextValue',
        () {
      const String nextValue = 'Bob';
      const String typeName = 'loading';
      final events = [ActiveStateChanged(nextValue, null, typeName: typeName)];

      final result = events.newValueFor(typeName);
      expect(result, match.equals(nextValue));
    });

    test(
        '[newValueFor] function test - does not contain event matching property name - returns nextValue',
        () {
      const String typeName = 'loading';
      final events = <ActiveStateChanged<String>>[];

      final result = events.newValueFor(typeName);
      expect(result, isNull);
    });

    test(
        '[oldValueFor] function test - contains event matching property name - returns previousValue',
        () {
      const String previousValue = 'Bob';
      const String typeName = 'loading';
      final events = [
        ActiveStateChanged(null, previousValue, typeName: typeName)
      ];

      final result = events.oldValueFor(typeName);
      expect(result, match.equals(previousValue));
    });

    test(
        '[oldValueFor] function test - does not contain event matching property name - returns previousValue',
        () {
      const String typeName = 'loading';
      final events = <ActiveStateChanged<String>>[];

      final result = events.oldValueFor(typeName);
      expect(result, isNull);
    });
  });
}

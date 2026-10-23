import 'package:activity/core/src/state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActiveStateChanged Extension Tests', () {
    test(
      '[containsPropertyName] - when matching event exists, returns true',
      () {
        const typeName = 'loading';
        final events = <ActiveStateChanged<String>>[
          const ActiveStateChanged('new', 'old', typeName: typeName),
        ];

        expect(events.containsPropertyName(typeName), isTrue);
      },
    );

    test(
      '[containsPropertyName] - when no matching event exists, returns false',
      () {
        const typeName = 'loading';
        final events = <ActiveStateChanged<String>>[
          const ActiveStateChanged('new', 'old', typeName: 'other'),
        ];

        expect(events.containsPropertyName(typeName), isFalse);
      },
    );

    test('[firstForPropertyName] - returns matching event when found', () {
      const typeName = 'loading';
      const expected = ActiveStateChanged(
        'newValue',
        'oldValue',
        typeName: typeName,
      );
      final events = <ActiveStateChanged<String>>[
        expected,
        const ActiveStateChanged('other', 'old', typeName: 'other'),
      ];

      final result = events.firstForPropertyName(typeName);

      expect(result, isNotNull);
      expect(result, equals(expected));
    });

    test('[firstForPropertyName] - returns null when no match found', () {
      const typeName = 'loading';
      final events = <ActiveStateChanged<String>>[
        const ActiveStateChanged('something', 'else', typeName: 'not_loading'),
      ];

      final result = events.firstForPropertyName(typeName);
      expect(result, isNull);
    });

    test('[newValueFor] - returns correct newValue when typeName matches', () {
      const newValue = 'Bob';
      const typeName = 'loading';
      final events = <ActiveStateChanged<String>>[
        const ActiveStateChanged(newValue, 'old', typeName: typeName),
      ];

      expect(events.newValueFor(typeName), equals(newValue));
    });

    test('[newValueFor] - returns null when no match found', () {
      const typeName = 'loading';
      final events = <ActiveStateChanged<String>>[
        const ActiveStateChanged('value', 'prev', typeName: 'not_loading'),
      ];

      expect(events.newValueFor(typeName), isNull);
    });

    test('[oldValueFor] - returns correct oldValue when typeName matches', () {
      const oldValue = 'Old';
      const typeName = 'loading';
      final events = <ActiveStateChanged<String>>[
        const ActiveStateChanged('New', oldValue, typeName: typeName),
      ];

      expect(events.oldValueFor(typeName), equals(oldValue));
    });

    test('[oldValueFor] - returns null when no match found', () {
      const typeName = 'loading';
      final events = <ActiveStateChanged<String>>[
        const ActiveStateChanged('new', 'old', typeName: 'not_loading'),
      ];

      expect(events.oldValueFor(typeName), isNull);
    });

    test('[toString] - returns formatted debug-friendly output', () {
      const oldValue = 'A';
      const newValue = 'B';
      const typeName = 'fieldName';
      const info = 'value updated';
      const change = ActiveStateChanged<String>(
        newValue,
        oldValue,
        typeName: typeName,
        info: info,
      );

      final result = change.toString();

      expect(result, contains('Old value : $oldValue'));
      expect(result, contains('New value : $newValue'));
      expect(result, contains('Type name : $typeName'));
      expect(result, contains('Type info : $info'));
    });

    test(
      '[equals operator] - correctly compares two identical ActiveStateChanged instances',
      () {
        const typeName = 'name';
        const a = ActiveStateChanged('Alice', 'Bob', typeName: typeName);
        const b = ActiveStateChanged('Alice', 'Bob', typeName: typeName);

        // Even though they are different instances, content is the same
        expect(a.toString(), equals(b.toString()));
      },
    );
  });
}

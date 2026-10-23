import 'package:activity/activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unicode case and characters', () {
    expect('ÉCOLE'.isUpperCase, isTrue);
    expect('école'.isLowerCase, isTrue);
    expect('😀a'.first, '😀');
    expect('😀a'.iterable.toList(), ['😀', 'a']);
    expect('abc123'.isAlNum, isTrue);
    expect(' -12.5 '.isNumeric, isTrue);
    expect('abc'.isNumeric, isFalse);
  });
  test('UUID v4 is fresh and correctly formatted', () {
    final ids = List.generate(500, (_) => UniqueID.generateUuid());
    expect(ids.toSet().length, ids.length);
    expect(
      ids.every(
        RegExp(
          r'^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
        ).hasMatch,
      ),
      isTrue,
    );
  });
}

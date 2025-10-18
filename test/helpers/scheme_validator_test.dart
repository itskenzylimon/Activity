import 'package:activity/core/helpers/schema_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SchemaValidator', () {
    test('validates required and type rules', () {
      final validator = SchemaValidator({
        'name': {'required': true, 'type': String},
      });

      final result = validator.validate({'name': 'John'});
      expect(result.valid, isTrue);
      expect(result.errors, isEmpty);

      final result2 = validator.validate({});
      expect(result2.valid, isFalse);
      expect(result2.errors.containsKey('name'), isTrue);
    });

    test('validates min/max for numbers', () {
      final validator = SchemaValidator({
        'age': {'type': int, 'min': 10, 'max': 20},
      });

      final low = validator.validate({'age': 5});
      expect(low.valid, isFalse);
      expect(low.errors['age'], contains('below'));

      final high = validator.validate({'age': 25});
      expect(high.valid, isFalse);
      expect(high.errors['age'], contains('exceeds'));

      final ok = validator.validate({'age': 15});
      expect(ok.valid, isTrue);
    });

    test('validates string length', () {
      final validator = SchemaValidator({
        'username': {'type': String, 'minLength': 3, 'maxLength': 5},
      });

      final tooShort = validator.validate({'username': 'ab'});
      expect(tooShort.valid, isFalse);

      final tooLong = validator.validate({'username': 'abcdef'});
      expect(tooLong.valid, isFalse);

      final ok = validator.validate({'username': 'abcd'});
      expect(ok.valid, isTrue);
    });

    test('validates pattern rule', () {
      final validator = SchemaValidator({
        'code': {'type': String, 'pattern': r'^ABC\\d+\$'},
      });

      final bad = validator.validate({'code': 'XYZ123'});
      expect(bad.valid, isFalse);
      expect(bad.errors['code'], contains('pattern'));

      final good = validator.validate({'code': 'ABC123'});
      expect(good.valid, isTrue);
    });

    test('validates email and phone format', () {
      final validator = SchemaValidator({
        'email': {'email': true},
        'phone': {'phone': true},
      });

      final invalid = validator.validate({'email': 'abc', 'phone': '12345'});
      expect(invalid.valid, isFalse);
      expect(invalid.errors.length, greaterThan(0));

      final valid = validator.validate({
        'email': 'john@example.com',
        'phone': '+1234567890',
      });
      expect(valid.valid, isTrue);
    });

    test('validates equalsTo rule', () {
      final validator = SchemaValidator({
        'password': {'type': String},
        'confirm': {'type': String, 'equalsTo': 'password'},
      });

      final bad = validator.validate({'password': 'abc', 'confirm': 'xyz'});
      expect(bad.valid, isFalse);
      expect(bad.errors['confirm'], contains('equal'));

      final good = validator.validate({'password': 'abc', 'confirm': 'abc'});
      expect(good.valid, isTrue);
    });

    test('validates date rules', () {
      final validator = SchemaValidator({
        'start': {
          'date': true,
          'before': '2030-01-01',
          'after': '2020-01-01',
        },
      });

      final badFormat = validator.validate({'start': 'not-a-date'});
      expect(badFormat.valid, isFalse);

      final tooEarly = validator.validate({'start': '2010-01-01'});
      expect(tooEarly.valid, isFalse);

      final tooLate = validator.validate({'start': '2040-01-01'});
      expect(tooLate.valid, isFalse);

      final ok = validator.validate({'start': '2025-01-01'});
      expect(ok.valid, isTrue);
    });

    test('validates list minItems and maxItems', () {
      final validator = SchemaValidator({
        'tags': {'type': List, 'minItems': 1, 'maxItems': 3},
      });

      final empty = validator.validate({'tags': []});
      expect(empty.valid, isFalse);

      final tooMany = validator.validate({'tags': [1, 2, 3, 4]});
      expect(tooMany.valid, isFalse);

      final ok = validator.validate({'tags': [1, 2]});
      expect(ok.valid, isTrue);
    });

    test('validates includes rule', () {
      final validator = SchemaValidator({
        'role': {'in': ['admin', 'user']},
      });

      final bad = validator.validate({'role': 'guest'});
      expect(bad.valid, isFalse);

      final ok = validator.validate({'role': 'admin'});
      expect(ok.valid, isTrue);
    });

    test('validates custom rule', () {
      final validator = SchemaValidator({
        'username': {
          'type': String,
          'custom': (value, data) =>
          value == 'admin' ? 'username is reserved' : null
        },
      });

      final bad = validator.validate({'username': 'admin'});
      expect(bad.valid, isFalse);
      expect(bad.errors['username'], contains('reserved'));

      final ok = validator.validate({'username': 'user123'});
      expect(ok.valid, isTrue);
    });

    test('applies custom error messages', () {
      final validator = SchemaValidator(
        {
          'email': {'email': true, 'required': true},
        },
        customErrors: {
          'email.required': 'Email missing!',
          'email.email': 'Email invalid!',
        },
      );

      final bad = validator.validate({'email': 'invalid'});
      expect(bad.errors['email'], equals('Email invalid!'));

      final missing = validator.validate({});
      expect(missing.errors['email'], equals('Email missing!'));
    });

    test('handles nested requiredIf and requiredWhen rules', () {
      final validator = SchemaValidator({
        'phone': {
          'type': String,
          'requiredIf': {'country': 'US'},
          'requiredWhen': (data) => data['needsPhone'] == true,
        },
      });

      final notRequired = validator.validate({'country': 'UK'});
      expect(notRequired.valid, isTrue);

      final requiredByIf = validator.validate({'country': 'US'});
      expect(requiredByIf.valid, isFalse);

      final requiredByWhen = validator.validate({'needsPhone': true});
      expect(requiredByWhen.valid, isFalse);
    });

    test('SchemaResponse toString shows readable output', () {
      final response = SchemaResponse(
        valid: false,
        data: {'x': 1},
        schema: {},
        errors: {'x': 'bad'},
      );
      expect(response.toString(), contains('Failed'));
      expect(response.toString(), contains('bad'));
    });
  });
}

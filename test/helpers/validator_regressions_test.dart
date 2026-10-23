import 'package:activity/activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('URL, strict dates, nullable callbacks and unknown fields', () {
    final validator = SchemaValidator({
      'url': {'url': true},
      'date': {'date': true},
      'name': {
        'custom':
            (dynamic value, Map<String, dynamic> data) =>
                value == 'admin' ? 'Reserved' : null,
      },
    }, allowUnknownKeys: false);
    final good = validator.validate({
      'url': 'https://example.com',
      'date': '2024-02-29',
      'name': 'ada',
      'extra': 1,
    });
    expect(good.valid, isTrue);
    expect(good.schema.containsKey('extra'), isFalse);
    expect(() => good.schema.clear(), throwsUnsupportedError);
    final bad = validator.validate({
      'url': '/relative',
      'date': '2025-02-29',
      'name': 'admin',
    });
    expect(bad.errors.keys, containsAll(['url', 'date', 'name']));
  });
  test(
    'type predicates allow subtype checks and unsupported rules fail explicitly',
    () {
      expect(
        SchemaValidator({
          'n': {'type': (dynamic v) => v is num},
        }).validate({'n': 1.5}).valid,
        isTrue,
      );
      expect(
        () => SchemaValidator({
          'n': {'type': 5},
        }).validate({'n': 1}),
        throwsArgumentError,
      );
    },
  );
  for (final address in [
    '::',
    '::1',
    '2001:db8::1',
    '1:2:3:4:5:6:7:8',
    '::ffff:192.0.2.1',
  ]) {
    test(
      'IPv6 accepts $address',
      () => expect(
        SchemaValidator({
          'ip': {'ipv6': true},
        }).validate({'ip': address}).valid,
        isTrue,
      ),
    );
  }
  for (final address in [
    '1:2:3',
    '1::2::3',
    '1:2:3:4:5:6:7:8:9',
    '::::',
    ':1:2:3:4:5:6:7',
    '::ffff:999.0.0.1',
  ]) {
    test(
      'IPv6 rejects $address',
      () => expect(
        SchemaValidator({
          'ip': {'ipv6': true},
        }).validate({'ip': address}).valid,
        isFalse,
      ),
    );
  }
}

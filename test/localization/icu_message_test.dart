import 'package:activity/activity.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

String format(String pattern, num count, {String locale = 'en'}) =>
    IcuMessage(pattern).format(locale: locale, parameters: {'count': count});

void main() {
  test('cardinal categories follow locale rules, not English number cases', () {
    const pattern =
        '{count, plural, one{one} few{few} many{many} other{other}}';
    expect(format(pattern, 1), 'one');
    expect(format(pattern, 2), 'other');
    expect(format(pattern, 0, locale: 'fr'), 'one');
    expect(format(pattern, 2, locale: 'ru'), 'few');
    expect(format(pattern, 5, locale: 'ru'), 'many');
    expect(format(pattern, 21, locale: 'ru'), 'one');
    expect(format(pattern, 1.2, locale: 'ru'), 'other');
    expect(format(pattern, -2, locale: 'ru'), 'few');
    expect(
      format(
        '{count, plural, zero{zero} one{one} two{two} few{few} many{many} other{other}}',
        0,
        locale: 'ar',
      ),
      'zero',
    );
    expect(
      format('{count, plural, two{two} other{other}}', 2, locale: 'ar'),
      'two',
    );
  });
  test(
    'exact branches precede categories, offsets affect category and pound only',
    () {
      const pattern =
          '{count, plural, offset:1 =0{Nobody} =1{Just you} one{You and # guest} other{You and # guests}}';
      expect(format(pattern, 0), 'Nobody');
      expect(format(pattern, 1), 'Just you');
      expect(format(pattern, 2), 'You and 1 guest');
      expect(format(pattern, 3), 'You and 2 guests');
      expect(format('{count, plural, =1.5{exact} other{#}}', 1.5), 'exact');
    },
  );
  test('nested select and plurals retain the correct pound scope', () {
    const pattern =
        '{gender, select, female{{count, plural, one{She has # task} other{She has # tasks}}} other{{count, plural, other{They have # tasks}}}}';
    expect(
      IcuMessage(
        pattern,
      ).format(locale: 'en', parameters: {'gender': 'female', 'count': 2}),
      'She has 2 tasks',
    );
    expect(
      IcuMessage(
        pattern,
      ).format(locale: 'en', parameters: {'gender': 'unknown', 'count': 1}),
      'They have 1 tasks',
    );
    expect(
      IcuMessage(
        '{outer, plural, other{# {inner, plural, other{#}} #}}',
      ).format(locale: 'en', parameters: {'outer': 2, 'inner': 3}),
      '2 3 2',
    );
    expect(
      IcuMessage(
        '{count, plural, other{{gender, select, other{#}}}}',
      ).format(locale: 'en', parameters: {'count': 3, 'gender': 'x'}),
      '3',
    );
  });
  test(
    'quoting escapes braces and pound while ordinary apostrophes remain literal',
    () {
      expect(
        format("Don't use '{count}' and ''quotes''", 2),
        "Don't use {count} and 'quotes'",
      );
      expect(format("{count, plural, other{'#' '#' #}}", 2), '# # 2');
      expect(
        IcuMessage(
          'Hello {name}; #',
        ).format(locale: 'en', parameters: {'name': '{count}'}),
        'Hello {count}; #',
      );
      expect(IcuMessage('{missing}').format(locale: 'en'), '{missing}');
    },
  );
  test('pound rendering uses locale number formatting', () {
    expect(
      format('{count, plural, other{#}}', 1234.5, locale: 'de'),
      '1.234,5',
    );
  });
  for (final bad in [
    '{count, plural, one{One}}',
    '{count, plural, other{a} other{b}}',
    '{count, plural, =1{a} =1.0{b} other{c}}',
    '{count, plural, nope{bad} other{ok}}',
    '{count, plural, offset:-1 other{bad}}',
    '{count, plural, other{bad}',
    '{count, selectordinal, other{bad}}',
    '{date, date, short}',
    'bad}',
  ]) {
    test(
      'invalid or unsupported pattern is rejected: $bad',
      () => expect(() => IcuMessage(bad), throwsFormatException),
    );
  }
  test(
    'complex arguments require correctly typed data and nesting is bounded',
    () {
      final message = IcuMessage('{count, plural, other{#}}');
      expect(() => message.format(locale: 'en'), throwsArgumentError);
      expect(
        () => message.format(locale: 'en', parameters: {'count': '2'}),
        throwsArgumentError,
      );
      expect(
        () => message.format(locale: 'en', parameters: {'count': double.nan}),
        throwsArgumentError,
      );
      final deep =
          '${List.filled(66, '{n, select, other{').join()}x${List.filled(66, '}}').join()}';
      expect(() => IcuMessage(deep), throwsFormatException);
    },
  );
  test(
    'fallback messages use the language of the fallback translation',
    () async {
      final l = ActiveLocalization(
        const Locale('ru'),
        fallbackLocale: const Locale('en'),
        loader:
            (locale) async =>
                locale.languageCode == 'en'
                    ? {'tasks': '{count, plural, one{one task} other{# tasks}}'}
                    : {},
      );
      await l.load();
      expect(l.translate('tasks', parameters: {'count': 21}), '21 tasks');
    },
  );
}

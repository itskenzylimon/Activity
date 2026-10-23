import 'dart:convert';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class Bundle extends CachingAssetBundle {
  final Map<String, String> assets;
  Bundle(this.assets);
  @override
  Future<ByteData> load(String key) async {
    final source = assets[key];
    if (source == null) throw FlutterError('Missing asset $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }
}

void main() {
  test(
    'custom loaders, locale tags, fallback keys and literal interpolation',
    () async {
      final delegate = ActiveLocalizationDelegate(
        supportedLocales: [const Locale('sw'), const Locale('en')],
        fallbackLocale: const Locale('en'),
        loader:
            (locale) async =>
                locale.languageCode == 'sw'
                    ? {'welcome': 'Habari {name}'}
                    : {'welcome': 'Hello {name}', 'save': 'Save'},
      );
      final l = await delegate.load(const Locale('sw'));
      expect(
        l.translate('welcome', parameters: {'name': 'A {save}'}),
        'Habari A {save}',
      );
      expect(l.translate('save'), 'Save');
      expect(l.translate('missing'), 'missing');
      expect(l.translate('missing', fallback: 'Other'), 'Other');
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    },
  );
  test('asset locale tags and missing primary asset fallback', () async {
    final l = ActiveLocalization(
      const Locale('en', 'GB'),
      fallbackLocale: const Locale('en'),
      bundle: Bundle({'assets/language/en.json': '{"save":"Save"}'}),
    );
    await l.load();
    expect(l.translate('save'), 'Save');
  });
  test('malformed translation data reports its error', () async {
    final l = ActiveLocalization(
      const Locale('en'),
      bundle: Bundle({'assets/language/en.json': '{"n":4}'}),
    );
    await expectLater(l.load(), throwsFormatException);
  });
  testWidgets('context extension gracefully handles absent delegate', (
    tester,
  ) async {
    await tester.pumpWidget(
      Builder(
        builder:
            (context) =>
                Text(context.tr('save'), textDirection: TextDirection.ltr),
      ),
    );
    expect(find.text('save'), findsOneWidget);
  });
}

part of 'localizations.dart';

typedef TranslationLoader = Future<Map<String, String>> Function(Locale locale);

class ActiveLocalization {
  final Locale locale;
  final TranslationLoader? loader;
  final AssetBundle? bundle;
  final String assetPath;
  final Locale? fallbackLocale;
  Map<String, String> _localizedValues = const {};
  Map<String, String> _fallbackValues = const {};
  final Map<String, IcuMessage> _messages = {};

  ActiveLocalization(
    this.locale, {
    this.loader,
    this.bundle,
    this.assetPath = 'assets/language',
    this.fallbackLocale,
  });

  static ActiveLocalization? of(BuildContext context) =>
      Localizations.of<ActiveLocalization>(context, ActiveLocalization);

  Future<Map<String, String>> _read(Locale target) async {
    if (loader != null) return Map.unmodifiable(await loader!(target));
    final raw = json.decode(
      await (bundle ?? rootBundle).loadString(
        '$assetPath/${target.toLanguageTag()}.json',
      ),
    );
    if (raw is! Map<String, dynamic> ||
        raw.values.any((value) => value is! String)) {
      throw const FormatException(
        'Translations must be a JSON object with string values',
      );
    }
    return Map<String, String>.unmodifiable(raw.cast<String, String>());
  }

  Future<void> load() async {
    final fallback = fallbackLocale;
    if (fallback != null && fallback != locale) {
      _fallbackValues = await _read(fallback);
    }
    try {
      _localizedValues = await _read(locale);
    } on FlutterError {
      if (fallback == null || fallback == locale) rethrow;
      _localizedValues = const {};
    }
  }

  String? getTranslateValue(String key) =>
      _localizedValues[key] ?? _fallbackValues[key];

  /// Format ICU placeholders, plurals and select. Missing keys use fallback/key.
  String translate(
    String key, {
    Map<String, Object?> parameters = const {},
    String? fallback,
  }) {
    final template = getTranslateValue(key) ?? fallback ?? key;
    final messageLocale =
        !_localizedValues.containsKey(key) && _fallbackValues.containsKey(key)
            ? fallbackLocale!
            : locale;
    return _messages
        .putIfAbsent(template, () => IcuMessage(template))
        .format(
          locale: messageLocale.toLanguageTag().replaceAll('-', '_'),
          parameters: parameters,
        );
  }

  /// Legacy en/sw delegate. Prefer an application-owned delegate below.
  static const LocalizationsDelegate<ActiveLocalization> delegate =
      _ActiveLocalizationDelegate();
}

/// Application-owned locale loading that composes with existing Flutter delegates.
///
/// In MaterialApp add this delegate alongside Flutter SDK delegates; switch locale using app-owned state. The gallery includes asset catalogs, context.tr, interpolation, ICU and RTL. A custom loader owns resource failures and retries.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#localization) · browser route `/#/localization`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Load interpolation through an injected catalog
///
/// <!-- activity-snippet: class-activelocalizationdelegate-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
/// import 'package:flutter/widgets.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final delegate = ActiveLocalizationDelegate(
///     supportedLocales: [const Locale('en')],
///     loader: (_) async => {'hello': 'Hello {name}'},
///   );
///   final messages = await delegate.load(const Locale('en'));
///   assert(
///     messages.translate('hello', parameters: {'name': 'Ada'}) == 'Hello Ada',
///   );
/// }
/// ```
///
/// ### Use fallback messages
///
/// <!-- activity-snippet: class-activelocalizationdelegate-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
/// import 'package:flutter/widgets.dart';
///
/// Future<void> main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final delegate = ActiveLocalizationDelegate(
///     supportedLocales: [const Locale('en'), const Locale('sw')],
///     fallbackLocale: const Locale('en'),
///     loader:
///         (locale) async => locale.languageCode == 'en' ? {'save': 'Save'} : {},
///   );
///   final messages = await delegate.load(const Locale('sw'));
///   assert(messages.translate('save') == 'Save');
///   assert(
///     messages.translate('missing', fallback: 'Unavailable') == 'Unavailable',
///   );
/// }
/// ```
class ActiveLocalizationDelegate
    extends LocalizationsDelegate<ActiveLocalization> {
  final List<Locale> supportedLocales;
  final Locale? fallbackLocale;
  final TranslationLoader? loader;
  final AssetBundle? bundle;
  final String assetPath;
  ActiveLocalizationDelegate({
    required Iterable<Locale> supportedLocales,
    this.fallbackLocale,
    this.loader,
    this.bundle,
    this.assetPath = 'assets/language',
  }) : supportedLocales = List.unmodifiable(supportedLocales) {
    if (this.supportedLocales.isEmpty) {
      throw ArgumentError('At least one locale is required');
    }
  }
  @override
  bool isSupported(Locale locale) => supportedLocales.contains(locale);
  @override
  Future<ActiveLocalization> load(Locale locale) async {
    final localization = ActiveLocalization(
      locale,
      loader: loader,
      bundle: bundle,
      assetPath: assetPath,
      fallbackLocale: fallbackLocale,
    );
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(covariant ActiveLocalizationDelegate old) =>
      assetPath != old.assetPath ||
      loader != old.loader ||
      bundle != old.bundle ||
      fallbackLocale != old.fallbackLocale ||
      !listEquals(supportedLocales, old.supportedLocales);
}

class _ActiveLocalizationDelegate
    extends LocalizationsDelegate<ActiveLocalization> {
  const _ActiveLocalizationDelegate();
  @override
  bool isSupported(Locale locale) =>
      supportedLanguages.contains(locale.languageCode);
  @override
  Future<ActiveLocalization> load(Locale locale) async {
    final localization = ActiveLocalization(Locale(locale.languageCode));
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_ActiveLocalizationDelegate old) => false;
}

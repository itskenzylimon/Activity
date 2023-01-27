part of 'localizations.dart';



class ActiveLocalization {
  final Locale locale;

  ActiveLocalization(this.locale);

  static ActiveLocalization? of(BuildContext context) {
    return Localizations.of<ActiveLocalization>(context, ActiveLocalization);
  }

  late Map<String, String> _localizedValues;

  Future load() async {
    String jsonStringValues = await rootBundle
        .loadString('assets/language/${locale.languageCode}.json');

    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);

    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String? getTranslateValue(String key) {
    return _localizedValues[key];
  }

  static const LocalizationsDelegate<ActiveLocalization> delegate =
      _ActiveLocalizationDelegate();
}

class _ActiveLocalizationDelegate
    extends LocalizationsDelegate<ActiveLocalization> {
  const _ActiveLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return supportedLanguages.contains(locale.languageCode);
  }

  @override
  Future<ActiveLocalization> load(Locale locale) async {
    ActiveLocalization localization = ActiveLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_ActiveLocalizationDelegate old) {
    return false;
  }
}

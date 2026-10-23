//Imports
import 'dart:convert';
import 'icu_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/services.dart';

//Part
part 'active_localizations.dart';

@Deprecated('Configure ActiveLocalizationDelegate.supportedLocales instead.')
List<String> supportedLanguages = ['en', 'sw'];

String? getTranslated(BuildContext context, String key) {
  return ActiveLocalization.of(context)?.getTranslateValue(key);
}

extension ActivityTranslations on BuildContext {
  String tr(
    String key, {
    Map<String, Object?> parameters = const {},
    String? fallback,
  }) =>
      ActiveLocalization.of(
        this,
      )?.translate(key, parameters: parameters, fallback: fallback) ??
      fallback ??
      key;
}

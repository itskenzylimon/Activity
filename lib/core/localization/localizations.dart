//Imports
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Part
part 'active_localizations.dart';

List supportedLanguages = ['en', 'sw'];

String? getTranslated(BuildContext context, String key) {
  return ActiveLocalization.of(context)!.getTranslateValue(key);
}
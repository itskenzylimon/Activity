import 'package:flutter/material.dart';

/// This is a custom widget that can be used to create any type of widget
class CustomWidget extends StatelessWidget {
  ValueChanged<Map<String, dynamic>>? onElementCallback;
  ValueChanged<Map<String, dynamic>>? onFormCallback;
  String elementName;
  Map<String, Map<String, dynamic>> valueFormResults;
  Map<String, dynamic> customTheme;
  Widget widgetData;

  CustomWidget({
    super.key,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme,
    required this.widgetData,
    this.onElementCallback,
    this.onFormCallback,
  });

  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};

  @override
  Widget build(BuildContext context) {
    callbackElement = valueFormResults[elementName]!;
    return widgetData;
  }
}

class CustomWidgetModel {
  /// The callback function that is called when you want to change the value
  /// of the element changes
  /// The callback function that is called when the value of the element changes
  /// value pairs of the form element values
  /// if no the key is not found, the value will not be updated
  /// e.g { 'value': 'I love activity ' }
  ValueChanged<Map<String, dynamic>> onElementCallback;
  /// The callback function that is called when you want to change the value
  /// of the form changes
  /// The callback function that is called when the value of the form changes
  /// Key value pairs of the form element values
  /// if no the key is not found, the value will not be updated
  /// e.g { 'elementName': { 'value': 'I love activity ' } }
  ValueChanged<Map<String, dynamic>>? onFormCallback;
  /// The name of the element['name'] that is used to identify the element
  String elementName;
  /// The values of the form
  Map<String, Map<String, dynamic>> valueFormResults;
  /// The custom theme
  Map<String, dynamic>? customTheme;

  /// The custom widget
  Widget customWidget;

  /// Model for the CustomWidget
  CustomWidgetModel({
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customWidget,
    this.customTheme,
    this.onFormCallback,
  });

  Map<String, dynamic> toMap() => {
    'onElementCallback': onElementCallback,
    'elementName': elementName,
    'valueFormResults': valueFormResults,
    'customWidget': customWidget,
    'customTheme': customTheme,
    'onFormCallback': onFormCallback,
  };

  Function makeOnElementCallback(){
    return (Map<String, dynamic> value) {
      // print('{{{{object}}}}');
      onElementCallback(value);
    };
  }

}
import 'package:flutter/material.dart';

class SampleWidget extends StatelessWidget {
   ValueChanged<Map<String, dynamic>>? onElementCallback;
   String elementName;

  /// Key value pairs of the form element values
  /// if no the key is not found, the value will not be updated
  /// e.g { 'elementName': { 'value': 'I love activity ' } }
   Map<String, Map<String, dynamic>> valueFormResults;
   Map<String, dynamic> customTheme;

  SampleWidget({
    super.key,
     this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme
  });

  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};

  @override
  Widget build(BuildContext context) {

    // Call the callback function and pass the callback value
    // onElementCallback(callbackElement);

    // Return an empty Container widget (or any other widget)
    return Container();
  }
}
import 'package:flutter/material.dart';

import '../../core/forms/form_controller.dart';

class AgeCalculatorWidget extends StatelessWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  final Map<String, Map<String, dynamic>> valueFormResults;
  final Map<String, dynamic> customTheme;

  AgeCalculatorWidget({
    super.key,
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme
  });

  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};
  TextEditingController agecalcEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    String labelText = valueFormResults[elementName]!['title'];

    // Return an empty Container widget (or any other widget)
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      const SizedBox(
        height: 20,
      ),
      Text(
        labelText,
        style: const TextStyle(color: Colors.black, fontSize: 18),
      ),
      const SizedBox(
        height: 10,
      ),
      TextFormField(
        keyboardType: FormController().
        checkInputType(valueFormResults[elementName]!),
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: valueFormResults[elementName]!['placeholder'] ?? '',
        ),
        validator: (value) {},
        onChanged: (value) {

          callbackElement['value'] = value;
          onElementCallback(callbackElement);

        },
      ),
    ]);
  }
}
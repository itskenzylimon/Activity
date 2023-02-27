import 'package:flutter/material.dart';

class RadioGroupWidget extends StatelessWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  final Map<String, Map<String, dynamic>> valueFormResults;

  RadioGroupWidget({
    super.key,
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults
  });

  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};

  @override
  Widget build(BuildContext context) {

    // Call the callback function and pass the callback value
    // onElementCallback(callbackElement);
    List choices = [];

    callbackElement = valueFormResults[elementName]!;

    String selectedChoice = '';
    return Visibility(
      visible: valueFormResults[elementName]!['visible'] ?? true,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          children: choices.map((choice) {
            return RadioListTile(
              title: Text(choice),
              value: choice,
              groupValue: selectedChoice,
              onChanged: (value) {

                callbackElement['value'] = value;
                onElementCallback(callbackElement);

              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
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

    String selectedChoice = '';
    callbackElement = valueFormResults[elementName]!;
    print('??????? CHOICES');
    print(callbackElement['choices']);
    for (var i = 0; i < callbackElement['choices'].length; i++) {
      print(callbackElement['choices'][i]);
      print('??CHOICE TYPE');
      print(callbackElement['choices'][i].runtimeType);
      if (callbackElement['choices'][i].runtimeType == String){
        print(callbackElement['choices'][i]);
        choices.add(callbackElement['choices'][i]);
      } else {
        print('??????? CHOICES OBJECT');
        print(callbackElement['choices']);
        choices.add(callbackElement['choices'][i]['value']);
      }
    }

    if (callbackElement['value'] != '') {
      selectedChoice = callbackElement['value'] ?? '';
    }
    else {
      // callbackElement['value'] = choices[0];

      selectedChoice = callbackElement['value'] ?? '';
    }
    return Visibility(
      visible: true,
      child: Container(
        margin: const EdgeInsets.only(top: 10, bottom: 10, left: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              callbackElement['title'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              callbackElement['isRequired'] ? '(Required)' : '(Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Column(
              children: choices.map((choice) {
                return RadioListTile(
                  title: Text(choice),
                  value: choice,
                  groupValue: selectedChoice,
                  onChanged: (value) {
                    selectedChoice = value;
                    callbackElement['value'] = value;
                    onElementCallback(callbackElement);

                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
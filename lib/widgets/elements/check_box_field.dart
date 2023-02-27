import 'package:flutter/material.dart';

class CheckBoxWidget extends StatelessWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  final Map<String, Map<String, dynamic>> valueFormResults;
  final Map<String, dynamic> customTheme;

  CheckBoxWidget({
    super.key,
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme
  });

  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};

  @override
  Widget build(BuildContext context) {

    callbackElement = valueFormResults[elementName]!;
    String selectedChoice = '';
    // Call the callback function and pass the callback value
    // onElementCallback(callbackElement);

    // Return an empty Container widget (or any other widget)
    return Column(
      children: [
        Wrap(
          children: [
            for (var choice in callbackElement['choices'])
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ChoiceChip(
                  label: Text(choice),
                  selected: selectedChoice == choice ? true : false,
                  onSelected: (bool selected) {},
                ),
              )
          ],
        ),
        Text("${callbackElement['title']}: $selectedChoice")
      ],
    );
  }
}
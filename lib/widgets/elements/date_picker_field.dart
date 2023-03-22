import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

class DatePickerWidget extends StatelessWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  final Map<String, Map<String, dynamic>> valueFormResults;
  final Map<String, dynamic> customTheme;

  DatePickerWidget({
    super.key,
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme
  });

  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};

  final TextEditingController textEditingController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime maxDays = DateTime(1950);

  @override
  Widget build(BuildContext context) {

    callbackElement = valueFormResults[elementName]!;
    if (callbackElement['maxDays'] != null) {
      maxDays.add(Duration(days: callbackElement['maxDays']));
    }
    textEditingController.text = ['', null].contains(callbackElement['value'])
        ? callbackElement['title']
        : callbackElement['value'];
    // Return an empty Container widget (or any other widget)
    return Container(
      margin: const EdgeInsets.only(left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            "${callbackElement['title']}",
          ),
          const SizedBox(
            height: 10,
          ),
          Ink(
              child: TextFormBox(
                onTap: () {
                  selectDate(context);
                },
                readOnly: true,
                placeholder: callbackElement['title'] ?? '',

                controller: textEditingController,
              )
          ),
        ],
      ),
    );
  }

  selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: maxDays,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      textEditingController.text = selectedDate.toString().substring(0,10);
      callbackElement['value'] = selectedDate.toString().substring(0,10);
      onElementCallback(callbackElement);
    }
  }

}
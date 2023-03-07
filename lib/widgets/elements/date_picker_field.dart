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
    return Ink(
        child: Container(
          margin: const EdgeInsets.only(top:8,bottom: 16,right:16,left:16),
          child:   TextField(
            onTap: () {
              selectDate(context);
            },
            readOnly: true,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Colors.grey, width: 0.0),
                  borderRadius: BorderRadius.circular(8)),
              focusedBorder: const OutlineInputBorder(
                  borderRadius:
                  BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.blue,)),
              hintText: callbackElement['title'] ?? '',
            ),
            controller: textEditingController,
          ),
        )
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
      textEditingController.text = selectedDate.toString();
      callbackElement['value'] = selectedDate.toString();
      onElementCallback(callbackElement);
    }
  }

}
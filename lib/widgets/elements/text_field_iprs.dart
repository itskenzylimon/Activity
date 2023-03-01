import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/forms/form_controller.dart';

class TextFieldIPRSWidget extends StatelessWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  final Map<String, Map<String, dynamic>> valueFormResults;
  final Map<String, dynamic> customTheme;

  TextFieldIPRSWidget({
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
    print("?????? IPRS TEXT FIELD");
    print(callbackElement);

    /// label text for the text field is the title with a * if the field is required
    String labelText = callbackElement['label'];

    return Container(
        margin: const EdgeInsets.all(10),
        child: TextFormField(
          controller: valueFormResults[elementName]!['controller'],
          keyboardType: FormController().checkInputType(valueFormResults[elementName]!),
          enabled: valueFormResults[elementName]!['enable'] ?? true,
          maxLines: valueFormResults[elementName]!['type'] == 'comment' ? 5 : 1,
          style: const TextStyle(
            color: Colors.black,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(top: 3, left: 8),
            hintStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xffE0E0E0)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Colors.grey, width: 0.0),
                borderRadius: BorderRadius.circular(8)),
            focusedBorder: const OutlineInputBorder(
                borderRadius:
                BorderRadius.all(Radius.circular(8.0)),
                borderSide: BorderSide(color: Colors.black,)),
            labelText: labelText,
            hintText: callbackElement['placeholder'] ?? '',
          ),
          validator: (value) {

            if (valueFormResults[elementName]!['isRequired'] == null) {
              if (value == null || value.isEmpty) {
                return 'Please enter ${valueFormResults[elementName]!['title']}';
              }
            }
            /// check if value is required
            if (valueFormResults[elementName]!['required'] == true) {
              /// input validator for numbers
              if (valueFormResults[elementName]!['inputType'] == 'number') {
                int intValue = int.parse(value ?? '0');
                //check if max exist
                if (valueFormResults[elementName]!['max'] != null) {
                  if (intValue > valueFormResults[elementName]!['max']) {
                    return '${valueFormResults[elementName]!['max']} is the max ${valueFormResults[elementName]!['title']}';
                  }
                }
                //check if min exist
                if (valueFormResults[elementName]!['min'] != null) {
                  if (valueFormResults[elementName]!['min'] > intValue) {
                    return '${valueFormResults[elementName]!['min']} is the min ${valueFormResults[elementName]!['title']}';
                  }
                }
                //
              }
            }
            if (value == null || value.isEmpty) {
              return (valueFormResults[elementName]!['title'] + ' is required');
            } else if (value.contains('@')) {
              return 'Please don\'t use the @ char.';
            }
            return null;
          },
          onChanged: (value) {

            Timer? debounce;
            if (debounce?.isActive ?? false) debounce?.cancel();
            debounce = Timer(const Duration(milliseconds: 1000),
                    () async {

                  callbackElement['value'] = value;
                  onElementCallback(callbackElement);

                });

          },
        ));

  }

  /// Calculate Age of person based on date of birth
  calculateAge(birthDate) {
    // 9/30/1993
    birthDate = birthDate.split(" ").first;
    birthDate = birthDate.split("/");
    DateTime currentDate = DateTime.now();
    num age = currentDate.year - num.parse(birthDate[2]);
    int month1 = currentDate.month;
    int month2 = int.parse(birthDate[0]);
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = int.parse(birthDate[1]);
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

}
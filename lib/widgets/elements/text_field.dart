import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

import '../../core/forms/form_controller.dart';

class TextFieldWidget extends StatelessWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  final Map<String, Map<String, dynamic>> valueFormResults;
  final Map<String, dynamic> customTheme;

  TextFieldWidget({
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

    /// label text for the text field is the title with a * if the field is required
    String labelText = "${callbackElement['title']} ${((callbackElement['isRequired'] ?? false) ? ' * ' : '')}";

    return Container(
        margin: const EdgeInsets.only(left:10,right:10,top: 30),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(labelText, style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
                    valueFormResults[elementName]!['isRequired'] != true ?  Text('*',style: TextStyle(fontSize: 18,color: Colors.red),) :const SizedBox(),
              ],
            ),
            const SizedBox(
                height: 10,
            ),
            TextFormBox(
              controller: valueFormResults[elementName]!['controller'],
              keyboardType: FormController().checkInputType(valueFormResults[elementName]!),
              enabled: valueFormResults[elementName]!['enable'] ?? true,
              maxLines: valueFormResults[elementName]!['type'] == 'comment' ? 5 : 1,
              style: const TextStyle(
                color: Colors.black,
              ),
              placeholder: callbackElement['placeholder'] ?? '',
              placeholderStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xffE0E0E0)),
              validator: (value) {
                /// check if value is required
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
                    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                    RegExp regExp = new RegExp(pattern);
                    if (value!.length <10) {
                      return 'Please enter valid mobile number';
                    }
                    else if (!regExp.hasMatch(value)) {
                      return 'Please enter valid mobile number';
                    }
                    return null;
                  }
                    //
                  }

                  /// input validator for email
                  if (valueFormResults[elementName]!['inputType'] == 'email') {
                    bool emailValid = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+")
                        .hasMatch(value!);
                    if (!emailValid) {
                      return "Email is invalid";
                    }
                    return null;
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
            ),
          ],
        ));

  }

}
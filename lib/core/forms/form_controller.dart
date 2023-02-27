import 'package:flutter/widgets.dart';

class FormController{


  TextInputType checkInputType(Map element) {
    TextInputType type = TextInputType.text;
    if (element['inputType'] != null) {
      if (element['inputType'] == 'number') {
        type = TextInputType.number;
      }
    } else {
      if (element['type'] != null) {
        if (element['type'] == 'number') {
          type = TextInputType.number;
        }
      }

      /// Find a way to get the form input type
      /// Mobile Number
      if (element.containsValue("^[+][0-9]{12}\$")) {
        type = TextInputType.number;
      }

      /// Email
      if (element.containsValue(" Email") ||
          element.containsValue(" abc@xyz.com")) {
        type = TextInputType.emailAddress;
      }
    }
    return type;
  }

  static String? emailValidator(String? value, ) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Define a regular expression for email validation
    final emailRegex = RegExp('^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');

    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }

    return null;
  }

}
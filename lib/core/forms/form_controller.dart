import 'package:activity/core/types/active_type.dart';
import 'package:flutter/widgets.dart';
import '../src/controller.dart';

class FormController extends ActiveController{



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
      if (element.containsValue("email") ||
          element.containsValue("abc@xyz.com")) {
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
    final emailRegex = RegExp("^[w-.]+@([w-]+.)+[w-]{2,4}\$");

    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }

    return null;
  }

  /// Check if a string is base64
  ///  Use this if you are unsure if a string is a valid base64 format string
  bool base64RegExp(String base64) {
    RegExp regExp =
    RegExp(r'^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$');
    return regExp.hasMatch(base64);
  }

  @override
  // TODO: implement activities
  Iterable<ActiveType> get activities => [];
}
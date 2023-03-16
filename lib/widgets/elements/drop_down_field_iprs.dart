import 'dart:async';
import 'dart:convert';
import 'package:activity/core/networks/active_request.dart';
import 'package:flutter/material.dart';

class DropDownIPRSWidget extends StatelessWidget {
   ValueChanged<Map<String, dynamic>> onElementCallback;
   String elementName;
   Map<String, Map<String, dynamic>> valueFormResults;
   Map<String, dynamic> customTheme;

   DropDownIPRSWidget({
    super.key,
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme
  });

  // Perform some logic or user interaction that generates a callback value
    Map<String, dynamic> callbackElement = {};
    ActiveRequest activeRequest = ActiveRequest();
    List<DropdownMenuItem> choices = [];

    List<String> choiceList = [];
    List<String> _listNotifier = [];
    List<String> _choicesNotifier = [];

   TextEditingController textEditingController = TextEditingController();



  @override
  Widget build(BuildContext context) {

    callbackElement = valueFormResults[elementName]!;


    Key dropdownKey = Key(callbackElement['name']);


    final List<DropdownMenuItem> choiceList = [
      DropdownMenuItem(
        value: callbackElement['label'].toString(),
        child: const Text('Select choices'),
      ),
      for (var i = 0; i < callbackElement['options'].length; i++)
        DropdownMenuItem(
          value: callbackElement['options'][i]['value'],
          child: Text(
              callbackElement['options'][i]['label']),
        )
    ];



    var vl ;
    return Container(
      height: 48.0,
      margin: EdgeInsets.only(bottom:8,top:10,right: 16,left: 16),
      alignment: Alignment.center,
      child: DropdownButtonFormField(
        style: TextStyle(color: Colors.black, fontSize: 14.0),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 3.0,
          ),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                  color: Colors.grey, width: 0.0),
              borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
              borderRadius:
              BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(color: Colors.blue,)),
        ),
        key: dropdownKey,
        hint: const Text('Select choices'),
        value: vl,
        items: choiceList,
        onChanged: (value) {
          callbackElement['value'] = value;
          onElementCallback(callbackElement);
        },
      ),

    );
  }




}
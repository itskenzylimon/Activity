import 'dart:async';
import 'dart:convert';
import 'package:activity/core/networks/active_request.dart';
import 'package:fluent_ui/fluent_ui.dart';

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
    List<ComboBoxItem> choices = [];

    List<String> choiceList = [];
    List<String> _listNotifier = [];
    List<String> _choicesNotifier = [];

   TextEditingController textEditingController = TextEditingController();



  @override
  Widget build(BuildContext context) {

    callbackElement = valueFormResults[elementName]!;


    Key dropdownKey = Key(callbackElement['name']);


    final List<ComboBoxItem> choiceList = [
      ComboBoxItem(
        value: callbackElement['label'].toString(),
        child: const Text('Select choices'),
      ),
      for (var i = 0; i < callbackElement['options'].length; i++)
        ComboBoxItem(
          value: callbackElement['options'][i]['value'],
          child: Text(
              callbackElement['options'][i]['label']),
        )
    ];

    var vl ;
    return Container(
      height: 48.0,
      margin: const EdgeInsets.only(bottom:8,top:10,right: 16,left: 16),
      alignment: Alignment.center,
      child: ComboboxFormField(
        isExpanded: true,
        style: const TextStyle(color: Colors.black, fontSize: 14.0),
        key: dropdownKey,
        placeholder: const Text('Select a choice'),
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
import 'dart:async';
import 'dart:convert';
import 'package:activity/widgets/elements/text_field_iprs.dart';
import 'package:flutter/material.dart';

import '../../core/forms/form_controller.dart';
import '../../core/networks/active_request.dart';
import 'drop_down_field_iprs.dart';

class TextSearchUpdateFieldWidget extends StatefulWidget {
  final ValueChanged<Map<String, dynamic>> onElementCallback;
  final String elementName;
  late final Map<String, Map<String, dynamic>> valueFormResults;
  final Map<String, dynamic> customTheme;

  TextSearchUpdateFieldWidget({
    super.key,
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme
  });

  @override
  State<TextSearchUpdateFieldWidget> createState() => _TextSearchUpdateFieldWidgetState();
}

class _TextSearchUpdateFieldWidgetState extends State<TextSearchUpdateFieldWidget> {
  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};
  var searchStatus = false;

  @override
  Widget build(BuildContext context) {

    callbackElement = widget.valueFormResults[widget.elementName]!;



    return SizedBox(
        height: 320,
        child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: callbackElement['lookup'].length,
        itemBuilder: (BuildContext context, int index) {
          final item = callbackElement['lookup'][index];
          return searchStatus == false ?
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12,left:16,right:16),
                child: Text('${item['name']}',
                    style: TextStyle(color: Colors.green,fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: item['parameters'].length,
                  itemBuilder: (BuildContext context, int index) {
                    final parameters = item['parameters'][index];
                    TextEditingController textEditingController = TextEditingController();

                    if(parameters['type'] == 'dropdown') {
                      /// call setUpElement
                      Map<String, dynamic> newElement = {
                        'value': callbackElement['outputs'][0]['value'],
                      }..addAll(item['parameters'][index]);
                      /// new element value
                      Map<String, dynamic> newValue = newElement;

                      /// add the element to the formValues map
                      if(widget.valueFormResults.containsKey('${item['parameters'][index]['name']}-${callbackElement['outputs'][0]['value']}') == false){

                        // setState(() {
                          /// Add the value
                          widget.valueFormResults.putIfAbsent('${item['parameters'][index]['name']}-${callbackElement['outputs'][0]['value']}', () => newValue);
                        // });

                      }
                    } else {
                      /// call setUpElement
                      Map<String, dynamic> newElement = {
                        'value': textEditingController.text,
                        'controller': textEditingController,
                      }..addAll(item['parameters'][index]);
                      /// new element value
                      Map<String, dynamic> newValue = newElement;

                      /// add the element to the formValues map
                      if(widget.valueFormResults.containsKey('${item['parameters'][index]['name']}-${callbackElement['outputs'][0]['value']}') == false){

                        // setState(() {
                          /// Add the value
                          widget.valueFormResults.putIfAbsent('${item['parameters'][index]['name']}-${callbackElement['outputs'][0]['value']}', () => newValue);
                        // });

                      }
                    }




                    return Container(
                      child: parameters['type'] == 'dropdown'
                          ? DropDownIPRSWidget(
                        onElementCallback: (Map<String, dynamic> value) {
                          setState(() {

                            Map<String, Map<String, dynamic>> newValueFormResults = widget.valueFormResults;
                            newValueFormResults['${item['parameters'][index]['name']}-${callbackElement['outputs'][0]['value']}'] = value;
                            // widget.valueFormResults = newValueFormResults;
                          });
                        },
                        elementName: '${item['parameters'][index]['name']}-${callbackElement['outputs'][0]['value']}',
                        valueFormResults: widget.valueFormResults, customTheme: {},
                      )
                          :
                      TextFieldIPRSWidget(
                        onElementCallback: (Map<String, dynamic> value) {
                          setState(() {
                            Map<String, Map<String, dynamic>> newValueFormResults = widget.valueFormResults;

                            newValueFormResults['${item['parameters'][index]['name']}-${callbackElement['outputs'][0]['value']}'] = value;
                            // widget.valueFormResults = newValueFormResults;
                          });
                        },
                        elementName: '${item['parameters'][index]['name']}-${callbackElement['outputs'][0]['value']}',
                        valueFormResults: widget.valueFormResults, customTheme: {},
                      )
                    );
                  },
                ),
              ),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                  child: OutlinedButton(
                onPressed: () async {

                  setState(() {
                    searchStatus = true;
                  });
                  TextEditingController idEditingController =
                  TextEditingController();
                  TextEditingController firstNameController =
                  TextEditingController();
                  idEditingController = widget.valueFormResults[
                  'id_number-${callbackElement['outputs'][0]['value']}']![
                  'controller'];
                  firstNameController = widget.valueFormResults[
                  'first_name-${callbackElement['outputs'][0]['value']}']![
                  'controller'];

                  var idType;
                  if (widget.valueFormResults.containsKey(
                      'id_type-${callbackElement['outputs'][0]['value']}')) {

                    if (widget.valueFormResults[
                    'id_type-${callbackElement['outputs'][0]['value']}'] !=
                        null) {
                      idType = widget.valueFormResults[
                      'id_type-${callbackElement['outputs'][0]['value']}']![
                      'value'];

                      if (idType == 'NationalIdentification') {
                        var data = await httpLookUpUrl({
                          "url": "http://197.248.4.134/iprs/databyid",
                          "id": '${idEditingController.text}',
                          "data": callbackElement['outputs'][0]['value']
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                duration: const Duration(milliseconds: 500),
                                content: Text('Processing Data')));
                        var resData;

                        if (data['first_name'].toLowerCase().contains(
                            firstNameController.text.toLowerCase())) {
                          for (var i in callbackElement['outputs']) {
                            TextEditingController textEditingController =
                            TextEditingController();

                            if (widget.valueFormResults.containsKey(i['value']))
                            {

                              resData = _textSelect(i['text']);

                              textEditingController.text =
                                  data['$resData'] ?? '';
                              callbackElement['value'] = textEditingController.text;
                              widget.onElementCallback(callbackElement);


                                setState(() {

                                  searchStatus = false;
                                  switch  (_textSelect(i['text'])) {
                                    case 'dob':
                                       widget
                                          .valueFormResults[i['value']]!['value']
                                      = calculateAge(data['$resData']) ?? '';
                                       break;

                                    case 'gender':
                                       widget
                                          .valueFormResults[i['value']]!['value']
                                      = data['$resData'] ?? '';
                                       break;

                                    default:
                                      widget
                                            .valueFormResults[i['value']]!['controller']
                                            .text = data['$resData'] ?? '';
                                       widget
                                          .valueFormResults[i['value']]!['value']
                                      = data['$resData'] ?? '';
                                  }





                                });

                              // });

                            }
                          }
                        }
                        else {
                          setState(() {
                            searchStatus = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'First Name does not match particulars')));
                        }

                      } else if (idType == 'AlienIdentification') {
                        var data = await httpLookUpUrl({
                          "url": "http://197.248.4.134/iprs/databyalienid",
                          "id": '${idEditingController.text}',
                          "data": callbackElement['outputs'][0]['value']
                        });
                      }
                    }
                  }
                },
                child: const Text('Search'),
              )

              )
            ],
          ) :
          Center(child: CircularProgressIndicator());
        }));

  }



  String _textSelect(String str) {
    str = str.replaceAll('<<', '');
    str = str.replaceAll('>>', '');
    str = str.replaceAll('result.', '');
    str = str.replaceAll(' ', '');
    return str;
  }

  Future<Map<String, dynamic>> httpLookUpUrl(Map choicesByUrl) async {

    Map<String, dynamic> choices = await formRequest(choicesByUrl);
    if (widget.valueFormResults.containsKey(choicesByUrl['data'])) {}

    return choices;
  }

  Future<Map<String, dynamic>> formRequest(Map request) async {
    String username = 'mrmiddleman';
    String password = '6I2-u?=W';
    // String basicAuth = base64Encode(utf8.encode('$username:$password'));
    String basicAuth = 'bXJtaWRkbGVtYW46NkkyLXU/PVc=';
    ActiveRequest activeRequest = ActiveRequest();
    activeRequest.setUp = RequestSetUp(
        idleTimeout: 10,
        connectionTimeout: 10,
        logResponse: true,
        withTrustedRoots: true,
        httpHeaders: {
          'Authorization': 'Basic ${basicAuth.replaceAll(' ', '')}',
        });

    /// Handle httplookup
    /// Handle choicesByUrl

    ActiveResponse activeResponse = await activeRequest.getApi(Params(
        endpoint: request['url'],
        queryParameters: {"number": "${request['id']}"}));
    final Map<String, dynamic> convertedData =
    jsonDecode(activeResponse.data!);
    return convertedData;
  }

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
    return age.toString();
  }
}
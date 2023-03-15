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

  @override
  Widget build(BuildContext context) {

    callbackElement = widget.valueFormResults[widget.elementName]!;
    // print('????ELEMNT NAME IPRS ???>>>>>>');
    // print(widget.elementName);
    // print(callbackElement);
    // print(callbackElement['lookup']);


    return SizedBox(
        height: 270,
        child: ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        itemCount: callbackElement['lookup'].length,
        itemBuilder: (BuildContext context, int index) {
          final item = callbackElement['lookup'][index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12,left:16,right:16),
                child: Text('${item['name']}',
                    style: TextStyle(color: Colors.green,fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                height: 195,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: item['parameters'].length,
                  itemBuilder: (BuildContext context, int index) {
                    // print('????ELEMNT NAME IPRS');
                    // print(item['parameters'][index]);
                    // print(item['parameters']);
                    // print('Outpurs ????');
                    // print(callbackElement['outputs']);
                    // print(callbackElement['outputs'][0]);
                    // print(callbackElement['outputs'][0]['value']);
                    // print('${item['parameters'][index]['name']}-${callbackElement['outputs'][0]['value']}');
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
                          // print(value);
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
                          // print(value);
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
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child:
              OutlinedButton(
                onPressed: () async {
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
                                duration: const Duration(milliseconds: 250),
                                content: Text('Processing Data')));
                        var resData;
                        if (data['first_name'].toLowerCase().contains(
                            firstNameController.text.toLowerCase())) {
                          for (var i = 0;
                          i < callbackElement['outputs'].length;
                          i++) {
                            TextEditingController textEditingController =
                            TextEditingController();

                            if (widget.valueFormResults.containsKey(
                                callbackElement['outputs'][i]['value'])) {
                              resData = _textSelect(
                                  callbackElement['outputs'][i]['text']);


                              textEditingController.text =
                                  data['$resData'] ?? '';
                              callbackElement['value'] = textEditingController.text;
                              widget.onElementCallback(callbackElement);

                              setState(() {
                                widget
                                    .valueFormResults[callbackElement['outputs'][i]
                                ['value']]!['controller']
                                    .text = data['$resData'] ?? '';
                              });
                            }
                          }
                        } else {
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
              ),)
            ],
          );
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
}
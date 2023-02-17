import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:activity/activity.dart';
import 'package:activity/core/forms/signature.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../helpers/logger.dart';

class FormBuilder extends StatefulWidget {
  final List elements;
  final ActiveMap<String, Map<String, dynamic>> formResults;
  final BuildContext context;

  const FormBuilder({
    required this.elements,
    required this.context,
    required this.formResults,
  });

  @override
  _FormBuilderState createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 1.5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.blue,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => log('Value changed'));
  }

  @override
  void dispose() {
    // IMPORTANT to dispose of the controller
    _controller.dispose();
    super.dispose();
  }

  exportImage(element) async {
    final Uint8List? data =
        await _controller.toPngBytes(height: 1000, width: 1000);
    if (data == null) {
      return;
    } else {
      printSuccess(data);
      List<int> fileInByte = data;
      String fileInBase64 = base64Encode(fileInByte);
      printSuccess(fileInBase64);
      widget.formResults.add(
          element['name'],
          {
            'controller': element['name'],
            'value': element['label'].toString(),
            'label': element['label'],
            'type': 'file',
            'file': fileInBase64,
            'extras': {}
          },
          notifyActivities: false);
    }
    if (!mounted) return;
  }

  convertToBase64(var image) async {
    List<int> fileInByte = image.readAsBytesSync();
    String fileInBase64 = base64Encode(fileInByte);
    printSuccess(fileInBase64)
;    return fileInBase64;
  }

  Center create() {
    // Key / value for the form
    TextEditingController textCont = TextEditingController();
    // Map representation of the formResults
    Map formValues = widget.formResults.value;
    /// invisibilityList is a list of elements that are invisible
    List invisibilityList = [];

    String textCont1 = "";
    String textCont2 = "";

    Timer? _debounce;
    ActiveRequest activeRequest = ActiveRequest();
    Future<List> getListItems(
      query,
      url,
    ) async {
      var list = [];
      activeRequest.setUp = RequestSetUp(
        idleTimeout: 10,
        connectionTimeout: 10,
        logResponse: true,
        withTrustedRoots: true,
      );
      printNormal(url);
      ActiveResponse userDataRes =
          await activeRequest.getApi(Params(endpoint: url, queryParameters: {
        '': "",
      }));

      if (userDataRes.statusCode == 200) {
        printWarning("dropdown data here");
        printSuccess(userDataRes.data);
        var data = json.decode(userDataRes.data!);
        var filteredList = data
            .where((elem) =>
                elem['value'].toString().toLowerCase().contains(query.toLowerCase()) ||
                elem['text'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
        list = filteredList.toSet().toList();
      } else {
        // printError(response['error_description']);
      }
      return list;
    }

    Future<List> getChoicesByUrl(
      query,
      url,
    ) async {
      var list = [];
      activeRequest.setUp = RequestSetUp(
        idleTimeout: 10,
        connectionTimeout: 10,
        logResponse: true,
        withTrustedRoots: true,
      );
      printNormal(url);
      ActiveResponse userDataRes =
          await activeRequest.getApi(Params(endpoint: url, queryParameters: {
        '': "",
      }));

      if (userDataRes.statusCode == 200) {
        var data = json.decode(userDataRes.data!);
        var listData = [];
        if (data is Map) {
          data.forEach((key, value) {
             for (var j = 0; j < value.length; j++) {
            listData.add(value[j]);
          }
          });

        } else if (data is List) {
          printWarning("this is a list data");
          printWarning("this is a list ${data.runtimeType}");
          for (var i = 0; i < data.length; i++) {
            listData.add(data[i]);
          }
        }
        var filteredList = listData
            .where((elem) => elem['value'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
        list = filteredList.toSet().toList();
        printSuccess(list);
      } else {
        // printError(response['error_description']);
      }
      return list;
    }

    /// List results
    /// key : {
    ///  key: dynamic,
    /// }
    ///
    /// key Element name
    /// Controller
    ///

    /// Validation func

    /// Logic fun
    String? path;

    String getBase64FormateFile(String path) {
      File file = File(path);
      print('File is = ' + file.toString());
      List<int> fileInByte = file.readAsBytesSync();
      String fileInBase64 = base64Encode(fileInByte);
      return fileInBase64;
    }

    String _textSelect(String str) {
      str = str.replaceAll('<<', '');
      str = str.replaceAll('>>', '');
      str = str.replaceAll('result.', '');
      str = str.replaceAll(' ', '');
      return str;
    }

    //upload file
    Future<String> getFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result == null) return "";
      path = result.files.single.path!;
      return getBase64FormateFile(path!);
    }

    /// Helper func
    String trimCurly(String value) {
      int start = value.indexOf("{") + 1;
      int end = value.indexOf("}");
      return value.substring(start, end);
    }

    List trimListString(String value) {
      int start = value.indexOf("[") + 1;
      int end = value.indexOf("]");
      return value.substring(start, end)
          .split(",").toList();
    }

    String conditionValue(String value) {
      printSuccess('@@@@@#$value');
      int start = value.indexOf(" = ");
      return value.substring(start);
    }

    /// Use this to split the string by [and, or]
    /// and remove the ' from values
    /// returns a list of strings
    List splitStringList(String value) {
      List splits = [];
      /// separate a string by or and remove the ' from values
      if(value.contains(" or ")){
        splits.addAll(value.split(" or ").map((str) => str.replaceAll("'", "")).toList());
      }
      /// separate a string by and and remove the ' from values
      if(value.contains(" and ")){
        splits.addAll(value.split(" and ").map((str) => str.replaceAll("'", "")).toList());
      }
      return splits;
    }

    /// Use this to split the string by [and, or]
    /// and remove the ' from values
    /// returns a bool
    bool enableIf(element) {

      bool enabled = true;
      if (element['readOnly'] != null) {
        printError('sfds');
        enabled = element['readOnly'];
      }


      if (element['enableIf'] != null) {
        printError(element);
        /// Handle anyof conditions
        /// it should overwrite enabled state from above

        /// Here we handle the many conditions in the visibleIf
        if (element['enableIf'].toString().contains('anyof')) {
          List enableIfConditions = splitStringList(element['enableIf']);
          for (String search in enableIfConditions) {
            if (widget.formResults[trimCurly(search)] != null) {
              /// TODO: Handel for OR conditions
              //data found, now check if trimCurly is in getListString
              enabled = trimListString(search).contains(trimCurly(search))
                  ? true
                  : false;
            }
          }
        }
      }

      /// Handle notempty conditions
      /// it should overwrite enabled state from above
      if (element['enableIf'].toString().contains('notempty')) {
        /// Here we handle the many conditions in the visibleIf
        List enableIfConditions = splitStringList(element['enableIf']);
        for (String search in enableIfConditions) {
          if (widget.formResults[trimCurly(search)] != null) {
            return true;
          }
        }
      }
      return enabled;
    }

    /// Use this to split the string by [and, or]
    /// and remove the ' from values
    visibleIf() {
      bool visible = true;
      formValues.forEach((key, value) {
        if (value['visible'] != null) {
          visible = value['visible'];
        }

        if (value['visibleIf'] != null) {
          printInfo(value['visibleIf']);
          printInfo('{{{{visibleIf}}}}');

          /// create a list of conditions
          /// Handle or conditions
          /// Handle and conditions
          List visibleIfConditions = splitStringList(value['visibleIf']);
          /// loop through visibleIfConditions
          for (var condition in visibleIfConditions) {
            /// Handle anyof conditionType
            /// it should overwrite visible state from above
            if (condition.toString().contains(' anyof ')) {
              /// Here we handle the many conditions in the visibleIf that meet
              /// the anyof condition type
              if (widget.formResults[trimCurly(condition)] != null) {
                //data found, now check if trimCurly is in getListString
                visible = trimListString(condition).contains(trimCurly(condition))
                    ? true
                    : false;
              }
            }
            /// Handle notempty conditions
            /// it should overwrite enabled state from above
            if (condition.toString().contains(' notempty ')) {
              /// Here we handle the many conditions in the visibleIf that meet
              /// the notempty condition type
              if (widget.formResults[trimCurly(condition)] != null) {
                visible = widget.formResults[trimCurly(condition)]!['value'] != ''
                    ? true
                    : false;
              }
            }

            /// Handle = conditions
            /// it should overwrite enabled state from above
            if (condition.toString().contains(' = ')) {
              /// Here we handle the many conditions in the visibleIf that meet
              /// the = condition type
              if (widget.formResults[trimCurly(condition)] != null) {
                /// get condition value
                String value = conditionValue(condition);
                visible = widget.formResults[trimCurly(condition)]!['value'] == value
                    ? true
                    : false;
              }
            }
          }
          /// check if visible is false and add to visible list
          if(!visible){
            if(!invisibilityList.contains(value['name'])){
              setState(() {
                invisibilityList.add(value['name']);
              });
            } else{
              setState(() {
                invisibilityList.remove(value['name']);
                invisibilityList.add(value['name']);
              });
            }
          } else if (visible && invisibilityList.contains(value['name'])) {
            /// check if visible is true and remove from visible list
            setState(() {
              invisibilityList.remove(value['name']);
            });
          }
        }
      });
    }

    Future<Map<String, dynamic>> formRequest(Map request) async {
      String username = 'mrmiddleman';
      String password = '6I2-u?=W';
      // String basicAuth = base64Encode(utf8.encode('$username:$password'));
      String basicAuth = 'bXJtaWRkbGVtYW46NkkyLXU/PVc=';
      print(basicAuth);
      print(request['id']);
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

      printWarning('URL ?????????');
      printWarning(request['url']);
      printWarning(activeRequest.setUp.httpHeaders);
      ActiveResponse activeResponse = await activeRequest.getApi(Params(
          endpoint: request['url'],
          queryParameters: {"number": "${request['id']}"}));
      printError("Active Respobse ??????");
      printError(activeResponse);
      final Map<String, dynamic> convertedData =
          jsonDecode(activeResponse.data!);
      return convertedData;
    }

    Future<Map<String, dynamic>> choicesByUrl(Map choicesByUrl) async {
      Map<String, dynamic> choices = await formRequest(choicesByUrl);
      return choices;
    }

    Future<Map<String, dynamic>> httpLookUpUrl(Map choicesByUrl) async {
      printError("????????");
      printError(choicesByUrl);

      Map<String, dynamic> choices = await formRequest(choicesByUrl);
      printInfo("choices ???");
      printInfo(choices);
      if (widget.formResults.containsKey(choicesByUrl['data'])) {}

      return choices;
    }

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

    Visibility textField(Map<String, dynamic> element) {
      Key textFieldKey = Key(element['name']);
      TextEditingController textEditingController = TextEditingController();
      bool isRequired = element['isRequired'] ?? false;
      String labelText = element['title'] + (isRequired == true ? ' * ' : '');

      /// Add to the widget.formResults
      if (widget.formResults.containsKey(element['name'])) {
        textEditingController.text =
            widget.formResults[element['name']]!['value'] ?? '';
        widget.formResults.update(
            element['name'],
            (value) => {
                  'controller': textEditingController,
                  'value': textEditingController.text,
                  'label': labelText,
                  'type': 'text',
                  'extras': widget.formResults[element['name']]!['extras'] ?? {}
                },
            notifyActivities: false);
      } else {
        widget.formResults.add(
            element['name'],
            {
              'controller': textEditingController,
              'value': textEditingController.text,
              'label': labelText,
              'type': 'text',
              'extras': {}
            },
            notifyActivities: false);
      }

      /// return the widget to be displayed
      return Visibility(
        visible: invisibilityList.contains(element['name']) ? false : true,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Center(
            child: TextFormField(
              controller: widget.formResults[element['name']]!['controller'],
              keyboardType: checkInputType(element),
              key: textFieldKey,
              readOnly: !enableIf(element),
              maxLines: element['type'] == 'comment' ? 5 : 1,
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
                focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.black,)),
                labelText: labelText,
                hintText: element['placeholder'] ?? '',
              ),
              validator: (value) {
                /// check if value is required
                if (element['isRequired'] == true) {
                  /// input validator for numbers
                  if (element['inputType'] == 'number') {
                    int intValue = int.parse(value ?? '0');
                    //check if max exist
                    if (element['max'] != null) {
                      if (intValue > element['max']) {
                        return '${element['max']} is the max ${element['title']}';
                      }
                    }
                    //check if min exist
                    if (element['min'] != null) {
                      if (element['min'] > intValue) {
                        return '${element['min']} is the min ${element['title']}';
                      }
                    }
                    //
                  }
                }

                if (value == null || value.isEmpty) {
                  return (element['title'] + ' is required');
                } else if (value.contains('@')) {
                  return 'Please don\'t use the @ char.';
                }
                return null;
              },
              onChanged: (value) {
                widget.formResults.remove(element['name'], notifyActivities: false);
                widget.formResults.add(
                    element['name'],
                    {
                      'controller': textEditingController,
                      'value': value,
                      'label': labelText,
                      'type': 'text',
                      'extras': {}
                    },
                    notifyActivities: false);

                printError(widget.formResults);
              },
            ),
          ),
        ),
      );
    }

    Visibility textFieldIPRS(Map<String, dynamic> element, value) {
      printInfo("????????>>>>");
      printInfo(element);
      Key textFieldKey = Key(element['name']);
      TextEditingController textEditingController = TextEditingController();
      bool isRequired = true;
      String labelText = element['label'] + (isRequired == true ? ' * ' : '');

      /// Add to the widget.formResults
      if (widget.formResults.containsKey('$value-${element['name']}')) {
        textEditingController.text =
            widget.formResults['$value-${element['name']}']!['value'] ?? '';
        widget.formResults.update(
            '$value-${element['name']}',
            (value) => {
                  'controller': textEditingController,
                  'value': textEditingController.text,
                  'label': labelText,
                  'type': 'text',
                  'extras': {}
                },
            notifyActivities: false);
      } else {
        printWarning(value);
        printWarning(element['name']);

        widget.formResults.add(
            '$value-${element['name']}',
            {
              'controller': textEditingController,
              'value': textEditingController.text,
              'label': labelText,
              'type': 'text',
              'extras': {}
            },
            notifyActivities: false);

        textEditingController.text =
            widget.formResults['$value-${element['name']}']!['value'] ?? '';
      }

      /// return the widget to be displayed
      return Visibility(
        visible: invisibilityList.contains(element['name']) ? false : true,
        child: TextFormField(
          controller:
              widget.formResults['$value-${element['name']}']!['controller'],
          keyboardType: checkInputType(element),
          key: textFieldKey,
          // readOnly: enableIf(element),
          maxLines: element['type'] == 'comment' ? 5 : 1,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: element['placeholder'] ?? '',
          ),
          validator: (value) {
            /// always  required
            /// input validator for numbers
            if (element['type'] == 'number') {
              int intValue = int.parse(value ?? '0');
              //check if max exist
              if (element['max'] != null) {
                if (intValue > element['max']) {
                  return '${element['max']} is the max ${element['title']}';
                }
              }
              //check if min exist
              if (element['min'] != null) {
                if (element['min'] > intValue) {
                  return '${element['min']} is the min ${element['title']}';
                }
              }
              //
            }

            if (value == null || value.isEmpty) {
              return (element['label'] + ' is required');
            } else if (value.contains('@')) {
              return 'Please don\'t use the @ char.';
            }
            return null;
          },
          onChanged: (value) {
            widget.formResults
                .remove('$value-${element['name']}', notifyActivities: false);
            widget.formResults.add(
                '$value-${element['name']}',
                {
                  'controller': textEditingController,
                  'value': value,
                  'label': labelText,
                  'type': 'text',
                  'extras': {}
                },
                notifyActivities: false);

            printError(widget.formResults);
          },
        ),
      );
    }

    Visibility dropdownChoices(Map<String, dynamic> element) {
      Key dropdownKey = Key(element['name']);
      Key key = Key("123");
      printSuccess(element['name']);
      String? currentSelectedValue = 'Select ${element['title']}';

      ValueNotifier<List<String>> _listNotifier =
          ValueNotifier<List<String>>(["Select ${element['title']}"]);
      ValueNotifier<List<String>> _choicesNotifier =
          ValueNotifier<List<String>>(["Select ${element['title']}"]);
      List<String> choiceList = [..._listNotifier.value];
      List<String> choicesbyurl = [..._choicesNotifier.value];

      /// Add to the widget.formResults
      if (widget.formResults.containsKey(element['name']) == false) {
        printInfo('{{{element}}}');
        printInfo(element['name']);

        widget.formResults.add(
            element['name'],
            {
              'controller': element['name'],
              'value': element['title'].toString(),
              'label': element['title'],
              'type': 'dropdown',
              'options': element['choices'],
              'extras': {}
            },
            notifyActivities: false);
      }
      List<DropdownMenuItem> choices = [];

      if (element['renderAs'] == null && element['choices'] != null) {
        choices = [
          DropdownMenuItem(
            value: element['title'].toString(),
            child: Text(element['title']),
          ),
          for (var i = 0; i < element['choices'].length; i++)
            DropdownMenuItem(
              value: widget.formResults[element['name']]!['options'][i] ?? "na",
              child: Text(
                  widget.formResults[element['name']]!['options'][i] ?? ""),
            )
        ];
      }
      if (formValues.containsKey(element['name']) == false) {
        formValues['${element['name']}'] = widget.formResults[element['name']];
      }

      String vl = formValues[element['name']]['value'];
      if (element['renderAs'] != null && element['renderAs'] == 'select2') {
        return Visibility(
            // visible: visibleIf(element),
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey)),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 12, left: 16),
                  ),
                  controller: textCont,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce =
                          Timer(const Duration(milliseconds: 1000), () async {
                        var list = await getListItems(
                          value,
                          element['choicesByUrl']['url'],
                        );
                        for (var l in list) {
                          choiceList.add(
                            l['value'].toString(),
                          );
                          _listNotifier.value = choiceList;
                        }
                      });
                    } else {
                      setState(() {
                        choiceList = ['Select ${element['title']}'];
                      });
                    }
                  },
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: _listNotifier,
                  builder: (BuildContext context, choiceList, Widget? child) {
                    return Container(
                        width: double.infinity,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, int index) {
                            return Container(
                              child: ListTile(
                                onTap: () {
                                  widget.formResults.add(
                                      element['name'],
                                      {
                                        'controller': element['name'],
                                        'value': choiceList[index],
                                        'label': element['title'],
                                        'type': 'select2',
                                        'options': "",
                                        'extras': {}
                                      },
                                      notifyActivities: false);
                                  textCont.text = choiceList[index];
                                  printWarning(textCont.text);
                                  choiceList.clear();
                                  choiceList.add(textCont.text);
                                  _listNotifier.notifyListeners();
                                },
                                title: Text(choiceList[index]),
                              ),
                            );
                          },
                          separatorBuilder: (context, int index) => SizedBox(height: 10),
                          itemCount: choiceList.length,
                        ));
                  }),
            ],
          ),
        ));
      } else if (element['renderAs'] == null && element['choicesByUrl'] != null) {
        return Visibility(
            // visible: visibleIf(element),
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey)),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: textCont1 == "" ? 'Search' : textCont1,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 12, left: 16),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      if (_debounce?.isActive ?? false) _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () async {
                        var list = await getChoicesByUrl(
                          value,
                          element['choicesByUrl']['url'],
                        );
                        for (var l in list) {
                          choicesbyurl.add(
                            l['value'].toString(),
                          );
                          _choicesNotifier.value = choicesbyurl;
                        }
                      });
                    } else {
                      setState(() {
                        choicesbyurl = ["Select ${element['title']}"];
                      });
                    }
                  },
                ),
              ),
              ValueListenableBuilder(
                  valueListenable: _choicesNotifier,
                  builder: (BuildContext context, choicesbyurl, Widget? child) {
                    return Container(
                        width: double.infinity,
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, int index) {
                            return Container(
                              child: ListTile(
                                onTap: () {
                                  widget.formResults.add(
                                      element['name'],
                                      {
                                        'controller': element['name'],
                                        'value': choicesbyurl[index],
                                        'label': element['title'],
                                        'type': 'dropdownChoices',
                                        'options': "",
                                        'extras': {}
                                      },
                                      notifyActivities: false);
                                  textCont1 = choicesbyurl[index];
                                  choicesbyurl.clear();
                                  choicesbyurl.add(textCont1);
                                  _choicesNotifier.notifyListeners();
                                },
                                title: Text(choicesbyurl[index]),
                              ),
                            );
                          },
                          separatorBuilder: (context, int index) => SizedBox(height: 10),
                          itemCount: choicesbyurl.length,
                        ));
                  }),
            ],
          ),
        ));
      } else {
        return Visibility(
          visible: !invisibilityList.contains(element['name']),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                key: dropdownKey,
                hint: Text(
                    element['title'] + ' ' + (element['description'] ?? '')),
                value: formValues[element['name']]['value'],
                items: choices,
                onChanged: (value) {
                  widget.formResults.remove(element['name'], notifyActivities: false);
                  widget.formResults.add(
                      element['name'],
                      {
                        'controller': element['name'],
                        'value': value,
                        'label': element['title'],
                        'type': 'dropdown',
                        'options': element['choices'],
                        'extras': {}
                      },
                      notifyActivities: false);

                  setState(() {
                    formValues['${element['name']}'] = {
                      'controller': element['name'],
                      'value': value,
                      'label': element['title'],
                      'type': 'dropdown',
                      'options': element['choices'],
                      'extras': {}
                    };
                  });
                },
              ),
            ),
          ),
        );
      }
    }

    Visibility dropdownChoicesIPRS(Map<String, dynamic> element, valueItem) {
      printWarning("?>DS>A>>>D>D");
      printWarning(valueItem);
      var labelText = valueItem;

      Key dropdownKey = Key('$labelText-${element['name']}');

      /// Add to the widget.formResults
      if (widget.formResults.containsKey('$labelText-${element['name']}') ==
          false) {
        printInfo('{{{element}}}');
        printInfo('$labelText-${element['name']}');

        widget.formResults.add(
            '$labelText-${element['name']}',
            {
              'controller': '$labelText-${element['name']}',
              'value': element['label'].toString(),
              'label': element['label'],
              'type': 'text',
              'options': element['options'],
              'extras': {}
            },
            notifyActivities: false);
      }

      if (element['options'] == null) {
        /// check if its a choicesByUrl
        /// Make a httpRequest

        // ActiveRequest activeRequest = ActiveRequest();
      } else {
        // choices.add(element['label'].toString());
      }

      final List<DropdownMenuItem> choiceList = [
        DropdownMenuItem(
          value: element['label'].toString(),
          child: const Text('Select choices'),
        ),
        for (var i = 0; i < element['options'].length; i++)
          DropdownMenuItem(
            value:
                widget.formResults['$labelText-${element['name']}']!['options']
                    [i]['value'],
            child: Text(
                widget.formResults['$labelText-${element['name']}']!['options']
                    [i]['label']),
          )
      ];

      if (formValues.containsKey('$labelText-${element['name']}') == false) {
        formValues['$labelText-${element['name']}'] =
            widget.formResults['$labelText-${element['name']}'];
      }

      String vl = formValues['$labelText-${element['name']}']['value'];

      return Visibility(
        visible: invisibilityList.contains(element['name']) ? false : true,
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              key: dropdownKey,
              hint: const Text('Select choices'),
              value: vl,
              items: choiceList,
              onChanged: (value) {
                printSuccess("Value Selected");
                printSuccess(value);
                printSuccess('$labelText-${element['name']}');
                print("????? VALUE");
                widget.formResults.remove('$labelText-${element['name']}',
                    notifyActivities: false);
                widget.formResults.add(
                    '$labelText-${element['name']}',
                    {
                      'controller': '$labelText-${element['name']}',
                      'value': value,
                      'label': element['label'],
                      'type': 'text',
                      'options': element['options'],
                      'extras': {}
                    },
                    notifyActivities: false);

                setState(() {
                  formValues['$labelText-${element['name']}'] = {
                    'controller': '$labelText-${element['name']}',
                    'value': value,
                    'label': element['label'],
                    'type': 'text',
                    'options': element['options'],
                    'extras': {}
                  };
                });
              },
            ),
          ),
        ),
      );
    }

    Visibility ageCalc(Map<String, dynamic> element) {
      Key textFieldKey = Key(element['name']);
      TextEditingController textEditingController = TextEditingController();
      TextEditingController agecalcEditingController = TextEditingController();
      String labelText = element['title'];

      /// return the widget to be displayed
      return Visibility(
        // visible: visibleIf(element),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 20,
          ),
          Text(
            "$labelText",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            keyboardType: checkInputType(element),
            key: textFieldKey,
            readOnly: enableIf(element),
            decoration: InputDecoration(
              labelText: labelText,
              hintText: element['placeholder'] ?? '',
            ),
            validator: (value) {},
            onChanged: (value) {
              widget.formResults.remove(element['name'], notifyActivities: false);
              widget.formResults.add(
                  element['name'],
                  {
                    'controller': agecalcEditingController,
                    'value': value,
                    'label': labelText,
                    'type': 'agecalc',
                    'extras': {}
                  },
                  notifyActivities: false);
            },
          ),
        ]),
      );
    }

    Visibility htmlText(Map<String, dynamic> element) {
      printError(' **** ' + element['name']);
      return Visibility(
          visible: !invisibilityList.contains(element['name']),
          child: Html(
            data: element['displayTemplate'],
          ));
    }

    Visibility httpLookUp(Map<String, dynamic> element) {
      // httpLookUpUrl(element);

      /// after loading update the data forms
      return Visibility(
          visible: !invisibilityList.contains(element['name']),
          child: SizedBox(
        height: 300,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: element['lookup'].length,
            itemBuilder: (BuildContext context, int index) {
              final item = element['lookup'][index];
              printWarning("????????>>>> ELEMENT");
              printWarning(element);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text('${item['name']}',
                        style: TextStyle(color: Colors.green)),
                  ),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: item['parameters'].length,
                      itemBuilder: (BuildContext context, int index) {
                        final parameters = item['parameters'][index];
                        printWarning("????????>>>> ELEMENT");
                        printWarning(element);
                        return Container(
                          child: parameters['type'] == 'dropdown'
                              ? dropdownChoicesIPRS(
                                  parameters, element['outputs'][0]['value'])
                              : textFieldIPRS(
                                  parameters, element['outputs'][0]['value']),
                        );
                      },
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      TextEditingController idEditingController =
                          TextEditingController();
                      TextEditingController firstNameController =
                          TextEditingController();
                      idEditingController = widget.formResults[
                              '${element['outputs'][0]['value']}-id_number']![
                          'controller'];
                      firstNameController = widget.formResults[
                              '${element['outputs'][0]['value']}-first_name']![
                          'controller'];

                      var idType;
                      if (widget.formResults.containsKey(
                          '${element['outputs'][0]['value']}-id_type')) {
                        if (widget.formResults[
                                '${element['outputs'][0]['value']}-id_type'] !=
                            null) {
                          idType = widget.formResults[
                                  '${element['outputs'][0]['value']}-id_type']![
                              'value'];

                          if (idType == 'NationalIdentification') {
                            var data = await httpLookUpUrl({
                              "url": "http://197.248.4.134/iprs/databyid",
                              "id": '${idEditingController.text}',
                              "data": element['outputs'][0]['value']
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    duration: const Duration(milliseconds: 250),
                                    content: Text('Processing Data')));
                            var resData;
                            printWarning(data['first_name']);
                            printWarning(firstNameController.text);
                            if (data['first_name'].toLowerCase().contains(
                                firstNameController.text.toLowerCase())) {
                              for (var i = 0;
                                  i < element['outputs'].length;
                                  i++) {
                                TextEditingController textEditingController =
                                    TextEditingController();

                                if (widget.formResults.containsKey(
                                    element['outputs'][i]['value'])) {
                                  resData = _textSelect(
                                      element['outputs'][i]['text']);
                                  widget.formResults.remove(
                                      element['outputs'][i]['value'],
                                      notifyActivities: false);
                                  textEditingController.text =
                                      data['$resData'] ?? '';
                                  widget.formResults.add(
                                      element['outputs'][i]['value'],
                                      {
                                        'controller': textEditingController,
                                        'value': textEditingController.text,
                                        'label': element['outputs'][i]['value'],
                                        'type': 'text',
                                        'extras': {}
                                      },
                                      notifyActivities: false);

                                  setState(() {
                                    widget
                                        .formResults[element['outputs'][i]
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
                              "data": element['outputs'][0]['value']
                            });
                          }
                        }
                      }
                      },
                    child: const Text('Search'),
                  ),
                ],
              );
            }),
      ));
    }

    Ink datepicker(Map<String, dynamic> element) {
      TextEditingController _textEditingController = TextEditingController();
      DateTime selectedDate = DateTime.now();
      DateTime maxDays = DateTime.now();
      if (element['maxDays'] != null) {
        maxDays.add(Duration(days: element['maxDays']));
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
          _textEditingController.text = selectedDate.toString();
        }
      }

      return Ink(
        child: TextField(
          onTap: () {
            selectDate(context);
          },
          readOnly: true,
          decoration: InputDecoration(
            hintText: element['title'],
            hintStyle: TextStyle(color: Colors.black),
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                width: 1.5,
                color: Colors.grey,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
          ),
          controller: _textEditingController,
          onChanged: (value) {},
        ),
      );
    }

    Visibility radiogroup(Map<String, dynamic> element) {
      List choices = [];

      // element['choices'].forEach((item) {
      //   bool add = false;
      //   if(item['visibleIf'] != null){
      //     if(visibleIf(item) == true){
      //       add = true;
      //     }
      //   } if(item['enableIf'] != null){
      //     if(enableIf(item) == true){
      //       add = true;
      //     }
      //   }
      //   if(add == true){
      //     choices.add(item['value']);
      //   }
      // });

      String selectedChoice = '';
      return Visibility(
        visible: invisibilityList.contains(element['name']) ? false : true,
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            children: choices.map((choice) {
              return RadioListTile(
                title: Text(choice),
                value: choice,
                groupValue: selectedChoice,
                onChanged: (value) {
                  // setState(() {
                  //   selectedChoice = value;
                  // });
                },
              );
            }).toList(),
          ),
        ),
      );
    }

    Container container(Map<String, dynamic> element) {
      return Container();
    }

    Visibility filePicker(Map<String, dynamic> element) {
      TextEditingController _textEditingController = TextEditingController();
      printError(' **** ' + element['name']);
      return Visibility(
        // visible: visibleIf(element),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
          ),
          child: TextField(
            onTap: () async {
              //upload file
              String base64 = await getFile();
              widget.formResults.add(
                  element['name'],
                  {
                    'controller': element['name'],
                    'value': element['label'].toString(),
                    'label': element['label'],
                    'type': 'file',
                    'file': base64,
                    'extras': {}
                  },
                  notifyActivities: false);
              _textEditingController.text = path!;
            },
            readOnly: true,
            decoration: InputDecoration(
              hintText: element['title'],
              hintStyle: TextStyle(color: Colors.black),
              contentPadding: const EdgeInsets.all(16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: BorderSide(
                  width: 1.5,
                  color: Colors.grey,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(2),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.5,
                ),
              ),
            ),
            controller: _textEditingController,
            onChanged: (value) {},
          ),
        ),
      );
    }

    Visibility signaturePad(Map<String, dynamic> element) {
      return Visibility(
        visible: invisibilityList.contains(element['name']) ? false : true,
        child: SizedBox(
          height: 450,
          child: Stack(
            children: [
              Signature(
                key: const Key('signature'),
                controller: _controller,
                height: 450,
                backgroundColor: Colors.grey[300]!,
              ),
              Positioned(
                left: 10,
                right: 10,
                top: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _controller.clear();
                      },
                      icon: Icon(
                        Icons.clear,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        exportImage(element);
                      },
                      icon: Icon(
                        Icons.check,
                        color: Colors.black,
                      ),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      );
    }

    Visibility html(Map<String, dynamic> element) {
      printError(' **** ' + element['name']);
      return Visibility(
          // visible: visibleIf(element),
          child: Html(
        data: element['html'],
      ));
    }

    Visibility checkbox(Map<String, dynamic> element) {
      String selectedChoice = '';
      return Visibility(
        visible: invisibilityList.contains(element['name']) ? false : true,
        child: Column(
          children: [
            Wrap(
              children: [
                for (var choice in element['choices'])
                  ChoiceChip(
                    label: Text(choice),
                    selected: selectedChoice == choice ? true : false,
                    onSelected: (bool selected) {},
                  )
              ],
            ),
            Text("${element['title']}: $selectedChoice")
          ],
        ),
      );
    }

    Widget getElement(Map<String, dynamic> element) {
      switch (element['type']) {
        case 'text':
          return textField(element);

        case 'comment':
          return textField(element);

        case 'dropdown':
          return dropdownChoices(element);

        case 'genericquestion':
          return htmlText(element);

        case 'httplookup':
          return httpLookUp(element);

        case 'bsdatepicker':
          return datepicker(element);

        case 'radiogroup':
          return radiogroup(element);

        case 'file':
          return filePicker(element);

        case 'checkbox':
          return checkbox(element);

        case 'signaturepad':
          return signaturePad(element);

        case 'html':
          return html(element);
        case 'agecalc':
          return ageCalc(element);
        // case '':
        //   return aboutPage(httpRequest);
        //   break;
        default:
          return container(element);
      }
    }

    Widget checkElement(Map<String, dynamic> element) {
      if (element['type'] == 'panel') {
        Column children = Column(
          children: [
            for (var element in element['elements']) checkElement(element)
          ],
        );

        return Visibility(
          visible: !invisibilityList.contains(element['name']),
          child: Card(
            margin: const EdgeInsets.all(20),
            elevation: 1,
            child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Text(
                        element['title'] ?? '',
                        style: const TextStyle(
                          color: Color(0xff0f1728),
                          fontSize: 18,
                          fontFamily: "Inter",
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    children,
                  ],
                )),
          ),
        );
      } else {
        return getElement(element);
      }
    }

    Widget buildForm() {
      return ListView(
        children: [for (var element in widget.elements) checkElement(element)],
      );
    }

    visibleIf();
    return Center(
      child: buildForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return create();
  }
}

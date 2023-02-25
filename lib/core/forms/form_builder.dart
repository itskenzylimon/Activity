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

  /// invisibilityList is a list of elements that are invisible
  /// { ''key' : bool }
  /// key being the element name
  Map invisibilityMap = {};

  // Map representation of the formResults
  Map<String, Map<String, dynamic>> formValues = {};

  exportImage(element) async {
    final Uint8List? data =
        await _controller.toPngBytes(height: 1000, width: 1000);
    if (data == null) {
      return;
    } else {
      List<int> fileInByte = data;
      String fileInBase64 = base64Encode(fileInByte);
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
;    return fileInBase64;
  }

  //upload file
  Future<String> getFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return "";
    path = result.files.single.path!;
    return getBase64FormateFile(path!);
  }

  String getBase64FormateFile(String path) {
    File file = File(path);
    List<int> fileInByte = file.readAsBytesSync();
    String fileInBase64 = base64Encode(fileInByte);
    return fileInBase64;
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
      enabled = element['readOnly'];
    }


    if (element['enableIf'] != null) {
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

    printInfo(formValues.length.toString());

    formValues.forEach((key, value) {
      if (value['visible'] != null) {
        invisibilityMap.addAll({
          key: value['visible']
        });
      }

      else if (value['visibleIf'] != null) {

        printWarning( '$key --- ### --- ${value['visibleIf'] }');


        /// create a list of conditions
        /// Handle or conditions
        /// Handle and conditions
        List visibleIfConditions = splitStringList(value['visibleIf']);
        /// New Map for conditional bools
        Map newInvisibilityMap = {};
        /// loop through visibleIfConditions
        for (var condition in visibleIfConditions) {
          /// Handle anyof conditionType
          /// it should overwrite visible state from above
          if (condition.toString().contains(' anyof ')) {
            /// Here we handle the many conditions in the visibleIf that meet
            /// the anyof condition type
            if (formValues[trimCurly(condition)] != null) {
              // data found, now check if trimCurly is in getListString
              if(trimListString(condition).contains(trimCurly(condition))){
                newInvisibilityMap.addAll({
                  key: true
                });
              } else {
                newInvisibilityMap.addAll({
                  key: false
                });
              }
            }

          }

          /// Handle notempty conditions
          /// it should overwrite enabled state from above
          if (condition.toString().contains(' notempty ')) {
            /// Here we handle the many conditions in the visibleIf that meet
            /// the notempty condition type
            if (formValues[trimCurly(condition)] != null) {
              // check condition not empty
              if(formValues[trimCurly(condition)]!['value'].toString().isNotEmpty){
                newInvisibilityMap.addAll({
                  key: true
                });
              } else {
                newInvisibilityMap.addAll({
                  key: false
                });
              }
            }
          }

          /// Handle = conditions
          /// it should overwrite enabled state from above
          if (condition.toString().contains(' = ')) {
            /// Here we handle the many conditions in the visibleIf that meet
            /// the = condition type
            if (formValues[trimCurly(condition)] != null) {
              /// get condition value
              String value = conditionValue(condition);

              if(formValues[trimCurly(condition)]!['value'] == value){
                newInvisibilityMap.addAll({
                  key: true
                });
              } else {
                newInvisibilityMap.addAll({
                  key: false
                });
              }
            }
          }
        }
        
        /// Handle the and / or conditions state
        if(value['visibleIf'].toString().contains(' and ')){
          setState(() {
            invisibilityMap.addAll({
              key: newInvisibilityMap.containsValue(false)
            });
          });
        }
        else if (value['visibleIf'].toString().contains(' or ')){
          setState(() {
            invisibilityMap.addAll({
              key: newInvisibilityMap.containsValue(true)
            });
          });
        }
      }

    });
  }

  /// All updates should be done here
  /// This is called when a form element is changed
  /// It updates the formValues map
  updateElement(String name, Map<String, dynamic> value){
    /// Update formResults
    if(widget.formResults.containsKey(name)){
      setState(() {
        widget.formResults.remove(name, notifyActivities: false);
        widget.formResults.add(name, value, notifyActivities: false);
      });
    }
    /// Update formValues
    if(formValues.containsKey(name)){
      setState(() {
        formValues.remove(name);
        formValues.addAll({name: value});
      });
    }
    /// Call visibleIf condition
    visibleIf();
    /// Call requiredIf condition

    /// Call enableIf condition
  }

  /// All created elements should be added here
  /// This is called when a form element is created
  /// It updates the formValues map and formResults map
  Map<String, dynamic> setUpElement(String name, Map<String, dynamic> value){
    /// Update formValues
    if(formValues.containsKey(name)){
      setState(() {
        formValues.remove(name);
        formValues.addAll({name: value});
        /// Update formResults
        widget.formResults.remove(name, notifyActivities: false);
        widget.formResults.add(name, value, notifyActivities: false);
      });
    }
    return value;
  }

  Center create() {
    // Key / value for the form
    TextEditingController textCont = TextEditingController();
    // assign formResults to formValues.

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
      ActiveResponse userDataRes =
          await activeRequest.getApi(Params(endpoint: url, queryParameters: {
        '': "",
      }));

      if (userDataRes.statusCode == 200) {
        var data = json.decode(userDataRes.data!);
        var filteredList = data
            .where((elem) =>
                elem['value'].toString().toLowerCase().contains(query.toLowerCase()) ||
                elem['text'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
        list = filteredList.toSet().toList();
      } else {
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
          for (var i = 0; i < data.length; i++) {
            listData.add(data[i]);
          }
        }
        var filteredList = listData
            .where((elem) => elem['value'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
        list = filteredList.toSet().toList();
      } else {
      }
      return list;
    }

    String _textSelect(String str) {
      str = str.replaceAll('<<', '');
      str = str.replaceAll('>>', '');
      str = str.replaceAll('result.', '');
      str = str.replaceAll(' ', '');
      return str;
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

    Future<Map<String, dynamic>> choicesByUrl(Map choicesByUrl) async {
      Map<String, dynamic> choices = await formRequest(choicesByUrl);
      return choices;
    }

    Future<Map<String, dynamic>> httpLookUpUrl(Map choicesByUrl) async {

      Map<String, dynamic> choices = await formRequest(choicesByUrl);
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

      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': textEditingController.text,
      }..addAll(element);

      var data = setUpElement(element['name'], newElement);

      /// return the widget to be displayed
      return Visibility(
        visible: invisibilityMap[element['name']] ?? true,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
          child: Center(
            child: TextFormField(
              controller: textEditingController,
              keyboardType: checkInputType(element),
              key: textFieldKey,
              readOnly: !enableIf(element),
              maxLines: element['type'] == 'comment' ? 5 : 1,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                 isDense: true,
                hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffE0E0E0)),
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

                element['value'] = value;
                /// call updateElement
                updateElement(element['name'], element);

              },
            ),
          ),
        ),
      );
    }

    Visibility textFieldIPRS(Map<String, dynamic> element, value) {
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
        visible: invisibilityMap[element['name']] ?? true,
        child:Container(
          margin: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
          child:
         TextFormField(
          controller:
              widget.formResults['$value-${element['name']}']!['controller'],
          keyboardType: checkInputType(element),
          key: textFieldKey,
          // readOnly: enableIf(element),
          maxLines: element['type'] == 'comment' ? 5 : 1,
                 style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                 isDense: true,
                hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffE0E0E0)),
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
          },
        ),
        )
      );
    }

    Visibility dropdownChoices(Map<String, dynamic> element) {
      Key dropdownKey = Key(element['name']);
      Key key = Key("123");
      String? currentSelectedValue = 'Select ${element['title']}';

      ValueNotifier<List<String>> _listNotifier =
          ValueNotifier<List<String>>(["Select ${element['title']}"]);
      ValueNotifier<List<String>> _choicesNotifier =
          ValueNotifier<List<String>>(["Select ${element['title']}"]);
      List<String> choiceList = [..._listNotifier.value];
      List<String> choicesbyurl = [..._choicesNotifier.value];

      /// Add to the widget.formResults
      if (widget.formResults.containsKey(element['name']) == false) {

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
        formValues['${element['name']}'] = widget.formResults[element['name']]!;
      }

      String vl = formValues[element['name']]!['value'] ?? "";
      if (element['renderAs'] != null && element['renderAs'] == 'select2') {
        return Visibility(
            // visible: visibleIf(element),
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10,right:16,left:16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey,width: 0.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                 decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.0),width: 0.0),
              borderRadius: BorderRadius.zero,
          ),
                child: TextField(
                style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
                 decoration: InputDecoration(
                 isDense: true,
                hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffE0E0E0)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.0),
                enabledBorder: UnderlineInputBorder(
                    borderSide:  BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 0.0),
                    borderRadius: BorderRadius.zero),
                focusedBorder: UnderlineInputBorder(
                    borderRadius:
                    BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.blue,)),
                labelText: 'Search',

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
                                  choiceList.clear();
                                  choiceList.add(textCont.text);
                                  _listNotifier.notifyListeners();
                                },
                                title: Text(choiceList[index],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                )
                              ),
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
      }
      else if (element['renderAs'] == null && element['choicesByUrl'] != null) {
        return Visibility(
            // visible: visibleIf(element),
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10, right: 16, left:16),
              decoration: BoxDecoration(
            border: Border.all(color: Colors.grey,width: 0.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
              decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withOpacity(0.0),width: 0.0),
              borderRadius: BorderRadius.zero,
            ),
                child: TextField(
                style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
                 decoration: InputDecoration(
                 isDense: true,
                hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xffE0E0E0)),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.0),
                enabledBorder: UnderlineInputBorder(
                    borderSide:  BorderSide(
                        color: Colors.grey.withOpacity(0.5), width: 0.0),
                    borderRadius: BorderRadius.zero),
                focusedBorder: UnderlineInputBorder(
                    borderRadius:
                    BorderRadius.zero,
                    borderSide: BorderSide(color: Colors.blue,)),
                labelText: 'Search',

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
                                title: Text(choicesbyurl[index],
                                     style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                )),
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
      }
      else {
        return Visibility(
          visible: invisibilityMap[element['name']] ?? true,
          child:
          Container(
            height: 48.0,
            margin: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
            alignment: Alignment.center,
            child:  DropdownButtonFormField(
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
                hint: Text(
                    element['title'] + ' ' + (element['description'] ?? '')),
                value: formValues[element['name']]!['value'],
                items: choices,
                onChanged: (value) {
                  widget.formResults.remove(element['name'], notifyActivities: false);
                  widget.formResults.add(
                      element['name'],
                      {
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
          )
        );
      }
    }

    Visibility dropdownChoicesIPRS(Map<String, dynamic> element, valueItem) {
      var labelText = valueItem;

      Key dropdownKey = Key('$labelText-${element['name']}');

      /// Add to the widget.formResults
      if (widget.formResults.containsKey('$labelText-${element['name']}') ==
          false) {
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
            widget.formResults['$labelText-${element['name']}']!;
      }

      String vl = formValues['$labelText-${element['name']}']!['value'];

      return Visibility(
        visible: invisibilityMap[element['name']] ?? true,
        child: Container(
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
          // SizedBox(
          //   height: 20,
          // ),
          // Text(
          //   "$labelText",
          //   style: TextStyle(color: Colors.black, fontSize: 18),
          // ),
          // SizedBox(
          //   height: 10,
          // ),
          // TextFormField(
          //   keyboardType: checkInputType(element),
          //   key: textFieldKey,
          //   readOnly: enableIf(element),
          //   decoration: InputDecoration(
          //     labelText: labelText,
          //     hintText: element['placeholder'] ?? '',
          //   ),
          //   validator: (value) {},
          //   onChanged: (value) {
          //     widget.formResults.remove(element['name'], notifyActivities: false);
          //     widget.formResults.add(
          //         element['name'],
          //         {
          //           'controller': agecalcEditingController,
          //           'value': value,
          //           'label': labelText,
          //           'type': 'agecalc',
          //           'extras': {}
          //         },
          //         notifyActivities: false);
          //   },
          // ),
        ]),
      );
    }

    Visibility htmlText(Map<String, dynamic> element) {
      return Visibility(
          visible: invisibilityMap[element['name']] ?? true,
          child: Html(
            data: element['displayTemplate'],
          ));
    }

    Visibility httpLookUp(Map<String, dynamic> element) {
      // httpLookUpUrl(element);

      /// after loading update the data forms
      return Visibility(
          visible: invisibilityMap[element['name']] ?? true,
          child: SizedBox(
        height: 270,
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: element['lookup'].length,
            itemBuilder: (BuildContext context, int index) {
              final item = element['lookup'][index];
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
                        final parameters = item['parameters'][index];
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
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16), child:                   OutlinedButton(
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
                  ),)
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
        child: Container(
          margin: EdgeInsets.only(top:8,bottom: 16,right:16,left:16),
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
                focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.blue,)),
                hintText: element['title'] ?? '',
              ),
          controller: _textEditingController,
          onChanged: (value) {},
        ),
        )


      );
    }

    Visibility radioGroup(Map<String, dynamic> element) {
      List choices = [];

      String selectedChoice = '';
      for (var i = 0; i < element['choices'].length; i++) {
        choices.add(element['choices'][i]);
      }
      if (widget.formResults.containsKey('${element['name']}')) {
        selectedChoice = widget.formResults['${element['name']}']!['value'] ?? '';
        printError(selectedChoice);
        widget.formResults.update(
            '${element['name']}',
                (value) => {
              'value': selectedChoice,
              'label': element['title'],
              'type': 'text',
              'extras': {}
            },
            notifyActivities: false);
      }
      else {

        widget.formResults.add(
            '${element['name']}',
            {
              'value': element['choices'][0],
              'label': element['title'],
              'type': 'text',
              'extras': {}
            },
            notifyActivities: false);

        selectedChoice =
            widget.formResults['${element['name']}']!['value'] ?? '';
      }
      return Visibility(
        visible: invisibilityMap[element['name']] ?? true,
        child: Container(
          margin: const EdgeInsets.only(top: 8, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                element['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                element['isRequired'] ? '(Required)' : '(Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Column(
                children: choices.map((choice) {
                  return RadioListTile(
                    title: Text(choice),
                    value: choice,
                    groupValue: selectedChoice,
                    onChanged: (val) {
                      print("Radio Tile pressed $val");
                      print(val);
                      setState(() {
                        selectedChoice = val;
                        printSuccess(selectedChoice);
                        widget.formResults.update(
                            '${element['name']}',
                                (value) => {
                              'value': selectedChoice,
                              'label': element['title'],
                              'type': 'text',
                              'extras': {}
                            },
                            notifyActivities: false);
                      });

                    },

                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }

    Container container(Map<String, dynamic> element) {
      return Container();
    }

    Visibility filePicker(Map<String, dynamic> element) {
      TextEditingController _textEditingController = TextEditingController();
      return Visibility(
        // visible: visibleIf(element),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8, bottom:8,right:16, left:16
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
                focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide(color: Colors.blue,)),
                hintText: element['title'] ?? '',
              ),
            controller: _textEditingController,
            onChanged: (value) {},
          ),
        ),
      );
    }

    Visibility signaturePad(Map<String, dynamic> element) {
      return Visibility(
        visible: invisibilityMap[element['name']] ?? true,
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
      return
      Visibility(
          // visible: visibleIf(element),
          child:
           Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Html(
                  data: element['html'],
                ))
           )
;
    }

    Visibility checkbox(Map<String, dynamic> element) {
      printSuccess('CHECKBOX ???');
      printSuccess('${element['name']}');
      List choices = [];
      var selectedCheck = false;

      for (var i = 0; i < element['choices'].length; i++) {
        choices.add(element['choices'][i]);
      }

      if (widget.formResults.containsKey('${element['name']}')) {
        printWarning('Selected CheckBox');
        printWarning(widget.formResults['${element['name']}']);
        printWarning(widget.formResults['${element['name']}']!['value']);
        selectedCheck = widget.formResults['${element['name']}']!['value'];
        widget.formResults.update(
            '${element['name']}',
                (value) => {
              'value': selectedCheck,
              'label': element['title'],
              'type': 'text',
              'extras': {}
            },
            notifyActivities: false);
      }
      else {
        widget.formResults.add(
            '${element['name']}',
            {
              'value': selectedCheck,
              'label': element['title'],
              'type': 'text',
              'extras': {}
            },
            notifyActivities: false);


      }
      return Visibility(
        visible: invisibilityMap[element['name']] ?? true,
        child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                element['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Column(
                children: choices.map((choice) {
                  return Row(
                    children: <Widget>[
                      SizedBox(
                        width: 10,
                      ),
                      /** Checkbox Widget **/
                      Checkbox(
                        value: selectedCheck,
                        onChanged: (value) {
                          setState(() {
                            selectedCheck = value!;
                            printSuccess("STATE CHECKED");
                            printWarning(value);
                            printWarning(selectedCheck);
                            widget.formResults.remove('${element['name']}', notifyActivities: false);
                            widget.formResults.add(
                                '${element['name']}',
                                {
                                  'value': selectedCheck,
                                  'label': element['title'],
                                  'type': 'text',
                                  'extras': {}
                                },
                                notifyActivities: false);
                            printWarning(widget.formResults['${element['name']}']);
                          });
                        },
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$choice',
                          style: TextStyle(fontSize: 16),
                          softWrap: false,
                          maxLines: 2,
                        ),
                      ), //Text

                    ], //<Widget>[]
                  ); //Row
                }).toList(),
              ),
            ],
          ),
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
          return radioGroup(element);

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
          visible: invisibilityMap[element['name']] ?? true,
          child:  Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 2,left: 16,right: 16),
                      child: Text(
                        element['title'] ?? '',
                        style: const TextStyle(
                          color: Color(0xff0f1728),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    children,
                  ],
                )),

        );
      } else {
        return getElement(element);
      }
    }

    Widget buildForm() {

      Map<String, Map<String, dynamic>> formData = {};
      for (Map<String, dynamic> element in widget.elements) {
        formData.addAll({element['name']: element});
      }

      printError('{{{{formData}}}}');
      printError('{{{{ ${formData.length} }}}}');
      printError('{{{{formData}}}}');

      setState(() {
        formValues = formData;
      });

      visibleIf();

      return ListView(
        children: [for (var element in widget.elements) checkElement(element)],
      );
    }

    return Center(
      child: buildForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return create();
  }
}

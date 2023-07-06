import 'dart:async';
import 'dart:convert';

import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import '../../widgets/customWidgets/dropdown.dart';
import '../../widgets/customWidgets/textfield.dart';
import 'form_controller.dart';

class SurveyJSForm extends StatefulWidget {
  final Map schema;
  final Map<String, dynamic> defaultValues;
  final Map<String, Map<String, dynamic>> formResults;
  final BuildContext context;
  final ValueChanged<Map<String, dynamic>> onFormValueSubmit;

  const SurveyJSForm({
    super.key,
    required this.schema,
    required this.defaultValues,
    required this.context,
    required this.formResults,
    required this.onFormValueSubmit,
  });

  @override
  State<SurveyJSForm> createState() => _SurveyJSFormState();
}

class _SurveyJSFormState extends State<SurveyJSForm> {
  /// All themes map
  List<Map<String, dynamic>> themeStyle = [];

  // Map<String, SampleWidget> customWidgets(){
  //  return {
  //
  //  };
  // }

  /// Theme map
  // Map<String, dynamic> metaData = {
  //   'theme': {
  //     'theme': {
  //       'primaryColor': Colors.teal,
  //       'secondaryColor': Colors.teal,
  //     },
  //     'textfield': {
  //       'showCursor': true,
  //     },
  //     'button': {
  //       'type': 'outline'
  //
  //       /// outline, filled
  //     },
  //   },
  //   'customWidgets': {'elementName': SampleWidget}
  // };

  List<GlobalKey<FormState>> listGlobalKey = [];

  int initialIndex = 0;

  List pages = [];
  List pagesListData = [];
  List<Widget> pageList = [];
  List<Widget> tabList = [];

  List<List<String>> dataKeyList = [];
  List<String> dataKeys = [];

  late Timer debounce;

  bool showDialogContainer = false;
  bool showDialogConfirmation = false;
  List<List> pageValues = [];
  List<String> pageTitles = [];

  String? path;

  Map<String, Map<String, dynamic>> valueFormResults = {};

  @override
  void initState() {
    super.initState();

    pages =
        widget.schema['pages'] ?? widget.schema['service']['schema']['pages'];
    for (var page in pages) {
      dataKeyList.add(page);
    }
    // metaData.putIfAbsent('customWidgets', () => customWidgets());
  }

  Widget formBuilderController(page) {
    // assign formResults to formValues.
    Visibility dropdownChoices(Map<String, dynamic> element) {

      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], element);

      return Visibility(
          child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: DropdownWidget(
          key: Key(element['name']),
          value: 'Select Option',
          items: const [DropdownMenuItem(value: 'Select Option', child: Text('Select Option'))],
          onChanged: (String value) {
            setState(() {
              Map<String, Map<String, dynamic>> newValueFormResults =
                  valueFormResults;
              newValueFormResults[element['name']] = {'value': value};
              newElement['value'] = value;
              newValueFormResults[element['name']] = newElement;
              valueFormResults = newValueFormResults;
            });
          },
          leadIcon: Icons.arrow_drop_down,
        ),
      ));
    }

    // Visibility datePicker(Map<String, dynamic> element) {
    //   /// call setUpElement
    //   Map<String, dynamic> newElement = {
    //     'value': '',
    //   }..addAll(element);
    //
    //   /// After setting up the element, add it to the elementData
    //   /// use elementData in the rest of the function
    //   setUpElement(element['name'], newElement);
    //
    //   return Visibility(
    //       visible: valueFormResults[element['name']]!['visible'],
    //       child: DatePickerWidget(
    //         onElementCallback: (Map<String, dynamic> value) {
    //           setState(() {
    //             Map<String, Map<String, dynamic>> newValueFormResults =
    //                 valueFormResults;
    //             newValueFormResults[element['name']] = value;
    //             valueFormResults = newValueFormResults;
    //           });
    //         },
    //         elementName: element['name'],
    //         valueFormResults: valueFormResults,
    //         customTheme: metaData['theme'],
    //       ));
    // }

    // Visibility radioGroup(Map<String, dynamic> element) {
    //   /// call setUpElement
    //   Map<String, dynamic> newElement = {
    //     'value': '',
    //   }..addAll(element);
    //
    //   // print("???? ELEMENT");
    //   // print(element);
    //   /// After setting up the element, add it to the elementData
    //   /// use elementData in the rest of the function
    //   setUpElement(element['name'], newElement);
    //
    //   return Visibility(
    //       child: RadioGroupWidget(
    //     onElementCallback: (Map<String, dynamic> value) {
    //       setState(() {
    //         Map<String, Map<String, dynamic>> newValueFormResults =
    //             valueFormResults;
    //         newValueFormResults[element['name']] = value;
    //         valueFormResults = newValueFormResults;
    //       });
    //     },
    //     elementName: element['name'],
    //     valueFormResults: valueFormResults,
    //   ));
    // }
    //
    // Visibility filePicker(Map<String, dynamic> element) {
    //   /// call setUpElement
    //   Map<String, dynamic> newElement = {
    //     'value': '',
    //   }..addAll(element);
    //
    //   /// After setting up the element, add it to the elementData
    //   /// use elementData in the rest of the function
    //   setUpElement(element['name'], newElement);
    //
    //   return Visibility(child: Container());
    // }
    //
    // Visibility checkbox(Map<String, dynamic> element) {
    //   /// call setUpElement
    //   Map<String, dynamic> newElement = {
    //     'value': '',
    //   }..addAll(element);
    //
    //   /// After setting up the element, add it to the elementData
    //   /// use elementData in the rest of the function
    //   setUpElement(element['name'], newElement);
    //
    //   // print("newElement-------------------------------->");
    //   // print(newElement);
    //
    //   return Visibility(
    //       child: Padding(
    //     padding: const EdgeInsets.only(left: 16, right: 16),
    //     child: CheckBoxWidget(
    //       onElementCallback: (Map<String, dynamic> value) {
    //         setState(() {
    //           Map<String, Map<String, dynamic>> newValueFormResults =
    //               valueFormResults;
    //           newValueFormResults[element['name']] = value;
    //           valueFormResults = newValueFormResults;
    //         });
    //       },
    //       elementName: element['name'],
    //       valueFormResults: valueFormResults,
    //       customTheme: metaData['theme'],
    //     ),
    //   ));
    // }
    //
    // Visibility signaturePad(Map<String, dynamic> element) {
    //   /// call setUpElement
    //   Map<String, dynamic> newElement = {
    //     'value': '',
    //   }..addAll(element);
    //
    //   /// After setting up the element, add it to the elementData
    //   /// use elementData in the rest of the function
    //   setUpElement(element['name'], newElement);
    //
    //   return Visibility(
    //       child: SignatureFieldWidget(
    //     onElementCallback: (Map<String, dynamic> value) {
    //       setState(() {
    //         Map<String, Map<String, dynamic>> newValueFormResults =
    //             valueFormResults;
    //         newValueFormResults[element['name']] = value;
    //         valueFormResults = newValueFormResults;
    //       });
    //     },
    //     elementName: element['name'],
    //     valueFormResults: valueFormResults,
    //     customTheme: metaData['theme'],
    //   ));
    // }
    //
    Visibility container(Map<String, dynamic> element) {
      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);

      return Visibility(
          visible: valueFormResults[element['name']]!['visible'],
          child: Container(
            padding: const EdgeInsets.all(10),
          ));
    }

    Visibility textField(Map<String, dynamic> element) {
      TextEditingController textEditingController = TextEditingController();

      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': textEditingController.text,
        'controller': textEditingController,
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);
      textEditingController.text = newElement['value'] ?? '';

      return Visibility(
          visible: valueFormResults[element['name']]!['visible'],
          child: textFieldWidget(
            key: Key(element['name']),
            controller: textEditingController,
            onChanged: (String value) {
              setState(() {
                Map<String, Map<String, dynamic>> newValueFormResults =
                    valueFormResults;
                newElement['value'] = value;
                textEditingController.text = value;
                newValueFormResults[element['name']] = newElement;
                valueFormResults = newValueFormResults;
              });
            }
          ));
    }

    // Visibility textSearchUpdateField(Map<String, dynamic> element) {
    //   TextEditingController textEditingController = TextEditingController();
    //
    //   /// call setUpElement
    //   Map<String, dynamic> newElement = {
    //     'value': textEditingController.text,
    //     'controller': textEditingController,
    //   }..addAll(element);
    //
    //   /// After setting up the element, add it to the elementData
    //   /// use elementData in the rest of the function
    //   setUpElement(element['name'], newElement);
    //
    //   return Visibility(
    //       visible: valueFormResults[element['name']]!['visible'],
    //       child: TextFieldWidget(
    //         onElementCallback: (Map<String, dynamic> value) {
    //           setState(() {
    //             Map<String, Map<String, dynamic>> newValueFormResults =
    //                 valueFormResults;
    //             newValueFormResults[element['name']] = value;
    //             valueFormResults = newValueFormResults;
    //           });
    //         },
    //         elementName: element['name'],
    //         valueFormResults: valueFormResults,
    //         customTheme: metaData['theme'],
    //       ));
    // }
    //
    Visibility customWidget(Map<String, dynamic> element) {
      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);

      // if(metaData['customWidgets'].containsKey(element['name'])){
      //   print('customWidget');
      // CustomWidget customWidget = metaData['customWidgets'][element['name']]!;
      // customWidget.elementName = element['name'];
      // customWidget.valueFormResults = valueFormResults;
      // customWidget.onFormCallback = (Map<String, dynamic> value) {
      //   if (kDebugMode) {
      //     print('customWidget.onElementCallback');
      //   }
      //   Map<String, Map<String, dynamic>> newValueFormResults = valueFormResults;
      //   value.forEach((key, value) {
      //     if(newValueFormResults.containsKey(key)){
      //       newValueFormResults[key]!['value'] = value[key];
      //     }
      //   });
      //   setState(() {
      //     valueFormResults = newValueFormResults;
      //   });
      // };
      // customWidget.onElementCallback = (Map<String, dynamic> value) {
      //   if (kDebugMode) {
      //     print('customWidget.onElementCallback');
      //   }
      //   Map<String, Map<String, dynamic>> newValueFormResults = valueFormResults;
      //   newValueFormResults[element['name']] = value..addAll(newElement);
      //   setState(() {
      //     valueFormResults = newValueFormResults;
      //   });
      // };
      //   return Visibility(
      //       visible: valueFormResults[element['name']]!['visible'],
      //       child:
      //       CustomWidget(
      //         elementName: element['name'],
      //         valueFormResults: valueFormResults,
      //         customTheme: metaData['theme'],
      //         widgetData: metaData['customWidgets'][element['name']]!
      //       )
      //   );
      // } else {
      return Visibility(
          visible: valueFormResults[element['name']]!['visible'],
          child: Container());
      // }
    }

    Widget getElement(Map<String, dynamic> element) {
      switch (element['type']) {
        case 'text':
          return textField(element);

        // case 'textsearchupdatefield':
        //   return textSearchUpdateField(element);
        //
        // case 'comment':
        //   return textField(element);

        case 'dropdown':
          return dropdownChoices(element);

        // case 'bsdatepicker':
        //   return datePicker(element);
        //
        //
        // case 'radiogroup':
        //   return radioGroup(element);
        //
        // case 'file':
        //   return filePicker(element);
        //
        // case 'checkbox':
        //   return checkbox(element);
        //
        // case 'signaturepad':
        //   return signaturePad(element);
        //
        // case 'container':
        //   return container(element);
        //
        default:
          return customWidget(element);
      }
    }

    Widget checkElement(Map<String, dynamic> element) {
      List<List> result = [];
      List temp = [];
      // printError( element['elements']);
      if (element['elements'] == null) {
        // printError( element['elements']);
      } else {
        for (Map char in element['elements']) {
          if (char["startWithNewLine"] == null) {
            if (temp.isNotEmpty) {
              result.add(temp);
            }
            temp = [char];
          } else {
            temp.add(char);
          }
        }
        if (temp.isNotEmpty) {
          result.add(temp);
        }
      }

      // printSuccess('{{{{{{{{{panelresult}}}}}}}}}');
      // printSuccess(result);
      // printSuccess(result[0].length);
      // printSuccess(result.length);
      // printSuccess('{{{{{{{{{{{{panelresult}}}}}}}}}}}}');

      if (element['type'] == 'panel') {
        /// After setting up the element, add it to the elementData
        /// use elementData in the rest of the function
        setUpElement(element['name'], element);

        // visibleMap.add(element['name'], true);

        Column children = Column(
          children: [
            for (List rowElements in result)
              rowElements.length >= 2
                  ? Row(
                      children: [
                        for (var element in rowElements)
                          Expanded(child: checkElement(element))
                      ],
                    )
                  : checkElement(rowElements[0])
          ],
        );

        return Visibility(
          visible: valueFormResults[element['name']]!['visible'] ?? true,
          child: Card(
            margin: const EdgeInsets.all(20),
            elevation: 4,
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

    ListView buildForm() {
      // List<Widget> children = [];
      // List<Widget> rowChildren = [];
      // List fields = page['elements'];

      /// Three columns in a row
      // for(var element in fields){
      //   if(rowChildren.isEmpty){
      //     rowChildren.add(
      //         checkElement(element)
      //     );
      //   } else {
      //     rowChildren.add(checkElement(element));
      //     children.add(Row(
      //       children: [
      //         for (var element in rowChildren)
      //           element
      //       ],
      //     ));
      //     printError('rowChildren: $rowChildren');
      //     printError('children: ${children}');
      //     rowChildren.clear();
      //   }
      // }

      List<List> result = [];
      List temp = [];
      for (Map char in page['elements']) {
        if (char["startWithNewLine"] == null) {
          if (temp.isNotEmpty) {
            result.add(temp);
          }
          temp = [char];
        } else {
          temp.add(char);
        }
      }
      if (temp.isNotEmpty) {
        result.add(temp);
      }

      // printSuccess('{{{{{{{{{result}}}}}}}}}');
      // printSuccess(result);
      // printSuccess(result[0].length);
      // printSuccess(result.length);
      // printSuccess('{{{{{{{{{{{{result}}}}}}}}}}}}');

      ListView listView = ListView(
        children: [
          for (List rowElements in result)
            rowElements.length >= 2
                ? Row(
                    children: [
                      for (var element in rowElements)
                        Expanded(child: checkElement(element))
                    ],
                  )
                : checkElement(rowElements[0])
        ],
      );

      return listView;
    }

    /// After setting up the element, add it to the elementData
    /// use elementData in the rest of the function
    setUpElement(page['name'], {
      'visible': true,
      'name': page['name'],
    });

    return Visibility(
        visible: valueFormResults[page['name']]!['visible'] ?? true,
        child: buildForm());
  }

  setUpTabview() {
    /// After setting up the element, add it to the elementData
    /// use elementData in the rest of the function

    tabList.clear();
    pageList.clear();
    pagesListData.clear();

    var lst = {};
    for (var page in pages) {
      // printWarning( '${page['name']} --- *** ---');
      setUpElement(page['name'], {
        'name': page['name'],
        'visibleIf': page['visibleIf'],
      });
      // if(page['visibleIf'] == false){
      //   visibleIf();
      // }
      int index = pages.indexOf(page);
      GlobalKey<FormState> key = GlobalKey<FormState>();
      listGlobalKey.add(key);

      // page.removeWhere((item) => item['visibleIf'] == true);

      pageList.add(Visibility(
          visible: valueFormResults[page['name']]!['visible'] ?? true,
          child: Form(
              key: listGlobalKey[index], child: formBuilderController(page))));
      lst = {
        "name": valueFormResults[page['name']],
        "visibility": valueFormResults[page['name']]!['visible'] ?? true
      };
      pagesListData.add(lst);

      visibleIf();

      // printSuccess('{{{{valueFormResults[page[]]}}}}');
      // printSuccess(valueFormResults[page['name']]);
      // printSuccess('{{{valueFormResults[page[]]}}}');
      tabList.add(Visibility(
        visible: valueFormResults[page['name']]!['visible'] ?? false,
        replacement: const SizedBox(),
        child: Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: initialIndex == index
                ? const Border(bottom: BorderSide(width: 1))
                : null,
            color: initialIndex == index
                ? Colors.grey.withOpacity(0.05)
                : Colors.grey.withOpacity(0.02),
          ),
          child: Text(
            page['title'],
            style: TextStyle(
              fontSize: 11,
              color: initialIndex == index ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      ));
    }
  }

  /// Extend the custom widget functions

  @override
  Widget build(BuildContext context) {
    // printWarning('{{{tabList}}}');
    // printSuccess(tabList);

    visibleIf();
    isRequiredIf();
    enableIf();

    setUpTabview();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale!.languageCode &&
              locale.countryCode == deviceLocale.countryCode) {
            return deviceLocale;
          }
        }
        return supportedLocales.first;
      },
      debugShowCheckedModeBanner: false,
      home: Activity(
        FormController(),
        onActivityStateChanged: () =>
            DateTime.now().microsecondsSinceEpoch.toString(),
        child: Stack(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tabList,
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: pageList[initialIndex],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      border: Border(
                        top: BorderSide(
                            width: 1.0, color: Colors.grey.withOpacity(0.3)),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 16, top: 8, bottom: 8, left: 16),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Visibility(
                              visible: initialIndex == 0 ? false : true,
                              child: Previous(
                                context: context,
                                onPrevious: () {
                                  for (var i = 0;
                                      i <= pagesListData.length;
                                      i++) {
                                    if (initialIndex > 0) {
                                      if (pagesListData[initialIndex - 1]
                                          ['visibility']) {
                                        GlobalKey<FormState> formKey =
                                            listGlobalKey[initialIndex];
                                        if (formKey.currentState!.validate()) {
                                          setState(() {
                                            initialIndex = initialIndex - 1;
                                          });
                                        }
                                        break;
                                      } else {
                                        if (initialIndex > 0) {
                                          GlobalKey<FormState> formKey =
                                              listGlobalKey[initialIndex];
                                          if (formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              initialIndex = initialIndex - 2;
                                            });
                                          }
                                        }
                                        break;
                                      }
                                    }
                                  }
                                },
                                formKey: GlobalKey(),
                              ),
                            ),
                            const Spacer(),
                            (initialIndex + 2) > pagesListData.length
                                ? SubmitButton(
                                    context: context,
                                    formKey: GlobalKey(),
                                    onFormSubmit: () {
                                      showConfirmDialog();
                                    },
                                  )
                                : Next(
                                    context: context,
                                    onNext: () {
                                      for (var i = 0;
                                          i <= pagesListData.length;
                                          i++) {
                                        if (initialIndex <
                                            pagesListData.length - 1) {
                                          if (pagesListData[initialIndex + 1]
                                              ['visibility']) {
                                            GlobalKey<FormState> formKey =
                                                listGlobalKey[initialIndex];
                                            if (formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                initialIndex = initialIndex + 1;
                                              });
                                            }
                                            break;
                                          } else {
                                            if (initialIndex <
                                                pagesListData.length - 1) {
                                              GlobalKey<FormState> formKey =
                                                  listGlobalKey[initialIndex];
                                              if (formKey.currentState!
                                                  .validate()) {
                                                setState(() {
                                                  initialIndex =
                                                      initialIndex + 2;
                                                });
                                              }
                                            }
                                            break;
                                          }
                                        }
                                      }
                                    },
                                    formKey: GlobalKey(),
                                  )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            showDialogContainer == true
                ? Container(
                    margin:
                        const EdgeInsets.only(bottom: 80, right: 20, left: 20),
                    child: Container(
                        margin: const EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xffE3E5EE)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView(
                                children: [
                                  for (int x = 0; x < pageTitles.length; x++)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 18, top: 15),
                                          child: Text(
                                            pageTitles[x],
                                            style: const TextStyle(
                                              color: Color(0xff111827),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        const Divider(
                                          thickness: 1.0,
                                          height: 1,
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        for (int y = 0;
                                            y < pageValues[x].length;
                                            y++)
                                          SizedBox(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 26,
                                                            right: 26),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          pageValues[x][y]
                                                              ['name'],
                                                          style:
                                                              const TextStyle(
                                                            color: Color(
                                                                0xff6B7280),
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        pageValues[x][y]['value']
                                                                        .runtimeType ==
                                                                    String &&
                                                                pageValues[x][y]['value']
                                                                        .toString()
                                                                        .length >
                                                                    100 &&
                                                                FormController().base64RegExp(
                                                                    pageValues[x][y][
                                                                        'value'])
                                                            ? SizedBox(
                                                                height: 250,
                                                                width: 250,
                                                                child: Image.memory(
                                                                    const Base64Decoder()
                                                                        .convert(pageValues[x][y]['value'])))
                                                            : Text(
                                                                pageValues[x][y]
                                                                        [
                                                                        'value']
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                  color: Color(
                                                                      0xff111827),
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 8,
                                                      top: 8,
                                                      left: 26,
                                                      right: 26),
                                                  child: Divider(
                                                    thickness: 1.0,
                                                    height: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                      ],
                                    )
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showDialogContainer = false;
                                      showDialogConfirmation = false;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 148,
                                        height: 44,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showDialogContainer = false;
                                            });
                                          },
                                          child: Container(
                                            height: 44,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color(
                                                        0xffD0D5DD)),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: const Center(
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            showDialogConfirmation = true;
                                          });
                                        },
                                        child: Container(
                                          height: 44,
                                          width: 148,
                                          decoration: BoxDecoration(
                                              color: const Color(0xff006FFF),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: const Center(
                                            child: Text(
                                              'Complete',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  )
                : const SizedBox(),
            showDialogConfirmation == true
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        height: 250,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        margin: const EdgeInsets.only(left: 50, right: 50),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: const Color(0xffeaf3ff),
                                      width: 10,
                                    ),
                                    color: const Color(0xffc6dfff),
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.circle_outlined,
                                          color: Colors.blue,
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showDialogConfirmation = false;
                                      });
                                    },
                                    child: const Icon(Icons.clear))
                              ],
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            const Text(
                              'Complete Application',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            const Text(
                              'Are you sure you want to complete this application?',
                              style: TextStyle(
                                color: Color(0xff475467),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showDialogConfirmation = false;
                                      });
                                    },
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0xffD0D5DD)),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Center(
                                        child: Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: GestureDetector(
                                    onTap: () {
                                      widget
                                          .onFormValueSubmit(valueFormResults);
                                      setState(() {
                                        showDialogConfirmation = false;
                                        showDialogContainer = false;
                                      });
                                    },
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                          color: const Color(0xff006FFF),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: const Center(
                                        child: Text(
                                          'Complete',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  setVisibleKeys(String name, bool visible) {
    if (!dataKeys.contains(name) && visible == true) {
      dataKeys.add(name);
    } else if (dataKeys.contains(name) && visible == false) {
      dataKeys.remove(name);
    }
  }

  loopThroughElements(List elements, String name, bool visible) {
    setVisibleKeys(name, visible);
    for (var element in elements) {
      if (element['elements'] != null) {
        loopThroughElements(element['elements'], element['name'], visible);
      } else {
        setVisibleKeys(element['name'], visible);
      }
    }
  }

  showConfirmDialog() {
    Map<String, List> formPagePreviewData = {};

    for (int x = 0; x < pages.length; x++) {
      valueFormResults.forEach((key, value) {
        // printError('{{{{{{value}}}}}}');
        // printError(value);
        // printError('{{{{{{value}}}}}}');
        /// Map check if formPageData has the key page
        if (pages[x].toString().contains(key)) {
          List currentValues = formPagePreviewData['${pages[x]['name']}'] ?? [];
          if (currentValues.isEmpty) {
            if (![null, '', ' '].contains(value['value'])) {
              formPagePreviewData['${pages[x]['title']}'] = [
                {'value': value['value'], 'name': key}
              ];
            }
          } else {
            if (![null, '', ' '].contains(value['value'])) {
              currentValues.add({'value': value['value'], 'name': key});
            }
          }
        }
      });
    }

    setState(() {
      pageValues = formPagePreviewData.values.toList();
      pageTitles = formPagePreviewData.keys.toList();
      showDialogContainer = true;
    });
  }

  /// All created elements should be added here
  /// This is called when a form element is created
  /// It updates the formValues map and formResults map
  Map<String, dynamic> setUpElement(String name, Map<String, dynamic> value) {
    /// new element value
    Map<String, dynamic> newValue = value;

    /// Do a update value check
    if (widget.defaultValues.containsKey(value['name'])) {
      newValue['value'] = widget.defaultValues[value['name']];
    }

    /// add the element to the formValues map
    if (valueFormResults.containsKey(name) == false) {
      setState(() {
        /// Add the value
        valueFormResults.putIfAbsent(name, () => newValue);

        ///check if name represent a page name

        visibleIf();
        isRequiredIf();
        enableIf();
      });
    }

    /// return the new element
    return newValue;
  }

  /// Helper func
  String trimCurly(String value) {
    int start = value.indexOf("{") + 1;
    int end = value.indexOf("}");
    return value.substring(start, end);
  }

  List<String> trimListString(String value) {
    try {
      value.toLowerCase();
      int start = value.indexOf("[") + 1;
      int end = value.indexOf("]");
      return value.substring(start, end).split(",").toList();
    } catch (e) {
      // printError(' ******* $e ********');
      return [];
    }
  }

  /// Use this to get the condition value
  /// returns a string
  String conditionValue(String value) {
    int start = value.indexOf("=") + 2;
    return value.substring(start);
  }

  /// Use this to split the string by [and, or]
  /// and remove the ' from values
  /// returns a list of strings
  List splitStringList(String value) {
    List splits = [];

    /// check if the value contains [and, or]
    if (value.contains(" or ") || value.contains(" and ")) {
      /// separate a string by or and remove the ' from values
      if (value.contains(" or ")) {
        splits.addAll(value
            .split(" or ")
            .map((str) => str.replaceAll("'", "").replaceAll(", ", ","))
            .toList());
      }

      /// separate a string by and and remove the ' from values
      if (value.contains(" and ")) {
        splits.addAll(value
            .split(" and ")
            .map((str) => str.replaceAll("'", "").replaceAll(", ", ","))
            .toList());
      }
    } else {
      splits.add(value.replaceAll("'", "").replaceAll(", ", ","));
    }
    return splits;
  }

  /// This function splits the enableIf string into a list of conditions
  /// and updates its required state
  enableIf() {
    /// loop through the objects to get value element
    valueFormResults.forEach((name, element) {
      // printWarning( '$name --- *** --- $element');

      /// check if the element has a name property
      if (name != null) {
        /// check if the element has a visible property
        if (element['enable'] != null) {}
        if (element['enableIf'] != null) {
          /// Drama follows here if the element has a enableIf
          /// property and no enable property is set

          /// create a list of conditions
          /// Handle or conditions
          /// Handle and conditions
          List enableIfConditions = splitStringList(element['enableIf']);

          // printWarning( '$name --- @@@ --- $enableIfConditions');

          /// New Map for conditional bools
          List visibilityStates = [];

          /// loop through enableIfConditions
          for (var condition in enableIfConditions) {
            // printWarning( '$name --- %%% --- $condition');

            /// Handle anyof conditionType
            /// it should overwrite enable state from above
            if (condition.toString().contains(' anyof ')) {
              // printWarning( '$name --- anyof --- $condition');

              /// Here we handle the many conditions in the enableIf that meet
              /// the anyof condition type
              if (valueFormResults[trimCurly(condition)] != null) {
                /// get the values in the list
                List<String> getListString =
                    trimListString(condition.toString().toLowerCase());

                /// get the value of the element if element is not found
                /// set it to an empty string

                String trimValue = trimCurly(condition);

                String trimCurlyValue = valueFormResults[trimValue]!['value']
                    .toString()
                    .toLowerCase();

                /// data found, now check if trimCurly element
                /// value is in getListString
                if (getListString.contains(trimCurlyValue)) {
                  visibilityStates.add(true);
                } else {
                  visibilityStates.add(false);
                }
              }
            }

            /// Handle notempty conditions
            /// it should overwrite enabled state from above
            if (condition.toString().contains('notempty')) {
              // printWarning( '$name --- notempty --- $condition');

              /// get the value of the element if element is not found
              /// set it to an empty string

              var trimCurlyValue =
                  valueFormResults[trimCurly(condition)] == null
                      ? ''
                      : valueFormResults[trimCurly(condition)]!['value'];

              // printWarning( '$name --- $trimCurlyValue --- $condition');

              /// Here we handle the many conditions in the enableIf that meet
              /// the notempty condition type
              if (trimCurlyValue.toString().isNotEmpty) {
                visibilityStates.add(true);
              } else {
                visibilityStates.add(false);
              }
            }

            /// Handle = conditions
            /// it should overwrite enabled state from above
            if (condition.toString().contains(' = ')) {
              // printWarning( '$name --- = --- $condition');
              // printWarning( '$name --- ${conditionValue(condition).toString()} --- $condition');

              /// get the value of the element if element is not found
              /// set it to an empty string
              var trimCurlyValue =
                  valueFormResults[trimCurly(condition)] == null
                      ? ''
                      : valueFormResults[trimCurly(condition)]!['value'];

              if (trimCurlyValue.toString() ==
                  conditionValue(condition).toString()) {
                visibilityStates.add(true);
              } else {
                visibilityStates.add(false);
              }
            }
          }

          /// Handle the and / or conditions state
          if (element['enableIf'].toString().contains(' and ')) {
            // printWarning( '$name --- FINAL AND --- $visibilityStates');

            /// update the enable valueFormResults
            valueFormResults.update(name, (value) {
              value['enable'] = !visibilityStates.contains(false);
              return value;
            });
          } else if (element['enableIf'].toString().contains(' or ')) {
            // printWarning( '$name --- FINAL OR --- $visibilityStates');

            /// update the enable valueFormResults
            valueFormResults.update(name, (value) {
              value['enable'] = visibilityStates.contains(true);
              return value;
            });
          } else {
            // printWarning( '$name --- FINAL --- $visibilityStates');

            /// update the enable valueFormResults
            valueFormResults.update(name, (value) {
              value['enable'] = !visibilityStates.contains(false);
              return value;
            });
          }
        } else {
          // printWarning( '$name --- NO VISIBILITY FIELDS --- ${element['name']}');

          /// Here we just let it go bro.
          /// if the element has no enableIf property and no enable property
          /// its inevitable that it will be enable
          /// remove the invisibilityMap
          /// update the enable valueFormResults
          valueFormResults.update(name, (value) {
            value['enable'] = true;
            return value;
          });
        }
      }
    });
  }

  /// This function splits the requiredIf string into a list of conditions
  /// and updates its required state
  isRequiredIf() {
    /// loop through the objects to get value element
    valueFormResults.forEach((name, element) {
      // printWarning( '$name --- *** --- $element');

      /// check if the element has a name property
      if (name != null) {
        if (element['isRequiredIf'] != null) {
          /// Drama follows here if the element has a isRequiredIf
          /// property and no isRequired property is set

          /// create a list of conditions
          /// Handle or conditions
          /// Handle and conditions
          List isRequiredIfConditions =
              splitStringList(element['isRequiredIf']);

          // printWarning( '$name --- @@@ --- $isRequiredIfConditions');

          /// New Map for conditional bools
          List visibilityStates = [];

          /// loop through isRequiredIfConditions
          for (var condition in isRequiredIfConditions) {
            // printWarning( '$name --- %%% --- $condition');

            /// Handle anyof conditionType
            /// it should overwrite isRequired state from above
            if (condition.toString().contains(' anyof ')) {
              // printWarning( '$name --- anyof --- $condition');

              /// Here we handle the many conditions in the isRequiredIf that meet
              /// the anyof condition type
              if (valueFormResults[trimCurly(condition)] != null) {
                /// get the values in the list
                List<String> getListString =
                    trimListString(condition.toString().toLowerCase());

                /// get the value of the element if element is not found
                /// set it to an empty string

                String trimValue = trimCurly(condition);

                String trimCurlyValue = valueFormResults[trimValue]!['value']
                    .toString()
                    .toLowerCase();

                /// data found, now check if trimCurly element
                /// value is in getListString
                if (getListString.contains(trimCurlyValue)) {
                  visibilityStates.add(true);
                } else {
                  visibilityStates.add(false);
                }
              }
            }

            /// Handle notempty conditions
            /// it should overwrite enabled state from above
            if (condition.toString().contains('notempty')) {
              // printWarning( '$name --- notempty --- $condition');

              /// get the value of the element if element is not found
              /// set it to an empty string

              var trimCurlyValue =
                  valueFormResults[trimCurly(condition)] == null
                      ? ''
                      : valueFormResults[trimCurly(condition)]!['value'];

              // printWarning( '$name --- $trimCurlyValue --- $condition');

              /// Here we handle the many conditions in the isRequiredIf that meet
              /// the notempty condition type
              if (trimCurlyValue.toString().isNotEmpty) {
                visibilityStates.add(true);
              } else {
                visibilityStates.add(false);
              }
            }

            /// Handle = conditions
            /// it should overwrite enabled state from above
            if (condition.toString().contains(' = ')) {
              // printWarning( '$name --- = --- $condition');
              // printWarning( '$name --- ${conditionValue(condition).toString()} --- $condition');

              /// get the value of the element if element is not found
              /// set it to an empty string
              var trimCurlyValue =
                  valueFormResults[trimCurly(condition)] == null
                      ? ''
                      : valueFormResults[trimCurly(condition)]!['value'];

              if (trimCurlyValue.toString() ==
                  conditionValue(condition).toString()) {
                visibilityStates.add(true);
              } else {
                visibilityStates.add(false);
              }
            }
          }

          /// Handle the and / or conditions state
          if (element['isRequiredIf'].toString().contains(' and ')) {
            // printWarning( '$name --- FINAL AND --- $visibilityStates');

            /// update the isRequired valueFormResults
            valueFormResults.update(name, (value) {
              value['isRequired'] = !visibilityStates.contains(false);
              return value;
            });
          } else if (element['isRequiredIf'].toString().contains(' or ')) {
            // printWarning( '$name --- FINAL OR --- $visibilityStates');

            /// update the isRequired valueFormResults
            valueFormResults.update(name, (value) {
              value['isRequired'] = visibilityStates.contains(true);
              return value;
            });
          } else {
            // printWarning('$name --- FINAL --- $visibilityStates');

            // printWarning( '$name --- FINAL --- $visibilityStates');

            /// update the isRequired valueFormResults
            valueFormResults.update(name, (value) {
              value['isRequired'] = !visibilityStates.contains(false);
              return value;
            });
          }
        } else {
          // printWarning( '$name --- NO VISIBILITY FIELDS --- ${element['name']}');

          /// Here we just let it go bro.
          /// if the element has no isRequiredIf property and no isRequired property
          /// its inevitable that it will be isRequired
          /// remove the invisibilityMap
          /// update the isRequired valueFormResults

          /// check if the element has a isRequired property
          valueFormResults.update(name, (value) {
            value['isRequired'] = false;
            return value;
          });
        }
      }
    });
  }

  /// This function splits the visibleIf string into a list of conditions
  /// and updates its visibility
  visibleIf() {
    /// loop through the objects to get value element
    valueFormResults.forEach((name, element) {
      // printWarning( '$name --- *** --- $element');

      /// check if the element has a name property
      if (name != null) {
        if (element['visibleIf'] != null) {
          /// Drama follows here if the element has a visibleIf
          /// property and no visible property is set

          /// create a list of conditions
          /// Handle or conditions
          /// Handle and conditions
          List visibleIfConditions = splitStringList(element['visibleIf']);

          // printWarning( '$name --- @@@ --- $visibleIfConditions');

          /// New Map for conditional bools
          List visibilityStates = [];

          /// loop through visibleIfConditions
          for (var condition in visibleIfConditions) {
            // print('???? Conditions');
            // print(condition);

            // printWarning( '$name --- %%% --- $condition');

            /// Handle anyof conditionType
            /// it should overwrite visible state from above
            if (condition.toString().contains(' anyof ')) {
              // printWarning( '$name --- anyof --- $condition');

              /// Here we handle the many conditions in the visibleIf that meet
              /// the anyof condition type
              if (valueFormResults[trimCurly(condition)] != null) {
                /// get the values in the list
                List<String> getListString =
                    trimListString(condition.toString().toLowerCase());

                /// get the value of the element if element is not found
                /// set it to an empty string

                String trimValue = trimCurly(condition);

                String trimCurlyValue = valueFormResults[trimValue]!['value']
                    .toString()
                    .toLowerCase();

                /// data found, now check if trimCurly element
                /// value is in getListString
                if (getListString.contains(trimCurlyValue)) {
                  visibilityStates.add(true);
                } else {
                  visibilityStates.add(false);
                }
              }
            }

            /// Handle notempty conditions
            /// it should overwrite enabled state from above
            if (condition.toString().contains('notempty')) {
              // printWarning( '$name --- notempty --- $condition');

              /// get the value of the element if element is not found
              /// set it to an empty string

              var trimCurlyValue =
                  valueFormResults[trimCurly(condition)] == null
                      ? ''
                      : valueFormResults[trimCurly(condition)]!['value'];

              // printWarning( '$name --- $trimCurlyValue --- $condition');

              /// Here we handle the many conditions in the visibleIf that meet
              /// the notempty condition type
              if (trimCurlyValue.toString().isNotEmpty) {
                visibilityStates.add(true);
              } else {
                visibilityStates.add(false);
              }
            }

            /// Handle = conditions
            /// it should overwrite enabled state from above
            if (condition.toString().contains(' = ')) {
              // printWarning( '$name --- = --- $condition');
              // printWarning( '$name --- ${conditionValue(condition).toString()} --- $condition');

              /// get the value of the element if element is not found
              /// set it to an empty string
              var trimCurlyValue =
                  valueFormResults[trimCurly(condition)] == null
                      ? ''
                      : valueFormResults[trimCurly(condition)]!['value'];

              if (trimCurlyValue.toString() ==
                  conditionValue(condition).toString()) {
                visibilityStates.add(true);
              } else {
                visibilityStates.add(false);
              }
            }
          }

          // "visibleIf": "{MotherMaritalStatus} anyof ['Divorced', 'Widowed', 'Married'] and {IsthechildAbandoned} anyof ['NO']"
          /// Handle the and / or conditions state
          if (element['visibleIf'].toString().contains(' and ')) {
            // printWarning( '$name --- FINAL AND --- $visibilityStates');

            /// update the visible valueFormResults
            valueFormResults.update(name, (value) {
              loopThroughElements(element['elements'] ?? [], element['name'],
                  !visibilityStates.contains(false));
              value['visible'] = !visibilityStates.contains(false);
              return value;
            });
          } else if (element['visibleIf'].toString().contains(' or ')) {
            // printWarning( '$name --- FINAL OR --- $visibilityStates');

            /// update the visible valueFormResults
            valueFormResults.update(name, (value) {
              loopThroughElements(element['elements'] ?? [], element['name'],
                  !visibilityStates.contains(false));
              value['visible'] = visibilityStates.contains(true);
              return value;
            });
          } else {
            // printWarning( '$name --- FINAL --- $visibilityStates');

            /// update the visible valueFormResults
            valueFormResults.update(name, (value) {
              loopThroughElements(element['elements'] ?? [], element['name'],
                  !visibilityStates.contains(false));
              value['visible'] = !visibilityStates.contains(false);
              return value;
            });
          }
        } else {
          // printWarning( '$name --- NO VISIBILITY FIELDS --- ${element['name']}');

          /// Here we just let it go bro.
          /// if the element has no visibleIf property and no visible property
          /// its inevitable that it will be visible
          /// remove the invisibilityMap
          /// update the visible valueFormResults
          /// check if the element has a visible property
          if (element['visible'] == null) {
            valueFormResults.update(name, (value) {
              loopThroughElements(
                  element['elements'] ?? [], element['name'], true);
              value['visible'] = true;
              return value;
            });
          } else {
            valueFormResults.update(name, (value) {
              loopThroughElements(
                  element['elements'] ?? [], element['name'], value['visible']);
              value['visible'] = value['visible'];
              return value;
            });
          }
        }
      }

      int index = pagesListData
          .indexWhere((element) => element['name']['name'] == name);
      if (index != -1) {
        pagesListData[index]['visibility'] =
            valueFormResults[name]!['visible'] ?? true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.context,
    required this.onFormSubmit,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final BuildContext context;
  final VoidCallback onFormSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: FilledButton(
      onPressed: () {
        onFormSubmit.call();
      },
      child: const Padding(
          padding: EdgeInsets.only(bottom: 3, top: 3, right: 8.0, left: 8.0),
          child: Text('Submit')),
    )
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //       backgroundColor: const Color(0xff2F6CF6),
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //       textStyle:
        //           const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        //   onPressed: () {
        //       onFormSubmit.call();
        //   },
        //   child: const Text("Submit"),
        // ),
        );
  }
}

class Next extends StatelessWidget {
  const Next({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.context,
    required this.onNext,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final BuildContext context;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: FilledButton(
      onPressed: () {
        onNext.call();
      },
      child: const Padding(
          padding: EdgeInsets.only(bottom: 3, top: 3, right: 8.0, left: 8.0),
          child: Text('Next')),
    )
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //       backgroundColor: Color(0xff2F6CF6),
        //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //       textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        //   onPressed: () {
        //     onNext.call();
        //   },
        //   child: const Text('Next'),
        // ),
        );
  }
}

class Previous extends StatelessWidget {
  const Previous({
    super.key,
    required this.formKey,
    required this.context,
    required this.onPrevious,
  });

  final GlobalKey<FormState> formKey;
  final BuildContext context;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: FilledButton(
      onPressed: () {
        onPrevious.call();
      },
      child: const Padding(
        padding: EdgeInsets.only(bottom: 3, top: 3, right: 8.0, left: 8.0),
        child: Text('Previous'),
      ),
    )
        // OutlinedButton(
        //   style: OutlinedButton.styleFrom(
        //       foregroundColor: Colors.black.withOpacity(0.6),
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //       textStyle:
        //           const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        //   onPressed: () {
        //     onPrevious.call();
        //   },
        //   child: const Text('Previous'),
        // ),
        );
  }
}

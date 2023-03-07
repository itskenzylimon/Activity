import 'dart:async';

import 'package:activity/activity.dart';
import 'package:flutter/material.dart';

import '../../widgets/elements/age_calculator_field.dart';
import '../../widgets/elements/check_box_field.dart';
import '../../widgets/elements/date_picker_field.dart';
import '../../widgets/elements/drop_down_field.dart';
import '../../widgets/elements/radio_group_field.dart';
import '../../widgets/elements/signature_pad_field.dart';
import '../../widgets/elements/text_field.dart';
import '../../widgets/elements/text_search_update_field.dart';
import '../../widgets/elements/type_field.dart';

class SurveyJSForm extends StatefulWidget {
  final Map schema;
  final Map<String, Map<String, dynamic>> formResults;
  final BuildContext context;
  final ValueChanged<Map<String, dynamic>> onFormValueSubmit;

  const SurveyJSForm({
    super.key,
    required this.schema,
    required this.context,
    required this.formResults,
    required this.onFormValueSubmit,
  });

  @override
  State<SurveyJSForm> createState() => _SurveyJSFormState();
}

class _SurveyJSFormState extends State<SurveyJSForm>
    with TickerProviderStateMixin {
  /// All themes map
  List<Map<String, dynamic>> themeStyle = [];

  // Map<String, SampleWidget> customWidgets(){
  //  return {
  //
  //  };
  // }

  /// Theme map
  Map<String, dynamic> metaData = {
    'theme': {
      'theme': {
        'primaryColor': Colors.teal,
        'secondaryColor': Colors.teal,
      },
      'textfield': {
        'showCursor': true,
      },
      'button': {
        'type': 'outline'

        /// outline, filled
      },
    },
    'customWidgets': {'elementName': SampleWidget}
  };

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TabController tabController;

  int initialIndex = 0;

  List pages = [];

  late Timer debounce;

  String? path;

  Map<String, Map<String, dynamic>> valueFormResults = {};

  @override
  void initState() {
    super.initState();

    pages =
        widget.schema['pages'] ?? widget.schema['service']['schema']['pages'];

    tabController = TabController(
      initialIndex: initialIndex,
      length: pages.length,
      vsync: this,
    );

    tabController.index = initialIndex;

    /// set the current page view
    setPageChangeListeners();

    // metaData.putIfAbsent('customWidgets', () => customWidgets());
  }

  setPageChangeListeners() {
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        setState(() {
          initialIndex = tabController.index;
        });
      }
    });
  }

  Widget formBuilderController(page) {
    // assign formResults to formValues.
    Visibility dropdownChoices(Map<String, dynamic> element) {
      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], element);

      return Visibility(
          child: DropDownWidget(
        onElementCallback: (Map<String, dynamic> value) {
          setState(() {
            Map<String, Map<String, dynamic>> newValueFormResults =
                valueFormResults;
            newValueFormResults[element['name']] = value;
            valueFormResults = newValueFormResults;
          });
        },
        elementName: element['name'],
        valueFormResults: valueFormResults,
        customTheme: metaData['theme'],
      ));
    }

    Visibility httpLookUp(Map<String, dynamic> element) {
      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement('${element['name']}-${element['outputs'][0]['value']}', newElement);
      return Visibility(
          child: TextSearchUpdateFieldWidget(
        onElementCallback: (Map<String, dynamic> value) {
          setState(() {
            Map<String, Map<String, dynamic>> newValueFormResults =
                valueFormResults;
            newValueFormResults[element['name']] = value;
            valueFormResults = newValueFormResults;
          });
        },
        elementName: '${element['name']}-${element['outputs'][0]['value']}',
        valueFormResults: valueFormResults,
        customTheme: {},
      ));
    }

    Visibility datepicker(Map<String, dynamic> element) {
      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);

      return Visibility(
          child: DatePickerWidget(
        onElementCallback: (Map<String, dynamic> value) {
          setState(() {
            Map<String, Map<String, dynamic>> newValueFormResults =
                valueFormResults;
            newValueFormResults[element['name']] = value;
            valueFormResults = newValueFormResults;
          });
        },
        elementName: element['name'],
        valueFormResults: valueFormResults,
        customTheme: metaData['theme'],
      ));
    }

    Visibility radioGroup(Map<String, dynamic> element) {
      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      // print("???? ELEMENT");
      // print(element);
      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);

      return Visibility(
          child: RadioGroupWidget(
        onElementCallback: (Map<String, dynamic> value) {
          setState(() {
            Map<String, Map<String, dynamic>> newValueFormResults =
                valueFormResults;
            newValueFormResults[element['name']] = value;
            valueFormResults = newValueFormResults;
          });
        },
        elementName: element['name'],
        valueFormResults: valueFormResults,
      ));
    }

    Visibility filePicker(Map<String, dynamic> element) {
      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);

      return Visibility(child: Container());
    }

    Visibility checkbox(Map<String, dynamic> element) {
      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);

      return Visibility(
          child: CheckBoxWidget(
        onElementCallback: (Map<String, dynamic> value) {
          setState(() {
            Map<String, Map<String, dynamic>> newValueFormResults =
                valueFormResults;
            newValueFormResults[element['name']] = value;
            valueFormResults = newValueFormResults;
          });
        },
        elementName: element['name'],
        valueFormResults: valueFormResults,
        customTheme: metaData['theme'],
      ));
    }

    Visibility signaturePad(Map<String, dynamic> element) {
      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);

      return Visibility(
          child: SignatureFieldWidget(
        onElementCallback: (Map<String, dynamic> value) {
          setState(() {
            Map<String, Map<String, dynamic>> newValueFormResults =
                valueFormResults;
            newValueFormResults[element['name']] = value;
            valueFormResults = newValueFormResults;
          });
        },
        elementName: element['name'],
        valueFormResults: valueFormResults,
        customTheme: metaData['theme'],
      ));
    }

    Visibility ageCalculator(Map<String, dynamic> element) {
      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': '',
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);

      return Visibility(
          visible: valueFormResults[element['name']]!['visible'],
          child: AgeCalculatorWidget(
            onElementCallback: (Map<String, dynamic> value) {
              setState(() {
                Map<String, Map<String, dynamic>> newValueFormResults =
                    valueFormResults;
                newValueFormResults[element['name']] = value;
                valueFormResults = newValueFormResults;
              });
            },
            elementName: element['name'],
            valueFormResults: valueFormResults,
            customTheme: metaData['theme'],
          ));
    }

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

      return Visibility(
          visible: valueFormResults[element['name']]!['visible'],
          child: TextFieldWidget(
            onElementCallback: (Map<String, dynamic> value) {
              setState(() {
                Map<String, Map<String, dynamic>> newValueFormResults =
                    valueFormResults;
                newValueFormResults[element['name']] = value;
                valueFormResults = newValueFormResults;
              });
            },
            elementName: element['name'],
            valueFormResults: valueFormResults,
            customTheme: metaData['theme'],
          ));
    }

    Visibility textSearchUpdateField(Map<String, dynamic> element) {
      TextEditingController textEditingController = TextEditingController();

      /// call setUpElement
      Map<String, dynamic> newElement = {
        'value': textEditingController.text,
        'controller': textEditingController,
      }..addAll(element);

      /// After setting up the element, add it to the elementData
      /// use elementData in the rest of the function
      setUpElement(element['name'], newElement);

      return Visibility(
          visible: valueFormResults[element['name']]!['visible'],
          child: TextFieldWidget(
            onElementCallback: (Map<String, dynamic> value) {
              setState(() {
                Map<String, Map<String, dynamic>> newValueFormResults =
                    valueFormResults;
                newValueFormResults[element['name']] = value;
                valueFormResults = newValueFormResults;
              });
            },
            elementName: element['name'],
            valueFormResults: valueFormResults,
            customTheme: metaData['theme'],
          ));
    }

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

        case 'textsearchupdatefield':
          return textSearchUpdateField(element);

        case 'comment':
          return textField(element);

        case 'dropdown':
          return dropdownChoices(element);

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

        case 'agecalc':
          return ageCalculator(element);

        case 'container':
          return container(element);

        default:
          return customWidget(element);
      }
    }

    Widget checkElement(Map<String, dynamic> element) {

      if (element['type'] == 'panel') {

        /// After setting up the element, add it to the elementData
        /// use elementData in the rest of the function
        setUpElement(element['name'], element);

        // visibleMap.add(element['name'], true);
        Column children = Column(
          children: [
            for (var element in element['elements']) checkElement(element)
          ],
        );

        return Visibility(
          visible: valueFormResults[element['name']]!['visible'] ?? true,
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
      }
      else {
        return getElement(element);
      }
    }


    /// new Line function
    /// check if next element has startWithNewLine = false
    bool checkNextLine(Map element, int index){
      bool startWithNewLine = true;
      List fields = page['elements'];
      Map nextElement = fields.length == (index + 1) ? {} : fields[index + 1];
      if(nextElement.isNotEmpty){
        startWithNewLine = nextElement['startWithNewLine'] ?? true;
        printError(' @#@#@#@#@# : ${element['name']}');
        printError('startWithNewLine: $startWithNewLine');
        printError(' %^%^%^%^%^% : ${nextElement['name']}');
      } else {
        startWithNewLine = true;
      }
      printError('startWithNewLine: $startWithNewLine');
      return startWithNewLine;
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

      ListView listView = ListView(
        children: [for (var element in page['elements']) checkElement(element)],
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

  /// Extend the custom widget functions

  @override
  Widget build(BuildContext context) {
    visibleIf();
    isRequiredIf();
    enableIf();

    return Scaffold(
      body: SafeArea(
          child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            // the tab bar with pages
            SizedBox(
              height: 50,
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                bottom: TabBar(
                  unselectedLabelStyle: const TextStyle(
                      fontSize: 14.0,
                      color: Color(0xff0062E1),
                      fontWeight: FontWeight.w500),
                  labelStyle: const TextStyle(
                      fontSize: 14.0,
                      color: Color(0xff101828),
                      fontWeight: FontWeight.bold),
                  labelColor: const Color(0xff0062E1),
                  unselectedLabelColor: const Color(0xff101828),
                  controller: tabController,
                  isScrollable: true,
                  tabs: [
                    //// TODO: Some pages could be invisible
                    for (var page in pages)
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Tab(
                          text: page['title'],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // create widgets for each tab bar here
            Expanded(
              flex: 1,
              child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    for (var page in pages) formBuilderController(page)
                  ]),
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
                            if (tabController.index > 0) {
                              setState(() {
                                initialIndex = initialIndex - 1;
                              });
                              tabController.index -= 1;
                            }
                          },
                          formKey: formKey,
                        ),
                      ),
                      const Spacer(),
                      (initialIndex + 1) == pages.length
                          ? SubmitButton(
                              context: context,
                              formKey: formKey,
                              onFormSubmit: () {
                                /// TODO: Validate the form
                                var listValues = [];
                                valueFormResults.forEach((key, value) {
                                  if (value.containsKey("value") &&
                                      value.containsKey("isRequired")) {
                                    if (value['isRequired'] == true &&
                                        value['value'] != "") {
                                      listValues.add(true);
                                    } else {
                                      listValues.add(false);
                                    }
                                  }
                                });
                                var isValid = listValues
                                    .any((element) => element == false);
                                if (isValid == true) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "Fill all required fields",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                          )));
                                } else {
                                  printError(
                                      "valueFormResults--------------------");
                                  widget.onFormValueSubmit(valueFormResults);
                                  printError(valueFormResults);
                                }
                              },
                            )
                          : Next(
                              context: context,
                              onNext: () {
                                if (tabController.index < pages.length - 1) {
                                  setState(() {
                                    initialIndex = initialIndex + 1;
                                  });
                                  tabController.index += 1;
                                }
                              },
                              formKey: formKey,
                            )
                    ],
                  ),
                ),
              ),
            ),
            // the buttons
          ],
        ),
      )),
    );
  }

  /// All created elements should be added here
  /// This is called when a form element is created
  /// It updates the formValues map and formResults map
  Map<String, dynamic> setUpElement(String name, Map<String, dynamic> value) {
    /// new element value
    Map<String, dynamic> newValue = value;

    /// add the element to the formValues map
    if (valueFormResults.containsKey(name) == false) {
      setState(() {
        /// Add the value
        valueFormResults.putIfAbsent(name, () => newValue);
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
      return value.substring(start, end)
          .split(",").toList();
    } catch(e){
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
          if(element['enableIf'].toString().contains(' and ')){

            // printWarning( '$name --- FINAL AND --- $visibilityStates');

            /// update the enable valueFormResults
            valueFormResults.update(name, (value) {
              value['enable'] = !visibilityStates.contains(false);
              return value;
            });

          }
          else if (element['enableIf'].toString().contains(' or ')){

            // printWarning( '$name --- FINAL OR --- $visibilityStates');

            /// update the enable valueFormResults
            valueFormResults.update(name, (value) {
              value['enable'] = visibilityStates.contains(true);
              return value;
            });

          }
          else {

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
        /// check if the element has a isRequired property
        if (element['isRequired'] != null) {}
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
          if(element['isRequiredIf'].toString().contains(' and ')){

            // printWarning( '$name --- FINAL AND --- $visibilityStates');

            /// update the isRequired valueFormResults
            valueFormResults.update(name, (value) {
              value['isRequired'] = !visibilityStates.contains(false);
              return value;
            });

          }
          else if (element['isRequiredIf'].toString().contains(' or ')){

            // printWarning( '$name --- FINAL OR --- $visibilityStates');

            /// update the isRequired valueFormResults
            valueFormResults.update(name, (value) {
              value['isRequired'] = visibilityStates.contains(true);
              return value;
            });
          } else {
            printWarning('$name --- FINAL --- $visibilityStates');

          }
          else {

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
          valueFormResults.update(name, (value) {
            value['isRequired'] = true;
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

              // printWarning( '$name --- %%% --- $condition');

              /// Handle anyof conditionType
              /// it should overwrite visible state from above
              if (condition.toString().contains(' anyof ')) {

                // printWarning( '$name --- anyof --- $condition');

                /// Here we handle the many conditions in the visibleIf that meet
                /// the anyof condition type
                if (valueFormResults[trimCurly(condition)] != null) {
                  /// get the values in the list
                  List<String> getListString = trimListString(condition.toString().toLowerCase());
                  /// get the value of the element if element is not found
                  /// set it to an empty string

                  String trimValue = trimCurly(condition);

                  String trimCurlyValue =
                  valueFormResults[trimValue]!['value'].toString().toLowerCase();

                  /// data found, now check if trimCurly element
                  /// value is in getListString
                  if(getListString.contains(trimCurlyValue)){

                    visibilityStates.add(true);
                  }
                  else {
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
                valueFormResults[trimCurly(condition)] == null ? '' :
                valueFormResults[trimCurly(condition)]!['value'];

                // printWarning( '$name --- $trimCurlyValue --- $condition');


                /// Here we handle the many conditions in the visibleIf that meet
                /// the notempty condition type
                if(trimCurlyValue.toString().isNotEmpty){
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
                valueFormResults[trimCurly(condition)] == null ? '' :
                valueFormResults[trimCurly(condition)]!['value'];

                if(trimCurlyValue.toString() == conditionValue(condition).toString()){
                  visibilityStates.add(true);
                } else {
                  visibilityStates.add(false);
                }
              }
            }

            /// Handle the and / or conditions state
            if(element['visibleIf'].toString().contains(' and ')){

              // printWarning( '$name --- FINAL AND --- $visibilityStates');

              /// update the visible valueFormResults
              valueFormResults.update(name, (value) {
                value['visible'] = !visibilityStates.contains(false);
                return value;
              });

            }
            else if (element['visibleIf'].toString().contains(' or ')){

              // printWarning( '$name --- FINAL OR --- $visibilityStates');

            /// update the visible valueFormResults
            valueFormResults.update(name, (value) {
              value['visible'] = visibilityStates.contains(true);
              return value;
            });

          }
          else {

            printWarning( '$name --- FINAL --- $visibilityStates');

              /// update the visible valueFormResults
              valueFormResults.update(name, (value) {
                value['visible'] = !visibilityStates.contains(false);
                return value;
              });

          }
        }
        else {
          // printWarning( '$name --- NO VISIBILITY FIELDS --- ${element['name']}');

          /// Here we just let it go bro.
          /// if the element has no visibleIf property and no visible property
          /// its inevitable that it will be visible
          /// remove the invisibilityMap
          /// update the visible valueFormResults
          valueFormResults.update(name, (value) {
            value['visible'] = true;
            return value;
          });

          /// check if the element has a visible property
          if (element['visible'] == null) {
            valueFormResults.update(name, (value) {
              value['visible'] = true;
              return value;
            });
          } else {
            valueFormResults.update(name, (value) {
              value['visible'] = value['visible'];
              return value;
            });
          }



        }
      }
    });
  }

  @override
  void dispose() {
    // super.dispose();
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
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff2F6CF6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // If the form is valid, display a Snackbar.
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Processing Data')));
            onFormSubmit.call();
          }
        },
        child: const Text("Submit"),
      ),
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
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff2F6CF6),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        onPressed: () {
          onNext.call();
        },
        child: const Text('Next'),
      ),
    );
  }
}

class Previous extends StatelessWidget {
  const Previous({
    super.key,
    required GlobalKey<FormState> formKey,
    required this.context,
    required this.onPrevious,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;
  final BuildContext context;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black.withOpacity(0.6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        onPressed: () {
          onPrevious.call();
        },
        child: const Text('Previous'),
      ),
    );
  }
}

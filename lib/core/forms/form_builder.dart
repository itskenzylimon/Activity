import 'dart:convert';

import 'package:activity/core/networks/active_request.dart';
import 'package:flutter/material.dart';

import '../helpers/logger.dart';

class FormBuilder{
  final List elements;
  final Object? results;
  final BuildContext context;

  const FormBuilder({
    required this.elements,
    required this.context,
    this.results,
  });

  Center create(){

    // Key / value for the form
    Map<String, dynamic> newResults = {};

    /// List results
    Object widgetKey = {};

    /// Validation func


    /// Logic fun


    /// Helper func
    String trimCurly(String value){
      int start = value.indexOf("{") + 1;
      int end = value.indexOf("}");
      return value.substring(start, end);
    }

    List trimListString(String value){
      int start = value.indexOf("[") + 1;
      int end = value.indexOf("]");
      String listString = value.substring(start, end);
      return listString.split(",")
          .map((str) => str.replaceAll("'", "")).toList();
    }

    List splitStringList(String value){
      return value.split("and")
          .map((str) => str.replaceAll("'", "")).toList();
    }

    bool enableIf(element){
      bool enabled = true;
      if(element['readOnly'] != null){
        printError('sfds');
        enabled = element['readOnly'];
      }
      if (element['enableIf'] != null){
        printError('sfwefvwevds');
        /// Handle anyof conditions
        /// it should overwrite enabled state from above

        /// Here we handle the many conditions in the visibleIf
        List enableIfConditions = splitStringList(element['enableIf']);
        for(String search in enableIfConditions){
          if(newResults[trimCurly(element['enableIf'])] != null){
            /// TODO: Handel for OR conditions
            //data found, now check if trimCurly is in getListString
            enabled = trimListString(element['enableIf']).contains(trimCurly(element['enableIf']))
                ? true : false;
          }
        }
      }

      /// Handle notempty conditions
      /// it should overwrite enabled state from above
      if(element['enableIf'].toString().contains('notempty')){
        /// Here we handle the many conditions in the visibleIf
        List enableIfConditions = splitStringList(element['enableIf']);
        for(String search in enableIfConditions){
          if(newResults[trimCurly(element['enableIf'])] != null){
            return true;
          }
        }
      }
      return enabled;
    }

    bool visibleIf(element){
      bool visible = true;
      if (element['visibleIf'] != null){
        printInfo(element['name']);
        /// Handle anyof conditions
        /// it should overwrite enabled state from above
        if(element['visibleIf'].toString().contains('anyof')){
          /// Here we handle the many conditions in the visibleIf
          List visibleIfConditions = splitStringList(element['visibleIf']);
          for(String search in visibleIfConditions){
            if(newResults[trimCurly(element['visibleIf'])] != null){
              /// TODO: Handel for OR conditions
              //data found, now check if trimCurly is in getListString
              visible = trimListString(element['visibleIf']).contains(trimCurly(element['visibleIf']))
                  ? true : false;
            }
          }
        }
        printInfo(visible);
        /// Handle notempty conditions
        /// it should overwrite enabled state from above
        if(element['visibleIf'].toString().contains('notempty')){
          /// Here we handle the many conditions in the visibleIf
          List visibleIfConditions = splitStringList(element['visibleIf']);
          for(String search in visibleIfConditions){
            if(newResults[trimCurly(element['visibleIf'])] != null){
              return true;
            }
          }
        }

      }
      return visible;
    }

    Future<Map<String, dynamic>> formRequest(Map request) async {
      ActiveRequest activeRequest =  ActiveRequest();
      activeRequest.setUp = RequestSetUp(
        idleTimeout: 10,
        connectionTimeout: 10,
        logResponse: true,
        withTrustedRoots: true,
      );

      /// Handle httplookup
      /// Handle choicesByUrl

      ActiveResponse activeResponse = await activeRequest
          .getApi(Params(endpoint: request['url']));

      final Map<String, dynamic> convertedData = jsonDecode(activeResponse.data!);
      return convertedData;
    }

    Future<Map<String, dynamic>> choicesByUrl(Map choicesByUrl) async{
      Map<String, dynamic> choices = await formRequest(choicesByUrl);
      return choices;
    }

    Future<Map<String, dynamic>> httpLookUpUrl(Map choicesByUrl) async{
      Map<String, dynamic> choices = await formRequest(choicesByUrl);
      return choices;
    }


    TextInputType checkInputType(Map element){
      TextInputType type = TextInputType.text;
      if(element['inputType'] != null){
        if(element['inputType'] == 'number'){
          type = TextInputType.number;
        }
      } else {
        /// Find a way to get the form input type
        /// Mobile Number
        if(element.containsValue("^[+][0-9]{12}\$")){
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

    Visibility textField(Map<String, dynamic> element){
      Key textFieldKey = Key(element['name']);
      bool isRequired = element['isRequired'] ?? false;
      String labelText = element['title'] + (isRequired == true ?
      ' * ' : '');

      return Visibility(
        visible: visibleIf(element),
        child: TextFormField(
          keyboardType: checkInputType(element),
          key: textFieldKey,
          readOnly: enableIf(element),
          maxLines: element['type'] == 'comment' ? 5 : 1,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: element['placeholder'] ?? '',
          ),
          validator: (value) {

            /// check if value is required
            if(element['isRequired'] == true){
              /// input validator for numbers
              if(element['inputType'] == 'number'){
                int intValue = int.parse(value ?? '0');
                //check if max exist
                if(element['max'] != null){
                  if(intValue > element['max']){
                    return 'Please enter your user name.';
                  }
                }
                //check if min exist
                if(element['min'] != null){
                  if(element['min'] > intValue){
                    return 'Please enter your user name.';
                  }
                }
                //
              }
            }

            if (value == null || value.isEmpty) {
              return 'Please enter your user name.';
            } else if (value.contains('@')) {
              return 'Please don\'t use the @ char.';
            }
            return null;
          },
        ),
      );
    }

    Visibility dropdownChoices(Map<String, dynamic> element) {
      Key dropdownKey = Key(element['name']);
      printSuccess(element['name']);

      /// TODO: showOtherItem ???

      List<String> choices = [element['title']];
      if(element['choices'] == null ){
        /// check if its a choicesByUrl
        /// Make a httpRequest

        ActiveRequest activeRequest = ActiveRequest();

      } else {
        choices.addAll(element['choices']);
      }


      if(element['renderAs'] != null){
        // if(element['renderAs'] == 'select2'){
        // } else {
        // }
        return Visibility(
            visible: visibleIf(element),
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
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
                      onChanged: (value) {

                      },
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      key: dropdownKey,
                      hint: Text(element['title'] + ' ' + (element['description'] ?? '')),
                      value: element['title'],
                      items: choices.map((String val){
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (value) {

                      },
                    ),
                  ),
                ],
              ),
            )
        );
      } else {
        return Visibility(
          visible: visibleIf(element),
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                key: dropdownKey,
                hint: Text(element['title'] + ' ' + (element['description'] ?? '')),
                value: element['title'],
                items: choices.map((String val){
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                }).toList(),
                onChanged: (value) {

                },
              ),
            ),
          ),
        );
      }
    }

    Visibility htmlText(Map<String, dynamic> element){
      printError( ' **** ' + element['name']);
      return Visibility(
          child: Text(
            element['displayTemplate'],
            style: const TextStyle(
              color: Color(0xff6b7280),
              fontSize: 12,
              fontFamily: "Inter",
              fontWeight: FontWeight.w500,
              letterSpacing: 0.60,
            ),
          ));
    }

    SizedBox httpLookUp(Map<String, dynamic> element) {
      httpLookUpUrl(element);
      /// after loading update the data forms
      return const SizedBox();
    }

    Ink datepicker(Map<String, dynamic> element) {
      DateTime selectedDate = DateTime.now();
      DateTime maxDays = DateTime.now();
      if(element['maxDays'] != null){
        maxDays.add(Duration(days: element['maxDays']));
      }
      selectDate(BuildContext context) async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: maxDays,
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != selectedDate){
          selectedDate = picked;
        }
      }
      return Ink(
        child: GestureDetector(
          onTap: (){
            selectDate(context);
          },
          child: Center(
            child: Text(element['title']),
          ),
        ),
      );
    }

    Container radiogroup(Map<String, dynamic> element) {
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
      return Container(
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
      );
    }

    Container container(Map<String, dynamic> element){
      return Container();
    }

    Container file(Map<String, dynamic> element){
      return Container();
    }

    Container signaturepad(Map<String, dynamic> element){
      return Container();
    }

    Container html(Map<String, dynamic> element){
      return Container();
    }

    Container checkbox(Map<String, dynamic> element){
      String selectedChoice = '';
      return Container(
        child: Column(
          children: [
            Wrap(
              children: [
                for(var choice in element['choices'])
                  ChoiceChip(
                    label: Text(choice),
                    selected: selectedChoice == choice ? true : false,
                    onSelected: (bool selected) {

                    },
                  )
              ],
            ),
            Text("${element['title']}: $selectedChoice")
          ],
        ),
      );
    }

    Widget getElement(Map<String, dynamic> element){
      switch(element['type']) {
        case 'text':
          return textField(element);

        case 'comment':
          return textField(element);

        case 'dropdown':
          return dropdownChoices(element);

        case 'genericquestion':
          return htmlText(element);

        case 'httplookup':
          httpLookUpUrl(element);
          return Container();

        case 'bsdatepicker':
          return datepicker(element);

        case 'radiogroup':
          return radiogroup(element);

        case 'file':
          return file(element);

        case 'checkbox':
          return checkbox(element);

        case 'signaturepad':
          return signaturepad(element);

        case 'html':
          return signaturepad(element);
      // case '':
      //   return aboutPage(httpRequest);
      //   break;
        default:
          return container(element);

      }
    }

    Widget checkElement(Map<String, dynamic> element){
      if(element['type'] == 'panel'){
        Column children = Column(
          children: [
            for(var element in element['elements'])
              checkElement(element)
          ],
        );

        return Card(
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
              )
          ),
        );
      } else {
        return getElement(element);
      }
    }

    Widget buildForm(){
      return ListView(
        children: [
          for(var element in elements)
            checkElement(element)
        ],
      );
    }

    return Center(
      child: buildForm(),
    );

  }

}
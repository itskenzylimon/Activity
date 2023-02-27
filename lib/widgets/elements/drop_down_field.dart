import 'dart:async';
import 'dart:convert';
import 'package:activity/activity.dart';
import 'package:activity/core/networks/active_request.dart';
import 'package:flutter/material.dart';

class DropDownWidget extends StatelessWidget {
   ValueChanged<Map<String, dynamic>> onElementCallback;
   String elementName;
   Map<String, Map<String, dynamic>> valueFormResults;
   Map<String, dynamic> customTheme;

  DropDownWidget({
    super.key,
    required this.onElementCallback,
    required this.elementName,
    required this.valueFormResults,
    required this.customTheme
  });

  // Perform some logic or user interaction that generates a callback value
    Map<String, dynamic> callbackElement = {};
    ActiveRequest activeRequest = ActiveRequest();
    String choice = "Select";
    List<String> choices = ['Select'];
    List<String> choiceList = [];
    List<String> _listNotifier = [];
    List<String> _choicesNotifier = [];

   TextEditingController textEditingController = TextEditingController();

   // Future<Map<String, dynamic>> choicesByUrl(Map choicesByUrl) async {
   //   Map<String, dynamic> choices = await formRequest(choicesByUrl);
   //   return choices;
   // }
List<String> choicesByUrl = [];

  @override
  Widget build(BuildContext context) {

    callbackElement = valueFormResults[elementName]!;
    if(callbackElement['choices'] is List<String>) {
      choices.addAll(callbackElement['choices']);
    }
    else if(callbackElement['choices'] is List<Map>){
      printError(callbackElement['choices']);
      for(var i = 0; i < callbackElement['choices'].length; i++){
        choices.add(callbackElement['choices'][i]['value']);
      }
    }

    if (callbackElement['renderAs'] != null && callbackElement['renderAs'] == 'select2') {
      return Visibility(
        visible: valueFormResults[elementName]!['visible'],
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
                    decoration:  InputDecoration(
                      hintText: 'Search ${callbackElement['title']}',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 12, left: 16),
                    ),
                    controller: callbackElement['controller'],
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        Timer? debounce;
                        if (debounce?.isActive ?? false) debounce?.cancel();
                        debounce =
                            Timer(const Duration(milliseconds: 1000), () async {

                              callbackElement['label'] = callbackElement['title'];
                              callbackElement['options'] = callbackElement['choices'];
                              onElementCallback(callbackElement);

                              var list = await getListItems(
                                value, callbackElement['choicesByUrl']['url'],
                              );

                              for (var l in list) {
                                choiceList.add(
                                  l['value'].toString(),
                                );
                                _listNotifier = choiceList;
                              }
                            });
                      } else {
                        choiceList = ['Select ${callbackElement['title']}'];
                      }
                    },
                  ),
                ),
                SizedBox(
                    width: double.infinity,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, int index) {
                        return ListTile(
                          onTap: () {

                            textEditingController.text = choiceList[index];

                            choiceList.add(choiceList[index]);

                            callbackElement['value'] = choiceList[index];
                            onElementCallback(callbackElement);
                            choiceList.clear();
                          },
                          title: Text(choiceList[index]),
                        );
                      },
                      separatorBuilder: (context, int index) =>
                      const SizedBox(height: 10),
                      itemCount: choiceList.length,
                    )),
              ],
            ),
          ));
    }
    else if (callbackElement['renderAs'] == null && callbackElement['choicesByUrl'] != null) {
      return Visibility(
        visible: valueFormResults[elementName]!['visible'],
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
                      hintText: 'Search',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(bottom: 12, left: 16),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        Timer? debounce;
                        if (debounce?.isActive ?? false) debounce?.cancel();
                        debounce = Timer(const Duration(milliseconds: 1000), () async {
                          var list = await getChoicesByUrl(
                            value,
                            callbackElement['choicesByUrl']['url'],
                          );
                          for (var l in list) {
                            choicesByUrl.add(
                              l['value'].toString(),
                            );
                            // _choicesNotifier = choicesbyurl;
                          }
                        });
                      } else {

                        choicesByUrl = ["Select ${callbackElement['title']}"];

                      }
                    },
                  ),
                ),
                SizedBox(
                    width: double.infinity,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, int index) {
                        return ListTile(
                          onTap: () {

                            callbackElement['value'] = choicesByUrl[index];
                            onElementCallback(callbackElement);
                          },
                          title: Text(choicesByUrl[index]),
                        );
                      },
                      separatorBuilder: (context, int index) => SizedBox(height: 10),
                      itemCount: choicesByUrl.length,
                    )),
              ],
            ),
          ));
    }
    else {

      printSuccess(callbackElement);

      choice = ['', null].contains(callbackElement['value']) ? 'Select' : callbackElement['value'];
      return Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                callbackElement['title'] + ' ' + (callbackElement['description'] ?? '')),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  hint: Text(
                      callbackElement['title'] + ' ' + (callbackElement['description'] ?? '')),
                  value: choice,
                  items: choices.map<DropdownMenuItem>((choice){
                    return DropdownMenuItem(
                      value: choice,
                      child: Text(
                        choice == 'Select' ? '\t - \t ${callbackElement['title']}' : '\t $choice',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {

                    callbackElement['value'] = value;
                    onElementCallback(callbackElement);

                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Call the callback function and pass the callback value
    // onElementCallback(callbackElement);

    // Return an empty Container widget (or any other widget)
    return Container();
  }

   Future<Map<String, dynamic>> formRequest(Map request) async {
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

}
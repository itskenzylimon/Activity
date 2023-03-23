import 'dart:async';
import 'dart:convert';
import 'package:activity/activity.dart';
import 'package:activity/core/networks/active_request.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;

class DropDownWidget extends StatelessWidget {
  ValueChanged<Map<String, dynamic>> onElementCallback;
  String elementName;
  Map<String, Map<String, dynamic>> valueFormResults;
  Map<String, dynamic> customTheme;

  DropDownWidget(
      {super.key,
      required this.onElementCallback,
      required this.elementName,
      required this.valueFormResults,
      required this.customTheme});

  // Perform some logic or user interaction that generates a callback value
  Map<String, dynamic> callbackElement = {};
  ActiveRequest activeRequest = ActiveRequest();

  List<String> choiceList = [];

  TextEditingController textEditingController = TextEditingController();

  // Future<Map<String, dynamic>> choicesByUrl(Map choicesByUrl) async {
  //   Map<String, dynamic> choices = await formRequest(choicesByUrl);
  //   return choices;
  // }
  List<String> choicesByUrl = [];
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    callbackElement = valueFormResults[elementName]!;

    if (callbackElement['renderAs'] != null &&
        callbackElement['renderAs'] == 'select2') {
      String? currentSelectedValue =
          ['', null].contains(callbackElement['value'])
              ? 'Select'
              : callbackElement['value'];
      final ValueNotifier<List<String>> _listNotifier =
          ValueNotifier<List<String>>([currentSelectedValue!]);
      List<String> choicesList = [..._listNotifier.value];
      ScrollController scrollController = ScrollController();
      return Visibility(
          visible: valueFormResults[elementName]!['visible'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${callbackElement['title']}",
                style: const Typography.raw().caption,
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
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
                          border:
                              Border(bottom: BorderSide(color: Colors.grey)),
                        ),
                        child: TextBox(
                            controller: callbackElement['controller'],
                            placeholder: 'Search ${callbackElement['title']}',
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                if (_debounce?.isActive ?? false)
                                  _debounce?.cancel();
                                _debounce =
                                    Timer(const Duration(milliseconds: 100),
                                        () async {
                                  var list = await getListItems(
                                    value,
                                    callbackElement['choicesByUrl']['url'],
                                  );
                                  for (var l in list) {
                                    choicesList.add(
                                      l['value'].toString(),
                                    );
                                    _listNotifier.value = choicesList;
                                  }
                                });
                              } else {
                                choiceList.clear();
                                choicesList = [
                                  "Select ${callbackElement['title']}"
                                ];
                              }
                            })),
                    SizedBox(
                        width: double.infinity,
                        child: ValueListenableBuilder(
                            valueListenable: _listNotifier,
                            builder: (BuildContext context, choicesList,
                                Widget? child) {
                              return SizedBox(
                                height: choicesList.length > 2 ? 250 : 40,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  controller: scrollController,
                                  itemBuilder: (context, int index) {
                                    return ListTile(
                                      onPressed: () {
                                        callbackElement['value'] =
                                            choicesList[index];
                                        onElementCallback(callbackElement);
                                      },
                                      title: Text(choicesList[index]),
                                    );
                                  },
                                  separatorBuilder: (context, int index) =>
                                      SizedBox(height: 10),
                                  itemCount: choicesList.length,
                                ),
                              );
                            })),
                  ],
                ),
              )
            ],
          ));
    }
    else if (callbackElement['renderAs'] == null &&
        callbackElement['choicesByUrl'] != null) {
      String? currentSelectedValue =
          ['', null].contains(callbackElement['value'])
              ? 'Select'
              : callbackElement['value'];
      final ValueNotifier<List<String>> _listNotifier =
          ValueNotifier<List<String>>([currentSelectedValue!]);
      List<String> choicesList = [..._listNotifier.value];
      ScrollController scrollController = ScrollController();
      return Visibility(
          visible: valueFormResults[elementName]!['visible'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${callbackElement['title']}",
                style: const Typography.raw().caption,
              ),
              const SizedBox(
                height: 10,
              ),
              ValueListenableBuilder(
                  valueListenable: _listNotifier,
                  builder: (BuildContext context, choicesList,
                      Widget? child) {
                    return AutoSuggestBox<String>(
                        items: choicesList.map((choice) {
                          return AutoSuggestBoxItem<String>(
                              value: choice,
                              label: choice
                          );
                        }).toList(),
                        onSelected: (item) {
                          callbackElement['value'] = item.value;
                          onElementCallback(callbackElement);
                        },
                        onChanged: (String value, TextChangedReason reason) {
                          if (value.isNotEmpty && value.length >= 2) {
                            Timer? debounce;
                            if (debounce?.isActive ?? false) debounce?.cancel();
                            debounce = Timer(const Duration(milliseconds: 500),
                                    () async {
                                  var list = await getChoicesByUrl(
                                    value,
                                    callbackElement['choicesByUrl']['url'],
                                  );
                                  for (var l in list) {
                                    choicesList.add(
                                      l['value'].toString(),
                                    );
                                    _listNotifier.value = choicesList;
                                  }
                                });
                          } else {
                            choicesList = [
                              "Select ${callbackElement['title']}"
                            ];
                          }
                        }
                    );
                  }),
            ],
          ));
    }
    else {
      // printSuccess("--------------------------------");
      // printSuccess(callbackElement);
      String? currentSelectedValue =
          ['', null].contains(callbackElement['value'])
              ? 'Select'
              : callbackElement['value'];
      List choices = ["Select"];
      List data = callbackElement['choices'];
      // printSuccess("==========================================================");
      // printSuccess(data.runtimeType);
      for (int i = 0; i < data.length; i++) {
        // printWarning(data[i].runtimeType);
        if (data[i].runtimeType == String) {
          choices.add(data[i]);
          // printWarning("data as List<String>");
          // printError(choices);
        } else {
          // printError(data);
          choices.add(data[i]['value']);
        }
      }
      // printSuccess(choices);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${callbackElement['title']}",
            style: const Typography.raw().caption,
          ),
          const SizedBox(
            height: 10,
          ),
          ComboboxFormField<String>(
            value: currentSelectedValue,
            isExpanded: true,
            placeholder: SizedBox(
              width: 100,
              child: Text(
                callbackElement['title'] +
                    ' ' +
                    (callbackElement['description'] ?? ''),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            items: choices.map<ComboBoxItem<String>>((choice) {
              return ComboBoxItem(
                value: choice,
                child: Text(
                  choice == 'Select'
                      ? '\t - \t ${callbackElement['title']}'
                      : '\t $choice',
                  style: mat.Theme.of(context).textTheme.caption,
                ),
              );
            }).toList(),
            onChanged: (value) {
              currentSelectedValue = value;
              callbackElement['value'] = value;
              onElementCallback(callbackElement);
            },
            validator: (value) {
              if (valueFormResults[elementName]!['isRequired'] ==
                  null) {
                if (value == null || value.isEmpty) {
                  return 'Please enter ${valueFormResults[elementName]!['title']}';
                }
              }
            },
          ),
        ],
      );
    }

    // Call the callback function and pass the callback value
    // onElementCallback(callbackElement);

    // Return an empty Container widget (or any other widget)
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
    final Map<String, dynamic> convertedData = jsonDecode(activeResponse.data!);
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
          .where((elem) => elem['value']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      list.clear();
      list = filteredList.toSet().toList();
    } else {}
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
          .where((elem) => elem['value']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      list.clear();
      list = filteredList.toSet().toList();
      return list;
    } else {
      return [];
    }
  }
}

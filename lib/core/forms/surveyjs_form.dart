import 'package:flutter/material.dart';

import 'form_builder.dart';

class SurveyJSForm {
  final Map schema;
  final Object? results;
  final BuildContext context;
  final AppBar formAppBar;

  const SurveyJSForm({
    required this.schema,
    required this.context,
    required this.formAppBar,
    this.results,
  });

  DefaultTabController createSurveyJSView(){

    List pages = schema['pages'];
    List formElements = [];
    for(var page in pages){
      formElements.add(page['elements']);
    }

    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        appBar: formAppBar,
        body: Column(
          children: <Widget>[
            // the tab bar with pages
            SizedBox(
              height: 50,
              child: AppBar(
                bottom: TabBar(
                  tabs: [
                    //// TODO: Some pages could be invisible
                    for(var page in schema['pages'])
                      Tab(
                        text: page['title'],
                      ),
                  ],
                ),
              ),
            ),

            // create widgets for each tab bar here
            Expanded(
              child: TabBarView(
                children: [
                  // first tab bar view widget
                  for(var page in schema['pages'])
                  FormBuilder(elements: page['elements'], context: context).create()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
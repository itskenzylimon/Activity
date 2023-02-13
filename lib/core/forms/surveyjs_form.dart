import 'package:activity/activity.dart';
import 'package:flutter/material.dart';

import 'form_builder.dart';

class SurveyJSForm {
  final Map schema;
  final ActiveMap<String, Map<String, dynamic>> formResults;
  final BuildContext context;
  final AppBar formAppBar;
  final  VoidCallback onFormSubmit;

  const SurveyJSForm({
    required this.schema,
    required this.context,
    required this.formAppBar,
    required this.formResults,
    required this.onFormSubmit,
  });

   DefaultTabController createSurveyJSView(){

    List pages = schema['service']['schema']['pages'];
    final _formKey = GlobalKey<FormState>();
    printError('Schema Data');
    printError(schema['service']['schema']['pages'][1]);
    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        appBar: formAppBar,
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // the tab bar with pages
              SizedBox(
                height: 50,
                child: AppBar(
                  bottom: TabBar(
                    tabs: [
                      //// TODO: Some pages could be invisible

                      for(var page in schema['service']['schema']['pages'])
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
                    for(var page in schema['service']['schema']['pages'])
                    FormBuilder(elements: page['elements'], context: context, formResults: formResults)
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Validate returns true if the form is valid, or false
                    // otherwise.
                    if (_formKey.currentState!.validate()) {
                      // If the form is valid, display a Snackbar.
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Processing Data')));

                      onFormSubmit.call();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
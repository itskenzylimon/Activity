import 'package:activity/activity.dart';
import 'package:flutter/material.dart';

import 'form_builder.dart';

class SurveyJSForm {
  final Map schema;
  final ActiveMap<String, Map<String, dynamic>> formResults;
  final BuildContext context;
  final VoidCallback onFormSubmit;

  const SurveyJSForm({
    required this.schema,
    required this.context,
    required this.formResults,
    required this.onFormSubmit,
  });

  DefaultTabController createSurveyJSView() {
    List pages = schema['service']['schema']['pages'];
    final _formKey = GlobalKey<FormState>();
    printError('Schema Data');
    printError(schema['service']['schema']['pages'][1]);
    return DefaultTabController(
      length: pages.length,
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              // the tab bar with pages
              SizedBox(
                height: 50,
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  bottom: TabBar(
                    unselectedLabelStyle: const TextStyle(fontSize: 16.0, color: Color(0xff0062E1)),
                    labelStyle: const TextStyle(fontSize: 16.0, color: Color(0xff101828)),
                    labelColor: const Color(0xff0062E1),
                    unselectedLabelColor: const Color(0xff101828),
                    isScrollable: true,
                    tabs: [
                      //// TODO: Some pages could be invisible

                      for (var page in schema['service']['schema']['pages'])
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
                    for (var page in schema['service']['schema']['pages'])
                      FormBuilder(
                          elements: page['elements'], context: context, formResults: formResults)
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

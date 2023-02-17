import 'package:activity/activity.dart';
import 'package:flutter/material.dart';

import 'form_builder.dart';

class SurveyJSForm extends StatefulWidget {
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

  @override
  State<SurveyJSForm> createState() => _SurveyJSFormState();
}

class _SurveyJSFormState extends State<SurveyJSForm> with TickerProviderStateMixin {
  late TabController _controller;

  ValueNotifier<int> _intNotifier = ValueNotifier<int>(0);
  int? initialIndex;
  List? pages;
  var list = [];
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    pages = widget.schema['service']['schema']['pages'];
    initialIndex = _intNotifier.value;
    super.initState();
    _controller = TabController(
      initialIndex: initialIndex!,
      length: pages!.length,
      vsync: this,
    );
    list.followedBy(pages!);
    _controller.index = _intNotifier.value;
  }

  Widget createSurveyJSView() {
    return Scaffold(
      body: ValueListenableBuilder(
          valueListenable: _intNotifier,
          builder: (context, initialIndex, Widget? child) {
            return Form(
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
                        unselectedLabelStyle:
                            const TextStyle(fontSize: 16.0, color: Color(0xff0062E1)),
                        labelStyle: const TextStyle(fontSize: 16.0, color: Color(0xff101828)),
                        labelColor: const Color(0xff0062E1),
                        unselectedLabelColor: const Color(0xff101828),
                        controller: _controller,
                        isScrollable: false,
                        tabs: [
                          //// TODO: Some pages could be invisible

                          for (var page in widget.schema['service']['schema']['pages'])
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
                      physics: NeverScrollableScrollPhysics(),
                      controller: _controller,
                      children: [
                        // first tab bar view widget
                        for (var page in widget.schema['service']['schema']['pages'])
                          FormBuilder(
                              elements: page['elements'],
                              context: context,
                              formResults: widget.formResults)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: _controller.index == pages!.length - 1 ?
                      Visibility(
                                visible: _controller.index == pages!.length - 1 ,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end, children: [
                                    Previous(
                                        formKey: _formKey,
                                        context: context,
                                        onPrevious: () {
                                          setState(() {
                                            if (_controller.index > 0) {
                                              _controller.index -= 1;
                                            }
                                          });
                                          _intNotifier.notifyListeners();
                                          printSuccess("_controller.index");
                                          printSuccess(_controller.index);
                                        }),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    SubmitButton(
                                        formKey: _formKey,
                                        context: context,
                                        onFormSubmit: widget.onFormSubmit),
                                  ]),
                              ):
                      
                      _controller.index == 0 
                          ? Visibility(
                            visible: _controller.index == 0,
                            child: Next(
                                formKey: _formKey,
                                context: context,
                                onNext: () {
                                  setState(() {
                                    if (_controller.index < pages!.length - 1) {
                                      _controller.index += 1;
                                    }
                                  });
                                  _intNotifier.notifyListeners();
                                  printSuccess("_controller.index");
                                  printSuccess(_controller.index);
                                  printSuccess(pages!.length - 1);
                                }),
                          )
                          : _controller.index > 1 && _controller.index < pages!.length
                              ? Visibility(
                                visible: _controller.index > 1 && _controller.index < pages!.length -1 ,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end, children: [
                                    Previous(
                                        formKey: _formKey,
                                        context: context,
                                        onPrevious: () {
                                          setState(() {
                                            if (_controller.index > 0) {
                                              _controller.index -= 1;
                                            }
                                          });
                                          _intNotifier.notifyListeners();
                                          printSuccess("_controller.index");
                                          printSuccess(_controller.index);
                                        }),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Next(
                                        formKey: _formKey,
                                        context: context,
                                        onNext: () {
                                          setState(() {
                                            if (_controller.index < (pages!.length - 1)) {
                                              _controller.index += 1;
                                            }
                                          });
                                          _intNotifier.notifyListeners();
                                          printSuccess("_controller.index");
                                          printSuccess(_controller.index);
                                          printSuccess(pages!.length - 1);
                                        }),
                                  ]),
                              ) : Visibility(
                            visible: _controller.index == 0,
                            child: Next(
                                formKey: _formKey,
                                context: context,
                                onNext: () {
                                  setState(() {
                                    if (_controller.index < pages!.length - 1) {
                                      _controller.index += 1;
                                    }
                                  });
                                  _intNotifier.notifyListeners();
                                  printSuccess("_controller.index");
                                  printSuccess(_controller.index);
                                  printSuccess(pages!.length - 1);
                                }),
                          )
                              
                              
                              
                                 
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return createSurveyJSView();
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
      width: 150,
      height: 40,
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
      width: 150,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          onNext();
          // Validate returns true if the form is valid, or false
          // otherwise.
          // if (_formKey.currentState!.validate()) {
          //   // If the form is valid, display a Snackbar.
          //   ScaffoldMessenger.of(context)
          //       .showSnackBar(const SnackBar(content: Text('Processing Data')));

          //   onNext.call();
          // }
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
      width: 150,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
          onPrevious.call();
          // Validate returns true if the form is valid, or false
          // otherwise.
          // if (_formKey.currentState!.validate()) {
          //   // If the form is valid, display a Snackbar.
          //   ScaffoldMessenger.of(context)
          //       .showSnackBar(const SnackBar(content: Text('Processing Data')));

          // }
        },
        child: const Text('Previous'),
      ),
    );
  }
}

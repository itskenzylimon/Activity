import 'package:flutter/cupertino.dart';

import '../forms/form_builder.dart';

class ActiveForm<Map> {

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map? results;
  final List elements;
  final Center? column;

  const ActiveForm({
    this.createdAt,
    this.updatedAt,
    this.results,
    this.column,
    required this.elements,
  });

  Center create(BuildContext context) {
    FormBuilder formBuilder = FormBuilder(
        context: context,
        elements: elements,
        results: results ?? {}
    );
    return formBuilder.create();
  }
}


/// Schema Response is a simple class that helps to check if the data
/// is valid or not. It also returns the schema used for validation
class SchemaResponse {
  /// true if the data is valid, false otherwise
  bool valid;
  /// the schema used for validation
  Map<String, dynamic> schema;
  /// errors if the data is invalid
  Map<String, dynamic> errors;

  SchemaResponse({
    required this.valid,
    required this.schema,
    required this.errors,
  });

  @override
  String toString() {
    return "( ${valid ? 'Success' : 'Failed'} ) \n "
        "${valid ? schema : errors}";
  }
}

/// Schema Validator is a simple class that helps you validate your data
/// against a schema. It is useful for validating data before sending to
/// a server or saving to a database.
class SchemaValidator {

  final Map<String, dynamic> _schema;

  SchemaValidator(this._schema);

  /// custom errors should match with the specified schema key
  /// customErrors['key'] == schema['key'] for it to show your custom errors.
  Map<String, String>? customErrors;

  SchemaResponse validate(Map<String, dynamic> data) {

    Map<String, dynamic> validatedSchema = data;
    Map<String, dynamic> errorSchema = {};

    for (String key in _schema.keys) {
      final validations = _schema[key];
      if (validations['required'] && !data.containsKey(key)) {
        errorSchema.putIfAbsent(key, () => customErrors == null ?
        "$key field is required" :
        customErrors!.containsKey(key) ?
        "${customErrors![key]}" : "$key field is required");
      }
      if (!data.containsKey(key)) {
        continue;
      }
      final value = data[key];
      if (validations['type'] != null &&
          validations['type'] != value.runtimeType) {
        errorSchema.putIfAbsent(key, () => customErrors == null ?
        "$key field type is not valid" :
        customErrors!.containsKey(key) ?
        "${customErrors![key]}" : "$key field type is not valid");
      }

      if (validations['min'] != null &&
          [double, int].contains(value.runtimeType) &&
          value < validations['min']) {
        errorSchema.putIfAbsent(key, () => customErrors == null ?
        "$key field value is less than the minimum limit" :
        customErrors!.containsKey(key) ?
        "${customErrors![key]}" : "$key field value is less than the minimum limit");
      }

      if (validations['min'] != null &&
          [String].contains(value.runtimeType) &&
          value.length < validations['min']) {
        errorSchema.putIfAbsent(key, () => customErrors == null ?
        "$key field value is less than the minimum limit" :
        customErrors!.containsKey(key) ?
        "${customErrors![key]}" : "$key field value is less than the minimum limit");
      }

      if (validations['max'] != null &&
          [double, int].contains(value.runtimeType)
          && value > validations['max']) {
        errorSchema.putIfAbsent(key, () => customErrors == null ?
        "$key field value is greater than the maximum limit" :
        customErrors!.containsKey(key) ?
        "${customErrors![key]}" : "$key field value is greater than the maximum limit");
      }

      if (validations['max'] != null &&
          [String].contains(value.runtimeType) &&
          value.length > validations['max']) {
        errorSchema.putIfAbsent(key, () => customErrors == null ?
        "$key field value is greater than the maximum limit" :
        customErrors!.containsKey(key) ?
        "${customErrors![key]}" : "$key field value is greater than the maximum limit");
      }

      if (validations['email'] != null && validations['email']) {
        final emailRegex = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
        if (!emailRegex.hasMatch(value)) {
          errorSchema.putIfAbsent(key, () => customErrors == null ?
          "$key field is not a valid email address" :
          customErrors!.containsKey(key) ?
          "${customErrors![key]}" : "$key field is not a valid email address");
        }
      }

      if (validations['phone'] != null && validations['phone']) {
        final phoneRegex = RegExp(r'^(?:[+0]9)?[0-9]{10}$');
        if (!phoneRegex.hasMatch(value)) {
          errorSchema.putIfAbsent(key, () => customErrors == null ?
          "$key field is not a valid phone number" :
          customErrors!.containsKey(key) ?
          "${customErrors![key]}" : "$key field is not a valid phone number");
        }
      }

      if (validations['date'] != null && validations['date']) {
        try {
          DateTime.parse(value);
        } catch (e) {
          errorSchema.putIfAbsent(key, () => customErrors == null ?
          "$key field is not a valid date" :
          customErrors!.containsKey(key) ?
          "${customErrors![key]}" : "$key field is not a valid date");
        }
      }

      if(errorSchema.containsKey(key)){
        validatedSchema.remove(key);
      }
    }

    SchemaResponse schemaResponse =
    SchemaResponse(
        valid: errorSchema.isEmpty ? true : false,
        schema: validatedSchema,
        errors: errorSchema
    );
    return schemaResponse;
  }
}
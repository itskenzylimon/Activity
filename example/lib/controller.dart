import 'dart:convert';
import 'dart:io';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'model.dart';

class MainController extends ActiveController {
  GlobalKey globalKey = GlobalKey<FormState>();

  /// Initialise area
  // Memory memory = Memory(filename: '${Directory.current.path}/data3.json');
  Memory memory = Memory.memory;

  /// Assign Active values
  /// You can ideally check
  /// ActiveString extend the normal String Type with activity helper functions
  ActiveString appTitle = ActiveString('First Title');

  /// Active int extend the normal int Type with activity helper functions
  ActiveInt appBarSize = ActiveInt(45);
  ActiveInt pageNumber = ActiveInt(1);
  ActiveInt pageSize = ActiveInt(2);

  /// Active bool extend the normal int Type with activity helper functions
  ActiveBool dataLoaded = ActiveBool(false);

  /// ActiveType is a Type any with activity helper functions
  ActiveType appBackgroundColor = ActiveType(Colors.white);

  ActiveList<ActiveModel<Task>> tasks = ActiveList([
    ActiveModel(Task(
        name: 'Test Task',
        body: 'Complete this amazing package',
        level: 100,
        user: User(name: 'Kenzy Limon', email: 'itskenzylimon@gmail.com')))
  ]);

  @override
  List<ActiveType> get activities {
    return [appTitle, appBarSize, dataLoaded];
  }

  void updateUI() async {
    appTitle.set('New Title');
  }

  /// This is a simple Object that we use against our schema to validate
  /// data type and our desired setup.
  var sampleJSON = {
    "email": "johndoegmail.com",
    "phone": "2541234567",
    "birthdate": "2020-01-01",
    "address": "Area 254",
    "name": "Test"
  };

  /// This is the schema definition.
  /// Activity allows String, Numbers, bool, Date, Email and Phone validations
  /// apart from those activity also supports max and Min with optional and
  /// mandatory fields.
  var registerSchema = {
    "name": {"type": String, "required": true, "min": 2, "max": 20},
    "email": {
      "type": String,
      "required": true,
      "email": true,
    },
    "phone": {
      "type": String,
      "required": true,
      "phone": true,
    },
    "birthdate": {
      "type": String,
      "required": true,
      "date": true,
    },
    "address": {"type": String, "required": true, "min": 5, "max": 100}
  };

  /// You can pass your own [customErrorMessage] custom error messages to make
  /// the return errors more readable and friendlier.
  /// Keys have to match the ones on [Schema] and You [Object] Payload.
  var customErrorMessage = {
    'name': 'Kindly Enter your Full Names',
    'birthdate': 'Enter a valid date',
  };

  validateJSON() async {
    SchemaValidator schemaValidator = SchemaValidator(registerSchema);
    // schemaValidator.customErrors = customErrorMessage;

    SchemaResponse schemaResponse = schemaValidator.validate(sampleJSON);
    if (schemaResponse.valid == false) {
      printError(schemaResponse.toString());
    } else {
      printSuccess(schemaResponse.toString());
    }
  }

  dataTypes() {
    /// Boolean
    /// The [typeName] can be any key you assign the type to.
    /// It can really help when you want to update a value based on the
    /// assigned [typeName]
    /// [ActiveBool] extends the dart bool, meaning you can enjoy the benefits
    /// of the built in bool functions
    /// [Activity] will allow you to update anywhere on the app code and rebuild UI
    /// for the affected widgets Only
    ///
    ActiveBool activeBool = ActiveBool(false, typeName: 'keyFlag');

    /// [isTrue] flag checks if ActiveBool is true
    activeBool.isTrue;

    /// You can easily [reset] ActiveBool back to original value
    /// [notifyChange] flag allows you choose if you want the change
    /// to be updated on the affected widgets.
    activeBool.reset(notifyChange: true);

    /// You can do updates to a field using [set] func, this will do the update
    /// and do the ui rebuild on the affected widgets.
    /// passing [notifyChange] as false will not do a UI rebuild
    /// passing [setAsOriginal] as true will set the new value as
    /// the original value.
    activeBool.set(true, notifyChange: false, setAsOriginal: true);

    /// [setTrue] will set [ActiveBool] value to true
    activeBool.setTrue();

    /// [setFalse] will set [ActiveBool] value to false
    activeBool.setFalse();

    /// [value] will give you the current value
    activeBool.value;

    /// DateTime
    /// The [typeName] can be any key you assign the type to.
    /// It can really help when you want to update a value based on the
    /// assigned [typeName]
    /// [ActiveDateTime] extends the dart bool, meaning you can enjoy the benefits
    /// of the built in DateTime functions
    /// [Activity] will allow you to update anywhere on the app code and rebuild UI
    /// for the affected widgets Only
    ActiveDateTime activeDateTime =
        ActiveDateTime(DateTime.now(), typeName: 'dateOfBirth');

    /// You can easily [setOriginalValueToCurrent] ActiveDateTime back to original value
    activeDateTime.setOriginalValueToCurrent();
    activeDateTime.reset(notifyChange: true);

    /// You can do updates to a field using [set] func, this will do the update
    /// and do the ui rebuild on the affected widgets.
    /// passing [notifyChange] as false will not do a UI rebuild
    /// passing [setAsOriginal] as true will set the new value as
    /// the original value.
    activeDateTime.set(DateTime.now().subtract(const Duration(days: 10)),
        notifyChange: false, setAsOriginal: true);

    /// [value] will give you the current value
    activeDateTime.value;

    /// Double
    /// The [typeName] can be any key you assign the type to.
    /// It can really help when you want to update a value based on the
    /// assigned [typeName]
    /// [ActiveDateTime] extends the dart bool, meaning you can enjoy the benefits
    /// of the built in DateTime functions
    /// [Activity] will allow you to update anywhere on the app code and rebuild UI
    /// for the affected widgets Only
    ActiveDouble activeDouble = ActiveDouble(1.5, typeName: 'rate'); // 1.5

    /// You can easily [setOriginalValueToCurrent] ActiveDateTime back to original value
    activeDouble.setOriginalValueToCurrent();
    activeDouble.reset(notifyChange: true);

    /// checks if the value is negative and returns a bool type
    activeDouble.isNegative;

    /// this converts a double to an int value
    activeDouble.toInt;

    /// this will add 0.5 to the current value and does the needed updates
    activeDouble.add(0.5); // 2.0

    /// this will subtract 1.0 to the current value and does the needed updates
    activeDouble.subtract(1.0); // 1.0

    /// this will divide 1.0 by 0.5 to the current value and does the needed updates
    activeDouble.divide(0.5); // 2.0

    /// this will multiply the value with 4 to the current value and does the needed updates
    activeDouble.multiply(4); // 8.0

    /// You can do updates to a field using [set] func, this will do the update
    /// and do the ui rebuild on the affected widgets.
    /// passing [notifyChange] as false will not do a UI rebuild
    /// passing [setAsOriginal] as true will set the new value as
    /// the original value.
    activeDouble.set(99.99, notifyChange: false, setAsOriginal: true);

    /// [value] will give you the current value
    activeDouble.value;

    /// INT
    /// The [typeName] can be any key you assign the type to.
    /// It can really help when you want to update a value based on the
    /// assigned [typeName]
    /// [ActiveDateTime] extends the dart bool, meaning you can enjoy the benefits
    /// of the built in DateTime functions
    /// [Activity] will allow you to update anywhere on the app code and rebuild UI
    /// for the affected widgets Only
    ActiveInt activeInt = ActiveInt(100, typeName: 'score'); // 1.5

    /// You can easily [setOriginalValueToCurrent] ActiveDateTime back to original value
    activeInt.setOriginalValueToCurrent();
    activeInt.reset(notifyChange: true);

    /// checks if the value is negative and returns a bool type
    activeInt.isNegative;

    /// checks if the value is positive and returns a bool type
    activeInt.isEven;

    /// increments the value by 1
    activeInt.increment();

    /// increments the value by 1
    activeInt.increment();

    /// this converts an int to double value
    activeInt.toDouble();

    /// this converts an int to a string value
    activeInt.toString();

    /// this will add 0.5 to the current value and does the needed updates
    activeInt.add(15); // 115

    /// this will subtract 10 to the current value and does the needed updates
    activeInt.subtract(10); // 95

    /// this will divide 1.0 by 0.5 to the current value and does the needed updates
    activeInt.divide(5); // 21

    /// this will multiply the value with 4 to the current value and does the needed updates
    activeInt.multiply(4); // 84

    /// You can do updates to a field using [set] func, this will do the update
    /// and do the ui rebuild on the affected widgets.
    /// passing [notifyChange] as false will not do a UI rebuild
    /// passing [setAsOriginal] as true will set the new value as
    /// the original value.
    activeInt.set(50, notifyChange: false, setAsOriginal: true);

    /// [value] will give you the current value
    activeInt.value;

    /// List
    /// The [typeName] can be any key you assign the type to.
    /// It can really help when you want to update a value based on the
    /// assigned [typeName]
    /// [ActiveList] extends the dart bool, meaning you can enjoy the benefits
    /// of the built in List functions
    /// [Activity] will allow you to update anywhere on the app code and rebuild UI
    /// for the affected widgets Only
    ActiveList activeList = ActiveList([1, 2, 3], typeName: 'score'); // 1.5

    /// You can easily [setOriginalValueToCurrent] ActiveDateTime back to original value
    activeList.setOriginalValueToCurrent();
    activeList.reset(notifyChange: true);

    /// You can do updates to a field using [set] func, this will do the update
    /// and do the ui rebuild on the affected widgets.
    /// passing [notifyChange] as false will not do a UI rebuild
    /// passing [setAsOriginal] as true will set the new value as
    /// the original value.
    activeList.set([0, 9, 8], notifyChange: false, setAsOriginal: true);

    /// [value] will give you the current value
    activeList.value;

    /// Map
    /// The [typeName] can be any key you assign the type to.
    /// It can really help when you want to update a value based on the
    /// assigned [typeName]
    /// [ActiveMap] extends the dart bool, meaning you can enjoy the benefits
    /// of the built in Map functions
    /// [Activity] will allow you to update anywhere on the app code and rebuild UI
    /// for the affected widgets Only
    ActiveMap activeMap = ActiveMap({'key': 123}, typeName: 'score'); // 1.5

    /// You can easily [setOriginalValueToCurrent] ActiveDateTime back to original value
    activeMap.setOriginalValueToCurrent();
    activeMap.reset(notifyChange: true);

    /// You can do updates to a field using [set] func, this will do the update
    /// and do the ui rebuild on the affected widgets.
    /// passing [notifyChange] as false will not do a UI rebuild
    /// passing [setAsOriginal] as true will set the new value as
    /// the original value.
    activeMap.set({'key': 100}, notifyChange: false, setAsOriginal: true);

    /// [value] will give you the current value
    activeMap.value;
  }

  syncMemory() async {
    // await memory.syncMemory();
  }

  /// How to start a local server on your io device with routing
  /// Create requestApis
  Future<Map<ContentType, dynamic>> homePage(HttpRequest request) async {
    try {
      var fileContents = await rootBundle.loadString('assets/index.html');
      // var fileContents = await File('/assets/index.html').readAsString().then((fileData) {
      //   return fileData;
      // });
      return {ContentType.html: fileContents};
    } catch (e) {
      printError(e);
      return {ContentType.json: notFoundPage(request)};
    }
  }

  Map<ContentType, dynamic> aboutPage(HttpRequest request) {
    return {
      ContentType.json: {
        'url': request.uri.path,
        'key': 'Hello, World!... This is about us!'
      }
    };
  }

  Map<ContentType, dynamic> contactUsPage(HttpRequest request) {
    return {
      ContentType.json: {
        'url': request.uri.path,
        'key': 'Hello, World!... This is contact us!'
      }
    };
  }

  Map<ContentType, dynamic> notFoundPage(HttpRequest request) {
    var json = jsonEncode(
        {'url': request.uri.path, 'key': 'Hello, World!... Not found!'});

    return {ContentType.json: json};
  }

  /// Map request to response
  Future<Map<ContentType, dynamic>> httpRequests(
      HttpRequest httpRequest) async {
    switch (httpRequest.uri.path) {
      case '/':
        return homePage(httpRequest);
        break;

      case '/contactus':
        return aboutPage(httpRequest);
        break;

      case '/about':
        return contactUsPage(httpRequest);
        break;

      default:
        return notFoundPage(httpRequest);
        break;
    }
  }

  startServer() {
    HttpServer.bind(InternetAddress.anyIPv4, 3000).then((server) {
      printInfo('Listening on localhost:${server.port}');

      /// Start a server
      server.listen((HttpRequest httpRequest) async {
        Map<ContentType, dynamic> response = await httpRequests(httpRequest);
        var data = response.values.first;
        var type = response.keys.first;
        printNormal(data);
        httpRequest.response
          ..headers.contentType = type
          ..statusCode = 200
          ..write(data)
          ..close();
      });
    });
  }

  Map schema = {
    "completedHtml": "<h3>Record submission successful</h3>",
    "pages": [
      {
        "elements": [
          {
            "name": "OrganizationName",
            "readOnly": true,
            "title": "Organization Name",
            "type": "text"
          },
          {
            "name": "OrganizationRegistrationNumber",
            "readOnly": true,
            "startWithNewLine": false,
            "title": "Organization Registration Number",
            "type": "text"
          },
          {
            "name": "County",
            "readOnly": true,
            "title": "County",
            "type": "text"
          },
          {
            "name": "SubCounty",
            "readOnly": true,
            "startWithNewLine": false,
            "title": "Sub County",
            "type": "text"
          },
          {
            "elements": [
              {
                "name": "InformantFullName",
                "title": "Full Name",
                "type": "text"
              },
              {
                "name": "InformantIdentificationNumber1",
                "startWithNewLine": false,
                "title": "Identification Number",
                "type": "text"
              },
              {
                "inputType": "number",
                "name": "InformantPhoneNumber",
                "placeholder": "+254700000000",
                "title": "Phone Number",
                "type": "text"
              },
              {
                "inputType": "email",
                "name": "InformantEmailAddress",
                "placeholder": "abc@xyz.com",
                "startWithNewLine": false,
                "title": "Email Address",
                "type": "text"
              },
              {
                "name": "InformantDesignation",
                "placeholder": "eg medical practitioner",
                "title": "Designation",
                "type": "text"
              }
            ],
            "name": "InformantDetails",
            "title": "Informant Details",
            "type": "panel",
            "visible": false
          },
          {
            "choices": ["NO", "YES"],
            "description": "(Mandatory)",
            "isRequired": true,
            "name": "IsthechildAbandoned",
            "title": "Is this a registration relating to an Abandoned child?",
            "type": "radiogroup"
          }
        ],
        "name": "General Information",
        "title": "General Information"
      },
      {
        "elements": [
          {
            "elements": [
              {
                "choices": [
                  "Adult (Above 18 years)",
                  "Minor (below 18years)",
                  "Not Able to Access Identification Document"
                ],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "CategoryOfMother",
                "title": "Category Of Mother",
                "type": "dropdown"
              },
              {
                "choices": ["Citizen", "Foreigner", "Alien"],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherTypeofNationality",
                "title": "Type of Nationality",
                "type": "dropdown",
                "visibleIf":
                    "{CategoryOfMother} anyof ['Adult (Above 18 years)', 'Minor (below 18years)']"
              },
              {
                "displayTemplate":
                    "<h4 class = \"bg-white text-dark border rounded \n p-3\">\nKENYAN\n<h4>",
                "name": "Nationality",
                "title": "Nationality",
                "type": "genericquestion",
                "visibleIf": "{MotherTypeofNationality} anyof ['Citizen']"
              },
              {
                "description": "(Mandatory)",
                "lookupDataTemplateId": "054353fb-9938-4e63-a7ad-a11c3ac83b5e",
                "lookupServiceId": 2,
                "name": "IPRSLookup",
                "outputs": [
                  {
                    "text": "<<result.id_number>>",
                    "value": "MotherIdentificationNumber"
                  },
                  {"text": "<<result.first_name>>", "value": "MotherFirstName"},
                  {
                    "text": "<<result.other_name>>",
                    "value": "MotherMiddleName"
                  },
                  {"text": "<<result.surname>>", "value": "MotherFathersName"},
                  {"text": "<<result.dob>>", "value": "MotherDateofBirth"},
                  {"text": "<<result.dob>>", "value": "motherAgeAtBirth"}
                ],
                "title": "IPRS Lookup",
                "type": "httplookup",
                "visibleIf":
                    "{MotherTypeofNationality} anyof ['Citizen', 'Alien'] and {CategoryOfMother} anyof ['Adult (Above 18 years)']"
              },
              {
                "description": "Identification Number/Passport Number",
                "enableIf": "{MotherTypeofNationality} anyof ['Foreigner']",
                "name": "MotherIdentificationNumber",
                "title": "Identification Number",
                "type": "text",
                "visibleIf":
                    "{CategoryOfMother} anyof ['Adult (Above 18 years)'] and {MotherTypeofNationality} anyof ['Citizen', 'Alien', 'Foreigner']"
              },
              {
                "enableIf":
                    "{MotherTypeofNationality} anyof ['Foreigner'] or {CategoryOfMother} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "isRequired": true,
                "name": "MotherFirstName",
                "title": "First Name",
                "type": "text"
              },
              {
                "enableIf":
                    "{MotherTypeofNationality} anyof ['Foreigner'] or {CategoryOfMother} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "name": "MotherMiddleName",
                "startWithNewLine": false,
                "title": "Middle Name",
                "type": "text"
              },
              {
                "enableIf":
                    "{MotherTypeofNationality} anyof ['Foreigner'] or {CategoryOfMother} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "isRequired": true,
                "name": "MotherFathersName",
                "startWithNewLine": false,
                "title": "Father's Name",
                "type": "text"
              },
              {
                "description": "(Mandatory)",
                "inputType": "number",
                "isRequired": true,
                "max": "17",
                "min": "1",
                "name": "motherAge",
                "title": "Mother's Age at the time of Birth",
                "type": "text",
                "visibleIf":
                    "{CategoryOfMother} anyof ['Minor (below 18years)', 'Not Able to Access Identification Document'] or {MotherTypeofNationality} anyof ['Foreigner']"
              },
              {
                "dateFormat": "MM/DD/YYYY hh:mm:ss",
                "dateInterval": "years",
                "name": "motherAgeAtBirth",
                "readOnly": true,
                "title": "Mother's Age at the time of Birth",
                "type": "agecalc",
                "visibleIf":
                    "{CategoryOfMother} anyof ['Adult (Above 18 years)'] and {MotherTypeofNationality} anyof ['Citizen']"
              },
              {
                "choices": ["Married", "Single", "Divorced", "Widowed"],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherMaritalStatus",
                "startWithNewLine": false,
                "title": "Marital Status",
                "type": "dropdown"
              },
              {
                "blockFutureDates": true,
                "name": "MotherDateofBirth",
                "title": "Date Of Birth",
                "type": "bsdatepicker",
                "visible": false
              },
              {
                "choicesByUrl": {
                  "titleName": "text",
                  "url":
                      "https://crs.pesaflow.com/resources/download/nationality",
                  "valueName": "value"
                },
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherNationality",
                "renderAs": "select2",
                "title": "Nationality",
                "type": "dropdown",
                "visibleIf":
                    "{MotherTypeofNationality} anyof ['Foreigner', 'Alien']"
              },
              {
                "choices": ["Yes", "No"],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "Hasthemotherpreviouslychangedhername",
                "title": "Has the mother previously changed her name?",
                "type": "dropdown"
              },
              {
                "isRequired": true,
                "name": "InitialFullName",
                "title": "Initial Full Name ",
                "type": "text",
                "visibleIf": "{Hasthemotherpreviouslychangedhername} = 'Yes'"
              },
              {
                "isRequired": true,
                "name": "MotherOccupation",
                "placeholder": "e.g Teacher",
                "title": "Occupation",
                "type": "text"
              },
              {
                "choices": [
                  "Uneducated",
                  "Primary School",
                  "Secondary School",
                  "Certificate",
                  "Diploma",
                  "Undergraduate",
                  "Masters",
                  "PHD"
                ],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherLevelOfEducation",
                "showOtherItem": true,
                "startWithNewLine": false,
                "title": "Level Of Education",
                "type": "dropdown"
              },
              {
                "choicesByUrl": {
                  "titleName": "text",
                  "url": "https://crs.pesaflow.com/resources/download/county",
                  "valueName": "value"
                },
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherCounty",
                "title": "County of Residence",
                "type": "dropdown"
              },
              {
                "choicesByUrl": {
                  "path": "{MotherCounty}",
                  "titleName": "text",
                  "url":
                      "https://crs.pesaflow.com/resources/download/sub-county",
                  "valueName": "value"
                },
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "MotherSubcounty",
                "startWithNewLine": false,
                "title": "Subcounty of Residence",
                "type": "dropdown"
              },
              {
                "name": "MotherUsualResidence",
                "placeholder": "e.g Buru Buru Phase X House Number Y",
                "title": "Usual Residence",
                "type": "comment"
              },
              {
                "isRequired": true,
                "maxErrorText": "Invalid format 12 digits e.g +254700000000",
                "minErrorText": "Invalid format 12 digits e.g +254700000000",
                "name": "motherMobileNumber",
                "placeholder": "+2547200000000",
                "requiredErrorText":
                    "Invalid format 12 digits e.g +254700000000",
                "title": "Mobile Number",
                "type": "text",
                "validators": [
                  {
                    "regex": "^[+][0-9]{12}\$",
                    "text": "Invalid format 12 digits e.g +254700000000",
                    "type": "regex"
                  }
                ]
              },
              {
                "name": "motherEmail",
                "placeholder": "abc@xyz.com",
                "startWithNewLine": false,
                "title": "Email",
                "type": "text"
              },
              {
                "name": "InPatientNumber",
                "title": "In Patient Number",
                "type": "text"
              },
              {
                "acceptedTypes": ".PDF",
                "description": "(PDF)",
                "isRequired": true,
                "name": "bioData",
                "storeDataAsText": false,
                "title": "Attach Passport Bio-Data Page",
                "type": "file",
                "visibleIf": "{MotherTypeofNationality} anyof ['Foreigner']"
              }
            ],
            "name": "Mother",
            "title": "Mother",
            "type": "panel"
          },
          {
            "elements": [
              {
                "choices": [
                  "None",
                  "1",
                  "2",
                  "3",
                  "4",
                  "5",
                  "6",
                  "7",
                  "8",
                  "9",
                  "10",
                  "11",
                  "12",
                  "13",
                  "14",
                  "15",
                  "16",
                  "17",
                  "18",
                  "19",
                  "20"
                ],
                "name": "NumberBornAlive",
                "title": "Number Born Alive",
                "type": "dropdown"
              },
              {
                "choices": [
                  "None",
                  "1",
                  "2",
                  "3",
                  "4",
                  "5",
                  "6",
                  "7",
                  "8",
                  "9",
                  "10",
                  "11",
                  "12",
                  "13",
                  "14",
                  "15",
                  "16",
                  "17",
                  "18",
                  "19",
                  "20"
                ],
                "name": "NumberBornDead",
                "startWithNewLine": false,
                "title": "Number Born Dead",
                "type": "dropdown"
              }
            ],
            "name": "PreviousBirthsToMother",
            "title": "Previous Births To Mother",
            "type": "panel"
          }
        ],
        "name": "Mother's Information",
        "title": "Mother's Information",
        "visibleIf": "{IsthechildAbandoned} anyof ['NO']"
      },
      {
        "elements": [
          {
            "elements": [
              {
                "choices": ["Yes", "No"],
                "name": "named",
                "title": "Has the child been named?",
                "type": "dropdown"
              },
              {
                "name": "ChildFirstName",
                "title": "First Name",
                "type": "text",
                "visibleIf": "{named} anyof ['Yes']"
              },
              {
                "name": "ChildOtherName",
                "startWithNewLine": false,
                "title": "Other  Name(s)",
                "type": "text",
                "visibleIf": "{named} anyof ['Yes']"
              },
              {
                "name": "ChildFathersName",
                "startWithNewLine": false,
                "title": "Fathers Name",
                "type": "text",
                "visibleIf":
                    "{named} anyof ['Yes'] and {MotherMaritalStatus} anyof ['Married', 'Divorced', 'Widowed']"
              },
              {
                "blockFutureDates": true,
                "isRequired": true,
                "maxDays": -183,
                "name": "ChildDateOfBirth",
                "title": "Date Of Birth",
                "type": "bsdatepicker"
              },
              {
                "choices": ["Male", "Female"],
                "isRequired": true,
                "name": "Sex",
                "showOtherItem": true,
                "startWithNewLine": false,
                "title": "Sex",
                "type": "dropdown"
              },
              {
                "choices": ["Single", "Twins"],
                "name": "TypeOfBirth",
                "showOtherItem": true,
                "title": "Type Of Birth",
                "type": "dropdown"
              },
              {
                "choices": ["Born Alive", "Born Dead"],
                "isRequired": true,
                "name": "NatureOfBirth",
                "startWithNewLine": false,
                "title": "Nature Of Birth",
                "type": "dropdown"
              }
            ],
            "name": "DetailsOfTheChild",
            "type": "panel"
          },
          {
            "elements": [
              {
                "choices": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
                "name": "Kilograms",
                "title": "Kilograms(kgs)",
                "type": "dropdown"
              },
              {
                "choices": [
                  "100",
                  "200",
                  "300",
                  "400",
                  "500",
                  "600",
                  "700",
                  "800",
                  "900"
                ],
                "name": "Grams",
                "showOtherItem": true,
                "startWithNewLine": false,
                "title": "Grams",
                "type": "dropdown"
              }
            ],
            "name": "WeightOfBirth",
            "title": "Weight Of Birth",
            "type": "panel"
          }
        ],
        "name": "Childs Information",
        "title": "Childs Information"
      },
      {
        "elements": [
          {
            "choices": ["Yes", "No"],
            "description": "(Mandatory)",
            "name": "Isthefathersinformationavailable",
            "title": "Is the father's information available?",
            "type": "dropdown"
          },
          {
            "elements": [
              {
                "choices": [
                  "Adult (Above 18 years)",
                  "Minor (below 18years)",
                  "Not Able to Access Identification Document"
                ],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "CategoryOfFather",
                "title": "Category Of Father",
                "type": "dropdown"
              },
              {
                "choices": ["Citizen", "Foreigner", "Alien"],
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "FatherTypeofNationality",
                "title": "Type of Nationality",
                "type": "dropdown",
                "visibleIf":
                    "{CategoryOfFather} anyof ['Adult (Above 18 years)', 'Minor (below 18years)']"
              },
              {
                "displayTemplate":
                    "<h4 class = \"bg-white text-dark border rounded \n p-3\">\nKENYAN\n<h4>",
                "name": "Nationality",
                "title": "Nationality",
                "type": "genericquestion",
                "visibleIf": "{FatherTypeofNationality} anyof ['Citizen']"
              },
              {
                "description": "(Mandatory)",
                "lookupDataTemplateId": "054353fb-9938-4e63-a7ad-a11c3ac83b5e",
                "lookupServiceId": 2,
                "name": "IPRSLookup",
                "outputs": [
                  {
                    "text": "<<result.id_number>>",
                    "value": "FatherIdentificationNumber"
                  },
                  {"text": "<<result.first_name>>", "value": "FatherFirstName"},
                  {
                    "text": "<<result.other_name>>",
                    "value": "FatherMiddleName"
                  },
                  {"text": "<<result.surname>>", "value": "FatherFathersName"},
                  {"text": "<<result.dob>>", "value": "FatherDateOfBirth"}
                ],
                "title": "IPRS Lookup",
                "type": "httplookup",
                "visibleIf":
                    "{FatherTypeofNationality} anyof ['Citizen', 'Alien'] and {CategoryOfFather} anyof ['Adult (Above 18 years)']"
              },
              {
                "description": "ID/Passport Number",
                "enableIf": "{FatherTypeofNationality} anyof ['Foreigner']",
                "name": "FatherIdentificationNumber",
                "title": "Identification Number",
                "type": "text",
                "visibleIf":
                    "{FatherTypeofNationality} anyof ['Citizen', 'Alien', 'Foreigner'] and {CategoryOfFather} anyof ['Adult (Above 18 years)']"
              },
              {
                "enableIf":
                    "{FatherTypeofNationality} anyof ['Foreigner'] or {CategoryOfFather} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "isRequired": true,
                "name": "FatherFirstName",
                "title": "First Name",
                "type": "text"
              },
              {
                "enableIf":
                    "{FatherTypeofNationality} anyof ['Foreigner'] or {CategoryOfFather} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "name": "FatherMiddleName",
                "startWithNewLine": false,
                "title": "Middle Name",
                "type": "text"
              },
              {
                "enableIf":
                    "{FatherTypeofNationality} anyof ['Foreigner'] or {CategoryOfFather} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                "name": "FatherFathersName",
                "readOnly": true,
                "startWithNewLine": false,
                "title": "Father's Name",
                "type": "text"
              },
              {
                "choicesByUrl": {
                  "titleName": "text",
                  "url":
                      "https://crs.pesaflow.com/resources/download/nationality",
                  "valueName": "value"
                },
                "description": "(Mandatory)",
                "isRequired": true,
                "name": "FatherNationality",
                "renderAs": "select2",
                "title": "Nationality",
                "type": "dropdown",
                "visibleIf":
                    "{FatherTypeofNationality} anyof ['Foreigner', 'Alien']"
              },
              {
                "maxErrorText": "Invalid format 12 digits e.g +254700000000",
                "minErrorText": "Invalid format 12 digits e.g +254700000000",
                "name": "fatherMobileNumber",
                "placeholder": "+254720217295",
                "requiredErrorText":
                    "Invalid format 12 digits e.g +254700000000",
                "title": "Mobile Number",
                "type": "text",
                "validators": [
                  {
                    "regex": "^[+][0-9]{12}\$",
                    "text": "Invalid format 12 digits e.g +254700000000",
                    "type": "regex"
                  }
                ]
              },
              {
                "name": "fatherEmail",
                "placeholder": "abc@yxz.com",
                "startWithNewLine": false,
                "title": "Email",
                "type": "text"
              },
              {
                "isRequired": true,
                "name": "fatherBioData",
                "storeDataAsText": false,
                "title": "Attach Bio-Data Page",
                "type": "file",
                "visibleIf": "{FatherTypeofNationality} anyof ['Foreigner']"
              }
            ],
            "name": "Fathers",
            "startWithNewLine": false,
            "title": "Father's",
            "type": "panel",
            "visibleIf":
                "{Isthefathersinformationavailable} = 'Yes' and {MotherMaritalStatus} anyof ['Married', 'Divorced', 'Widowed']"
          }
        ],
        "name": "Father's Information",
        "title": "Father's Information",
        "visibleIf":
            "{MotherMaritalStatus} anyof ['Divorced', 'Widowed', 'Married'] and {IsthechildAbandoned} anyof ['NO']"
      },
      {
        "elements": [
          {
            "choices": [
              {
                "value": "Mother",
                "visibleIf":
                    "{CategoryOfMother} anyof ['Adult (Above 18 years)']"
              },
              {
                "enableIf":
                    "{MotherMaritalStatus} anyof ['Married', 'Divorced', 'Widowed']",
                "value": "Father",
                "visibleIf": "{FatherIdentificationNumber} notempty"
              },
              "Other"
            ],
            "isRequired": true,
            "name": "informant",
            "title": "Who is the Informant?",
            "type": "radiogroup"
          },
          {
            "elements": [
              {
                "choices": [
                  "Citizen",
                  "Foreigner",
                  "Alien",
                  "Not able to provide Valid Identification Document"
                ],
                "isRequired": true,
                "name": "InformantTypeofNationality",
                "title": "Type of Nationality",
                "type": "dropdown"
              },
              {
                "displayTemplate":
                    "<h4 class = \"bg-white text-dark border rounded \n p-3\">\nKENYAN\n<h4>",
                "name": "Nationality",
                "title": "Nationality",
                "type": "genericquestion",
                "visibleIf": "{InformantTypeofNationality} anyof ['Citizen']"
              },
              {
                "lookupDataTemplateId": "054353fb-9938-4e63-a7ad-a11c3ac83b5e",
                "lookupServiceId": 2,
                "name": "InformantLookup",
                "outputs": [
                  {
                    "text": "<<result.id_number>>",
                    "value": "InformantIdentificationNumber"
                  },
                  {
                    "text": "<<result.first_name>>",
                    "value": "InformantFirstName"
                  },
                  {
                    "text": "<<result.other_name>>",
                    "value": "InformantMiddleName"
                  },
                  {
                    "text": "<<result.surname>>",
                    "value": "InformantFathersName"
                  }
                ],
                "title": "Look Up",
                "type": "httplookup",
                "visibleIf":
                    "({InformantTypeofNationality} anyof ['Citizen', 'Alien'])"
              },
              {
                "description": "ID/Passport Number",
                "enableIf": "{InformantTypeofNationality} anyof ['Foreigner']",
                "name": "InformantIdentificationNumber",
                "title": "Identification Number",
                "type": "text",
                "visibleIf":
                    "{InformantTypeofNationality} anyof ['Citizen', 'Foreigner', 'Alien']"
              },
              {
                "enableIf": "{InformantTypeofNationality} anyof ['Foreigner']",
                "name": "InformantFirstName",
                "title": "First Name",
                "type": "text"
              },
              {
                "enableIf": "{InformantTypeofNationality} anyof ['Foreigner']",
                "name": "InformantMiddleName",
                "startWithNewLine": false,
                "title": "Middle Name",
                "type": "text"
              },
              {
                "enableIf": "{InformantTypeofNationality} anyof ['Foreigner']",
                "name": "InformantFathersName",
                "startWithNewLine": false,
                "title": "Informant Father's Name",
                "type": "text"
              },
              {
                "choicesByUrl": {
                  "titleName": "text",
                  "url":
                      "https://crs.pesaflow.com/resources/download/nationality",
                  "valueName": "value"
                },
                "name": "InformantNationality",
                "renderAs": "select2",
                "title": "Nationality",
                "type": "dropdown",
                "visibleIf":
                    "{InformantTypeofNationality} anyof ['Foreigner', 'Alien']"
              },
              {
                "choices": ["Male", "Female"],
                "name": "InformantGender",
                "title": "Gender",
                "type": "dropdown",
                "visible": false
              },
              {
                "name": "informantMobileNumber",
                "title": "Mobile Number",
                "type": "text"
              },
              {
                "name": "informantEmail",
                "startWithNewLine": false,
                "title": "Email",
                "type": "text"
              },
              {
                "isRequired": true,
                "name": "Capacity",
                "placeholder": "eg Aunt",
                "title": "Capacity",
                "type": "text"
              },
              {
                "acceptedTypes": ".pdf",
                "description": "(PDF)",
                "isRequired": true,
                "name": "informantBioDataPage",
                "storeDataAsText": false,
                "title": "Bio-Data Page",
                "type": "file",
                "visibleIf": "{InformantTypeofNationality} anyof ['Foreigner']"
              }
            ],
            "name": "PanelInformant",
            "startWithNewLine": false,
            "title": "Informant",
            "type": "panel",
            "visibleIf": "{informant} anyof ['Other']"
          },
          {
            "elements": [
              {
                "choices": [
                  "I certify that to the best of my knowledge that the information given in this form is correct."
                ],
                "isRequired": true,
                "name": "Declaration",
                "title": "Informant's Declaration",
                "type": "checkbox"
              },
              {
                "choices": [
                  "Online Signature",
                  "Manual Signature (Download B1, Sign and Upload)",
                  "Upload image of signature (Photo of signature on a plain  white background)"
                ],
                "isRequired": true,
                "name": "typeOfSignature",
                "title": "Type of Signature ",
                "type": "dropdown",
                "visibleIf": "{Declaration} notempty"
              },
              {
                "isRequired": true,
                "name": "signaturePad",
                "title": "Signature Pad",
                "type": "signaturepad",
                "visibleIf": "{typeOfSignature} anyof ['Online Signature']"
              },
              {
                "name": "PhotoofSignatureofInformantonclearbackground",
                "storeDataAsText": false,
                "title": "Photo of Signature of Informant on clear background",
                "type": "file",
                "visibleIf":
                    "{typeOfSignature} anyof ['Upload image of signature (Photo of signature on a plain  white background)']"
              }
            ],
            "name": "panel2",
            "type": "panel",
            "visibleIf": "{informant} notempty"
          }
        ],
        "name": "Informant Information",
        "title": "Informant Information"
      },
      {
        "elements": [
          {
            "elements": [
              {
                "html":
                    "<a href=\"/applications/{applicationId}/downloads/b1\"target=\"_blank\">CLICK HERE TO DOWNLOAD THE REGISTRATION FORM<BR></a>",
                "name": "question1",
                "type": "html"
              },
              {
                "description": "Please upload the signed B1 form. ",
                "isRequired": true,
                "name": "b1",
                "startWithNewLine": false,
                "storeDataAsText": false,
                "title": "Registration Form B1",
                "type": "file",
                "visibleIf":
                    "{typeOfSignature} anyof ['Manual Signature (Download B1, Sign and Upload)']"
              }
            ],
            "name": "panel3",
            "type": "panel"
          },
          {
            "choices": [
              "I certify that to the best of my knowledge that the information given in this form is correct."
            ],
            "name": "RegistrationAssistantsDeclaration",
            "title": "Registration Assistants Declaration",
            "type": "checkbox"
          }
        ],
        "name": "Document Preview",
        "title": "Document Preview"
      }
    ],
    "progressBarType": "buttons",
    "showProgressBar": "top",
    "showQuestionNumbers": "off"
  };
}

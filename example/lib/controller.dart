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

  Map schema2 = {};
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

  reOrganizeData() {
    schema2 = {
      "initial_data": {
        "County": "Kakamega",
        "OrganizationName": "Mundoli Health Centre",
        "OrganizationRegistrationNumber": "Mundoli Health Centre",
        "SubCounty": ""
      },
      "lookup_services": [
        {
          "data_templates": [
            {
              "content": "{\r\n\"registration_name\":\"{{data.default.records[0].business_name}}\",\r\n\"registration_number\":\"{{data.default.records[0].registration_number}}\",\r\n\"email\":\"{{data.default.records[0].email}}\",\r\n\"phone_number\":\"{{data.default.records[0].phone_number}}\",\r\n\"registration_date\":\"{{data.default.records[0].registration_date}}\",\r\n\"pin\":\"{{data.kra_look_up.pin}}\",\r\n\"owners\":[\r\n {% for owner in data.default.records[0].partners%}\r\n{\r\n\"full_names\":\"{{owner.name}}\",\r\n\"id_type\":\"{{owner.id_type}}\",\r\n\"id_number\":\"{{owner.id_number}}\",\r\n\"type\":\"{{owner.type}}\"\r\n}\r\n{% if forloop.last == false %}, {% endif %}\r\n{% endfor %}\r\n]\r\n}",
              "format": "json",
              "id": "63e31de8-6ce6-41aa-ad86-cf405ac03998",
              "name": "CompanySearchJSON"
            }
          ],
          "id": 1,
          "name": "BRS Look Up",
          "parameters": [
            {
              "label": "Registration Number",
              "name": "registration_number",
              "options": [],
              "raw_options": null,
              "type": "text"
            }
          ],
          "requests": [
            {
              "auth": "basic",
              "body": null,
              "enctype": "json",
              "endpoint": "https://brs.ecitizen.go.ke/api/businesses?registration_number={{registration_number}}",
              "headers": [],
              "method": "get",
              "order_id": null,
              "password": "c6uurhm3wcshd37n4qfqeby45fr65hwt4ezgpozn3nelqcqmvzea====",
              "slug": "default",
              "token": null,
              "username": "c5775b8be304b2e94e94b5bb05e91955"
            }
          ],
          "validation": null
        },
        {
          "data_templates": [
            {
              "content": "id_number={{data.id_number}}\\\\\r\nfirst_name={{data.first_name}}\\\\\r\nother_name={{data.other_name}}\\\\\r\nsurname={{data.surname}}\\\\\r\ngender={{data.gender}}\\\\\r\ndob={{data.dob}}",
              "format": "simplified",
              "id": "054353fb-9938-4e63-a7ad-a11c3ac83b5e",
              "name": "IPRS Search"
            }
          ],
          "id": 2,
          "name": "IPRS Look Up",
          "parameters": [
            {
              "label": "ID Type",
              "name": "id_type",
              "options": [
                {
                  "id": "a0c1a188-aba2-4764-be15-6a6786a28ede",
                  "label": "National Identification",
                  "value": "NationalIdentification"
                },
                {
                  "id": "ab77bd8e-e8a1-4506-86ee-a92b6bbd8149",
                  "label": "Alien National Identification",
                  "value": "AlienNationalIdentification"
                }
              ],
              "raw_options": [
                " NationalIdentification|National Identification",
                " AlienNationalIdentification|Alien National Identification"
              ],
              "type": "dropdown"
            },
            {
              "label": "ID Number",
              "name": "id_number",
              "options": [],
              "raw_options": null,
              "type": "number"
            },
            {
              "label": "First Name",
              "name": "first_name",
              "options": [],
              "raw_options": null,
              "type": "text"
            }
          ],
          "requests": [
            {
              "auth": "basic",
              "body": null,
              "enctype": "json",
              "endpoint": "http://197.248.4.134/iprs/{% if id_type == 'NationalIdentification' %}databyid{% else %}databyalienid{% endif %}?number={{id_number}}",
              "headers": [],
              "method": "get",
              "order_id": null,
              "password": "6I2-u?=W",
              "slug": "default",
              "token": null,
              "username": "mrmiddleman"
            }
          ],
          "validation": "String.downcase(inputs[\"first_name\"]) == String.downcase(data[\"first_name\"])"
        },
        {
          "data_templates": [
            {
              "content": "id_number={{data.id_number}}\\\\\r\nfirst_name={{data.first_name}}\\\\\r\nother_name={{data.other_name}}\\\\\r\nsurname={{data.surname}}\\\\\r\ngender={{data.gender}}\\\\\r\ndob={{data.dob}}",
              "format": "simplified",
              "id": "284ed706-eda7-4dce-8266-64523927eaec",
              "name": "IPRS Search"
            }
          ],
          "id": 3,
          "name": "IPRS Look Up (National Only)",
          "parameters": [
            {
              "label": "ID Number",
              "name": "id_number",
              "options": [],
              "raw_options": null,
              "type": "number"
            },
            {
              "label": "First Name",
              "name": "first_name",
              "options": [],
              "raw_options": null,
              "type": "text"
            }
          ],
          "requests": [
            {
              "auth": "basic",
              "body": null,
              "enctype": "json",
              "endpoint": "http://197.248.4.134/iprs/databyid?number={{id_number}}",
              "headers": [],
              "method": "get",
              "order_id": null,
              "password": "6I2-u?=W",
              "slug": "default",
              "token": null,
              "username": "mrmiddleman"
            }
          ],
          "validation": "String.downcase(inputs[\"first_name\"]) == String.downcase(data[\"first_name\"])"
        },
        {
          "data_templates": [
            {
              "content": "code={{data.data.code}}\\\\\r\nname={{data.data.name}}\\\\\r\ncounty={{data.data.county}}\\\\\r\nsub_county={{data.data.subCounty}}\\\\\r\nward={{data.data.ward}}\\\\\r\noperation_status={{data.data.operationStatus}}",
              "format": "simplified",
              "id": "b8d407eb-518c-489f-bb2b-14af3e2e1edb",
              "name": "Health Facility Search"
            }
          ],
          "id": 4,
          "name": "Health Facility Lookup",
          "parameters": [
            {
              "label": "Health Facility Code",
              "name": "code",
              "options": [],
              "raw_options": null,
              "type": "text"
            }
          ],
          "requests": [
            {
              "auth": "basic",
              "body": null,
              "enctype": "json",
              "endpoint": "http://172.18.76.54:4000/api/lookup/dataset?name=health_facility&key=code&value={{code}}",
              "headers": [],
              "method": "get",
              "order_id": null,
              "password": "manticore#ec14",
              "slug": "default",
              "token": null,
              "username": "permitflow"
            }
          ],
          "validation": "data[\"status\"] != \"error\""
        },
        {
          "data_templates": [
            {
              "content": "notificationNumber={{data.data.notificationNumber}}\\\\\r\ncounty={{data.data.county}}\\\\\r\nnamed={{data.data.named}}\\\\\r\nsubCounty={{data.data.subCounty}}\\\\\r\ngender={{data.data.gender}}\\\\\r\ntypeOfBirth={{data.data.typeOfBirth}}\\\\\r\nmotherUsualResidence={{data.data.motherUsualResidence}}\\\\\r\nmotherLevelOfEducation={{data.data.motherLevelOfEducation}}\\\\\r\ninformantFirstName={{data.data.informantFirstName}}\\\\\r\ninformantGender={{data.data.informantGender}}\\\\\r\ncategoryOfFather={{data.data.categoryOfFather}}\\\\\r\nfatherMiddleName={{data.data.fatherMiddleName}}\\\\\r\nmotherIdNumber={{data.data.motherIdNumber}}\\\\\r\ninformantDesignation={{data.data.informantDesignation}}\\\\\r\norganizationName={{data.data.organizationName}}\\\\\r\nnumberBornDead={{data.data.numberBornDead}}\\\\\r\nmotherSubCounty={{data.data.motherSubCounty}}\\\\\r\nweigthOfBirth={{data.data.weigthOfBirth}}\\\\\r\nmotherTypeOfNationality={{data.data.motherTypeOfNationality}}\\\\\r\nmotherNationality={{data.data.motherNationality}}\\\\\r\nmotherCounty={{data.data.motherCounty}}\\\\\r\nmotherMaritalStatus={{data.data.motherMaritalStatus}}\\\\\r\nmotherMiddleName={{data.data.motherMiddleName}}\\\\\r\nmotherDateOfBirth={{data.data.motherDateOfBirth}}\\\\\r\ncategoryOfInformant={{data.data.categoryOfInformant}}\\\\\r\nmotherFirstName={{data.data.motherFirstName}}\\\\\r\ninformantFathersName={{data.data.informantFathersName}}\\\\\r\nmotherFathersName={{data.data.motherFathersName}}\\\\\r\nchildOtherName={{data.data.childOtherName}}\\\\\r\nchildFathersName={{data.data.childFathersName}}\\\\\r\ntheInformant={{data.data.theInformant}}\\\\\r\nfatherDateOfBirth={{data.data.fatherDateOfBirth}}\\\\\r\ninformantTypeOfNationality={{data.data.informantTypeOfNationality}}\\\\\r\nchildFirstName={{data.data.childFirstName}}\\\\\r\nfatherFathersName={{data.data.fatherFathersName}}\\\\\r\nfatherNationality={{data.data.fatherNationality}}\\\\\r\ncategoryOfMother={{data.data.categoryOfMother}}\\\\\r\nnumberBornAlive={{data.data.numberBornAlive}}\\\\\r\norganizationNumber={{data.data.organizationNumber}}\\\\\r\nchildDateOfBirth={{data.data.childDateOfBirth}}\\\\\r\ninformantMiddleName={{data.data.informantMiddleName}}\\\\\r\ninformantIdNumber={{data.data.informantIdNumber}}\\\\\r\nfatherFirstName={{data.data.fatherFirstName}}\\\\\r\nfatherIdNumber={{data.data.fatherIdNumber}}\\\\\r\nfatherTypeOfNationality={{data.data.fatherTypeOfNationality}}\\\\\r\nnatureOfBirth={{data.data.natureOfBirth}}\\\\\r\nmotherOccupation={{data.data.motherOccupation}}\\\\\r\ninformantNationality={{data.data.informantNationality}}",
              "format": "simplified",
              "id": "a0fb8b42-5dc6-47c3-bafb-f2ce0aeb6702",
              "name": "Birth Notification Search"
            }
          ],
          "id": 5,
          "name": "Birth Notification Lookup",
          "parameters": [
            {
              "label": "Notification Number",
              "name": "notification_number",
              "options": [],
              "raw_options": null,
              "type": "text"
            }
          ],
          "requests": [
            {
              "auth": "basic",
              "body": null,
              "enctype": "json",
              "endpoint": "http://172.18.76.54:4000/api/lookup/dataset?name=birth_notification&key=notification_number&value={{notification_number}}",
              "headers": [],
              "method": "get",
              "order_id": null,
              "password": "manticore#ec14",
              "slug": "default",
              "token": null,
              "username": "permitflow"
            }
          ],
          "validation": "data[\"status\"] != \"error\""
        },
        {
          "data_templates": [
            {
              "content": "burialPermitNo={{data.data.burialPermitNo}}\\\\\r\nageUnit={{data.data.ageUnit}}\\\\\r\ncategoryOfDeceased={{data.data.categoryOfDeceased}}\\\\\r\ntypeOfNationalityOfDeceased={{data.data.typeOfNationalityOfDeceased}}\\\\\r\ndeceasedIdNumber={{data.data.deceasedIdNumber}}\\\\\r\ndeceasedFirstName={{data.data.deceasedFirstName}}\\\\\r\ndeceasedOtherName={{data.data.deceasedOtherName}}\\\\\r\ndeceasedLastName={{data.data.deceasedLastName}}\\\\\r\ndeceasedMaritalStatus={{data.data.deceasedMaritalStatus}}\\\\\r\ndeceasedGender={{data.data.deceasedGender}}\\\\\r\ndeceasedLevelOfEducation={{data.data.deceasedLevelOfEducation}}\\\\\r\nplaceOfDeath={{data.data.placeOfDeath}}\\\\\r\ndeceasedUsualResidence={{data.data.deceasedUsualResidence}}\\\\\r\ndeceasedOccupation={{data.data.deceasedOccupation}}\\\\\r\nnaturalCasuesOfDeath={{data.data.naturalCasuesOfDeath}}\\\\\r\nunNaturalCausesOfBirth={{data.data.unNaturalCausesOfBirth}}\\\\\r\ncapacityOfInformant={{data.data.capacityOfInformant}}\\\\\r\ninformantTypeOfNationality={{data.data.informantTypeOfNationality}}\\\\\r\ninformantIdNumber={{data.data.informantIdNumber}}\\\\\r\ninformantFirstName={{data.data.informantFirstName}}\\\\\r\ninformantOtherName={{data.data.informantOtherName}}\\\\\r\ninformantSurname={{data.data.informantSurname}}\\\\\r\ninformantNationality={{data.data.informantNationality}}\\\\\r\ninformantGender={{data.data.informantGender}}\\\\\r\ninformantMobileNumber={{data.data.informantMobileNumber}}\\\\\r\ninformantEmail={{data.data.informantEmail}}\\\\\r\norganizationName={{data.data.organizationName}}\\\\\r\norganizationNumber={{data.data.organizationNumber}}\\\\\r\ncounty={{data.data.county}}\\\\\r\nsubCounty={{data.data.subCounty}}\\\\\r\ncountyOfDeath={{data.data.countyOfDeath}}\\\\\r\nsubCountyOfDeath={{data.data.subCountyOfDeath}}\\\\\r\ndeceasedCountyResidence={{data.data.deceasedCountyResidence}}\\\\\r\ndeceasedSubCountyResidence={{data.data.deceasedSubCountyResidence}}\\\\\r\ndateOfDeath={{data.data.dateOfDeath}}\\\\\r\nage={{data.data.age}}",
              "format": "simplified",
              "id": "d7ee8a8c-e3d4-45b4-aee1-a66e33d1efa8",
              "name": "Death Notification Search"
            }
          ],
          "id": 6,
          "name": "Death Notification Lookup",
          "parameters": [
            {
              "label": "Burial Permit Number",
              "name": "burial_permit_no",
              "options": [],
              "raw_options": null,
              "type": "text"
            }
          ],
          "requests": [
            {
              "auth": "basic",
              "body": null,
              "enctype": "json",
              "endpoint": "http://172.18.76.54:4000/api/lookup/dataset?name=death_notification&key=burial_permit_no&value={{burial_permit_no}}",
              "headers": [],
              "method": "get",
              "order_id": null,
              "password": "manticore#ec14",
              "slug": "default",
              "token": null,
              "username": "permitflow"
            }
          ],
          "validation": "data[\"status\"] != \"error\""
        },
        {
          "data_templates": [
            {
              "content": "notificationNumber={{data.data.notificationNumber}}\\\\\r\ncounty={{data.data.county}}\\\\\r\nnamed={{data.data.named}}\\\\\r\nsubCounty={{data.data.subCounty}}\\\\\r\ngender={{data.data.gender}}\\\\\r\ntypeOfBirth={{data.data.typeOfBirth}}\\\\\r\nmotherUsualResidence={{data.data.motherUsualResidence}}\\\\\r\nmotherLevelOfEducation={{data.data.motherLevelOfEducation}}\\\\\r\ninformantFirstName={{data.data.informantFirstName}}\\\\\r\ninformantGender={{data.data.informantGender}}\\\\\r\ncategoryOfFather={{data.data.categoryOfFather}}\\\\\r\nfatherMiddleName={{data.data.fatherMiddleName}}\\\\\r\nmotherIdNumber={{data.data.motherIdNumber}}\\\\\r\ninformantDesignation={{data.data.informantDesignation}}\\\\\r\norganizationName={{data.data.organizationName}}\\\\\r\nnumberBornDead={{data.data.numberBornDead}}\\\\\r\nmotherSubCounty={{data.data.motherSubCounty}}\\\\\r\nweigthOfBirth={{data.data.weigthOfBirth}}\\\\\r\nmotherTypeOfNationality={{data.data.motherTypeOfNationality}}\\\\\r\nmotherNationality={{data.data.motherNationality}}\\\\\r\nmotherCounty={{data.data.motherCounty}}\\\\\r\nmotherMaritalStatus={{data.data.motherMaritalStatus}}\\\\\r\nmotherMiddleName={{data.data.motherMiddleName}}\\\\\r\nmotherDateOfBirth={{data.data.motherDateOfBirth}}\\\\\r\ncategoryOfInformant={{data.data.categoryOfInformant}}\\\\\r\nmotherFirstName={{data.data.motherFirstName}}\\\\\r\ninformantFathersName={{data.data.informantFathersName}}\\\\\r\nmotherFathersName={{data.data.motherFathersName}}\\\\\r\nchildOtherName={{data.data.childOtherName}}\\\\\r\nchildFathersName={{data.data.childFathersName}}\\\\\r\ntheInformant={{data.data.theInformant}}\\\\\r\nfatherDateOfBirth={{data.data.fatherDateOfBirth}}\\\\\r\ninformantTypeOfNationality={{data.data.informantTypeOfNationality}}\\\\\r\nchildFirstName={{data.data.childFirstName}}\\\\\r\nfatherFathersName={{data.data.fatherFathersName}}\\\\\r\nfatherNationality={{data.data.fatherNationality}}\\\\\r\ncategoryOfMother={{data.data.categoryOfMother}}\\\\\r\nnumberBornAlive={{data.data.numberBornAlive}}\\\\\r\norganizationNumber={{data.data.organizationNumber}}\\\\\r\nchildDateOfBirth={{data.data.childDateOfBirth}}\\\\\r\ninformantMiddleName={{data.data.informantMiddleName}}\\\\\r\ninformantIdNumber={{data.data.informantIdNumber}}\\\\\r\nfatherFirstName={{data.data.fatherFirstName}}\\\\\r\nfatherIdNumber={{data.data.fatherIdNumber}}\\\\\r\nfatherTypeOfNationality={{data.data.fatherTypeOfNationality}}\\\\\r\nnatureOfBirth={{data.data.natureOfBirth}}\\\\\r\nmotherOccupation={{data.data.motherOccupation}}\\\\\r\ninformantNationality={{data.data.informantNationality}}",
              "format": "simplified",
              "id": "dba96e58-1b34-4bd9-9d25-90b9f5d33d5e",
              "name": "Birth Certificate Search"
            }
          ],
          "id": 7,
          "name": "Birth Certificate Lookup",
          "parameters": [
            {
              "label": "Entry Number",
              "name": "notification_number",
              "options": [],
              "raw_options": null,
              "type": "text"
            }
          ],
          "requests": [
            {
              "auth": "basic",
              "body": null,
              "enctype": "json",
              "endpoint": "http://172.18.76.54:4000/api/lookup/dataset?name=birth_certificate&key=notification_number&value={{notification_number}}",
              "headers": [],
              "method": "get",
              "order_id": null,
              "password": "manticore#ec14",
              "slug": "default",
              "token": null,
              "username": "permitflow"
            }
          ],
          "validation": "data[\"status\"] != \"error\""
        },
        {
          "data_templates": [
            {
              "content": "burialPermitNo={{data.data.burialPermitNo}}\\\\\r\nageUnit={{data.data.ageUnit}}\\\\\r\ncategoryOfDeceased={{data.data.categoryOfDeceased}}\\\\\r\ntypeOfNationalityOfDeceased={{data.data.typeOfNationalityOfDeceased}}\\\\\r\ndeceasedIdNumber={{data.data.deceasedIdNumber}}\\\\\r\ndeceasedFirstName={{data.data.deceasedFirstName}}\\\\\r\ndeceasedOtherName={{data.data.deceasedOtherName}}\\\\\r\ndeceasedLastName={{data.data.deceasedLastName}}\\\\\r\ndeceasedMaritalStatus={{data.data.deceasedMaritalStatus}}\\\\\r\ndeceasedGender={{data.data.deceasedGender}}\\\\\r\ndeceasedLevelOfEducation={{data.data.deceasedLevelOfEducation}}\\\\\r\nplaceOfDeath={{data.data.placeOfDeath}}\\\\\r\ndeceasedUsualResidence={{data.data.deceasedUsualResidence}}\\\\\r\ndeceasedOccupation={{data.data.deceasedOccupation}}\\\\\r\nnaturalCasuesOfDeath={{data.data.naturalCasuesOfDeath}}\\\\\r\nunNaturalCausesOfBirth={{data.data.unNaturalCausesOfBirth}}\\\\\r\ncapacityOfInformant={{data.data.capacityOfInformant}}\\\\\r\ninformantTypeOfNationality={{data.data.informantTypeOfNationality}}\\\\\r\ninformantIdNumber={{data.data.informantIdNumber}}\\\\\r\ninformantFirstName={{data.data.informantFirstName}}\\\\\r\ninformantOtherName={{data.data.informantOtherName}}\\\\\r\ninformantSurname={{data.data.informantSurname}}\\\\\r\ninformantNationality={{data.data.informantNationality}}\\\\\r\ninformantGender={{data.data.informantGender}}\\\\\r\ninformantMobileNumber={{data.data.informantMobileNumber}}\\\\\r\ninformantEmail={{data.data.informantEmail}}\\\\\r\norganizationName={{data.data.organizationName}}\\\\\r\norganizationNumber={{data.data.organizationNumber}}\\\\\r\ncounty={{data.data.county}}\\\\\r\nsubCounty={{data.data.subCounty}}\\\\\r\ncountyOfDeath={{data.data.countyOfDeath}}\\\\\r\nsubCountyOfDeath={{data.data.subCountyOfDeath}}\\\\\r\ndeceasedCountyResidence={{data.data.deceasedCountyResidence}}\\\\\r\ndeceasedSubCountyResidence={{data.data.deceasedSubCountyResidence}}\\\\\r\ndateOfDeath={{data.data.dateOfDeath}}\\\\\r\nage={{data.data.age}}",
              "format": "simplified",
              "id": "d18a56ce-4e52-4b7a-9750-673f1279eda0",
              "name": "Death Certificate Search"
            }
          ],
          "id": 8,
          "name": "Death Certificate Lookup",
          "parameters": [
            {
              "label": "Burial Permit Number",
              "name": "burial_permit_no",
              "options": [],
              "raw_options": null,
              "type": "text"
            }
          ],
          "requests": [
            {
              "auth": "basic",
              "body": null,
              "enctype": "json",
              "endpoint": "http://172.18.76.54:4000/api/lookup/dataset?name=burial_permit_no&key=burial_permit_no&value={{burial_permit_no}}",
              "headers": [],
              "method": "get",
              "order_id": null,
              "password": "manticore#ec14",
              "slug": "default",
              "token": null,
              "username": "permitflow"
            }
          ],
          "validation": "data[\"status\"] != \"error\""
        }
      ],
      "service": {
        "id": 2,
        "name": "Current Birth Registration",
        "schema": {
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
                  "choices": [
                    "NO",
                    "YES"
                  ],
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
                      "choices": [
                        "Citizen",
                        "Foreigner",
                        "Alien"
                      ],
                      "description": "(Mandatory)",
                      "isRequired": true,
                      "name": "MotherTypeofNationality",
                      "title": "Type of Nationality",
                      "type": "dropdown",
                      "visibleIf": "{CategoryOfMother} anyof ['Adult (Above 18 years)', 'Minor (below 18years)']"
                    },
                    {
                      "displayTemplate": "<h4 class = \"bg-white text-dark border rounded \n p-3\">\nKENYAN\n<h4>",
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
                        {
                          "text": "<<result.first_name>>",
                          "value": "MotherFirstName"
                        },
                        {
                          "text": "<<result.other_name>>",
                          "value": "MotherMiddleName"
                        },
                        {
                          "text": "<<result.surname>>",
                          "value": "MotherFathersName"
                        },
                        {
                          "text": "<<result.dob>>",
                          "value": "MotherDateofBirth"
                        },
                        {
                          "text": "<<result.dob>>",
                          "value": "motherAgeAtBirth"
                        }
                      ],
                      "title": "IPRS Lookup",
                      "type": "httplookup",
                      "visibleIf": "{MotherTypeofNationality} anyof ['Citizen', 'Alien'] and {CategoryOfMother} anyof ['Adult (Above 18 years)']"
                    },
                    {
                      "description": "Identification Number/Passport Number",
                      "enableIf": "{MotherTypeofNationality} anyof ['Foreigner']",
                      "name": "MotherIdentificationNumber",
                      "title": "Identification Number",
                      "type": "text",
                      "visibleIf": "{CategoryOfMother} anyof ['Adult (Above 18 years)'] and {MotherTypeofNationality} anyof ['Citizen', 'Alien', 'Foreigner']"
                    },
                    {
                      "enableIf": "{MotherTypeofNationality} anyof ['Foreigner'] or {CategoryOfMother} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                      "isRequired": true,
                      "name": "MotherFirstName",
                      "title": "First Name",
                      "type": "text"
                    },
                    {
                      "enableIf": "{MotherTypeofNationality} anyof ['Foreigner'] or {CategoryOfMother} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                      "name": "MotherMiddleName",
                      "startWithNewLine": false,
                      "title": "Middle Name",
                      "type": "text"
                    },
                    {
                      "enableIf": "{MotherTypeofNationality} anyof ['Foreigner'] or {CategoryOfMother} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
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
                      "visibleIf": "{CategoryOfMother} anyof ['Minor (below 18years)', 'Not Able to Access Identification Document'] or {MotherTypeofNationality} anyof ['Foreigner']"
                    },
                    {
                      "dateFormat": "MM/DD/YYYY hh:mm:ss",
                      "dateInterval": "years",
                      "name": "motherAgeAtBirth",
                      "readOnly": true,
                      "title": "Mother's Age at the time of Birth",
                      "type": "agecalc",
                      "visibleIf": "{CategoryOfMother} anyof ['Adult (Above 18 years)'] and {MotherTypeofNationality} anyof ['Citizen']"
                    },
                    {
                      "choices": [
                        "Married",
                        "Single",
                        "Divorced",
                        "Widowed"
                      ],
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
                        "url": "https://crs.pesaflow.com/resources/download/nationality",
                        "valueName": "value"
                      },
                      "description": "(Mandatory)",
                      "isRequired": true,
                      "name": "MotherNationality",
                      "renderAs": "select2",
                      "title": "Nationality",
                      "type": "dropdown",
                      "visibleIf": "{MotherTypeofNationality} anyof ['Foreigner', 'Alien']"
                    },
                    {
                      "choices": [
                        "Yes",
                        "No"
                      ],
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
                        "url": "https://crs.pesaflow.com/resources/download/sub-county",
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
                      "requiredErrorText": "Invalid format 12 digits e.g +254700000000",
                      "title": "Mobile Number",
                      "type": "text",
                      "validators": [
                        {
                          "regex": "^[+][0-9]{12}",
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
                      "choices": [
                        "Yes",
                        "No"
                      ],
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
                      "visibleIf": "{named} anyof ['Yes'] and {MotherMaritalStatus} anyof ['Married', 'Divorced', 'Widowed']"
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
                      "choices": [
                        "Male",
                        "Female"
                      ],
                      "isRequired": true,
                      "name": "Sex",
                      "showOtherItem": true,
                      "startWithNewLine": false,
                      "title": "Sex",
                      "type": "dropdown"
                    },
                    {
                      "choices": [
                        "Single",
                        "Twins"
                      ],
                      "name": "TypeOfBirth",
                      "showOtherItem": true,
                      "title": "Type Of Birth",
                      "type": "dropdown"
                    },
                    {
                      "choices": [
                        "Born Alive",
                        "Born Dead"
                      ],
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
                      "choices": [
                        "1",
                        "2",
                        "3",
                        "4",
                        "5",
                        "6",
                        "7",
                        "8",
                        "9",
                        "10"
                      ],
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
                  "choices": [
                    "Yes",
                    "No"
                  ],
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
                      "choices": [
                        "Citizen",
                        "Foreigner",
                        "Alien"
                      ],
                      "description": "(Mandatory)",
                      "isRequired": true,
                      "name": "FatherTypeofNationality",
                      "title": "Type of Nationality",
                      "type": "dropdown",
                      "visibleIf": "{CategoryOfFather} anyof ['Adult (Above 18 years)', 'Minor (below 18years)']"
                    },
                    {
                      "displayTemplate": "<h4 class = \"bg-white text-dark border rounded \n p-3\">\nKENYAN\n<h4>",
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
                        {
                          "text": "<<result.first_name>>",
                          "value": "FatherFirstName"
                        },
                        {
                          "text": "<<result.other_name>>",
                          "value": "FatherMiddleName"
                        },
                        {
                          "text": "<<result.surname>>",
                          "value": "FatherFathersName"
                        },
                        {
                          "text": "<<result.dob>>",
                          "value": "FatherDateOfBirth"
                        }
                      ],
                      "title": "IPRS Lookup",
                      "type": "httplookup",
                      "visibleIf": "{FatherTypeofNationality} anyof ['Citizen', 'Alien'] and {CategoryOfFather} anyof ['Adult (Above 18 years)']"
                    },
                    {
                      "description": "ID/Passport Number",
                      "enableIf": "{FatherTypeofNationality} anyof ['Foreigner']",
                      "name": "FatherIdentificationNumber",
                      "title": "Identification Number",
                      "type": "text",
                      "visibleIf": "{FatherTypeofNationality} anyof ['Citizen', 'Alien', 'Foreigner'] and {CategoryOfFather} anyof ['Adult (Above 18 years)']"
                    },
                    {
                      "enableIf": "{FatherTypeofNationality} anyof ['Foreigner'] or {CategoryOfFather} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                      "isRequired": true,
                      "name": "FatherFirstName",
                      "title": "First Name",
                      "type": "text"
                    },
                    {
                      "enableIf": "{FatherTypeofNationality} anyof ['Foreigner'] or {CategoryOfFather} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                      "name": "FatherMiddleName",
                      "startWithNewLine": false,
                      "title": "Middle Name",
                      "type": "text"
                    },
                    {
                      "enableIf": "{FatherTypeofNationality} anyof ['Foreigner'] or {CategoryOfFather} anyof ['Not Able to Access Identification Document', 'Minor (below 18years)']",
                      "name": "FatherFathersName",
                      "readOnly": true,
                      "startWithNewLine": false,
                      "title": "Father's Name",
                      "type": "text"
                    },
                    {
                      "choicesByUrl": {
                        "titleName": "text",
                        "url": "https://crs.pesaflow.com/resources/download/nationality",
                        "valueName": "value"
                      },
                      "description": "(Mandatory)",
                      "isRequired": true,
                      "name": "FatherNationality",
                      "renderAs": "select2",
                      "title": "Nationality",
                      "type": "dropdown",
                      "visibleIf": "{FatherTypeofNationality} anyof ['Foreigner', 'Alien']"
                    },
                    {
                      "maxErrorText": "Invalid format 12 digits e.g +254700000000",
                      "minErrorText": "Invalid format 12 digits e.g +254700000000",
                      "name": "fatherMobileNumber",
                      "placeholder": "+254720217295",
                      "requiredErrorText": "Invalid format 12 digits e.g +254700000000",
                      "title": "Mobile Number",
                      "type": "text",
                      "validators": [
                        {
                          "regex": "^[+][0-9]{12}",
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
                  "visibleIf": "{Isthefathersinformationavailable} = 'Yes' and {MotherMaritalStatus} anyof ['Married', 'Divorced', 'Widowed']"
                }
              ],
              "name": "Father's Information",
              "title": "Father's Information",
              "visibleIf": "{MotherMaritalStatus} anyof ['Divorced', 'Widowed', 'Married'] and {IsthechildAbandoned} anyof ['NO']"
            },
            {
              "elements": [
                {
                  "choices": [
                    {
                      "value": "Mother",
                      "visibleIf": "{CategoryOfMother} anyof ['Adult (Above 18 years)']"
                    },
                    {
                      "enableIf": "{MotherMaritalStatus} anyof ['Married', 'Divorced', 'Widowed']",
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
                      "displayTemplate": "<h4 class = \"bg-white text-dark border rounded \n p-3\">\nKENYAN\n<h4>",
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
                      "visibleIf": "({InformantTypeofNationality} anyof ['Citizen', 'Alien'])"
                    },
                    {
                      "description": "ID/Passport Number",
                      "enableIf": "{InformantTypeofNationality} anyof ['Foreigner']",
                      "name": "InformantIdentificationNumber",
                      "title": "Identification Number",
                      "type": "text",
                      "visibleIf": "{InformantTypeofNationality} anyof ['Citizen', 'Foreigner', 'Alien']"
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
                        "url": "https://crs.pesaflow.com/resources/download/nationality",
                        "valueName": "value"
                      },
                      "name": "InformantNationality",
                      "renderAs": "select2",
                      "title": "Nationality",
                      "type": "dropdown",
                      "visibleIf": "{InformantTypeofNationality} anyof ['Foreigner', 'Alien']"
                    },
                    {
                      "choices": [
                        "Male",
                        "Female"
                      ],
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
                      "visibleIf": "{typeOfSignature} anyof ['Upload image of signature (Photo of signature on a plain  white background)']"
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
                      "html": "<a href=\"/applications/{applicationId}/downloads/b1\"target=\"_blank\">CLICK HERE TO DOWNLOAD THE REGISTRATION FORM<BR></a>",
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
                      "visibleIf": "{typeOfSignature} anyof ['Manual Signature (Download B1, Sign and Upload)']"
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
        }
      }
    };
    print("Start reOrganizeData");
    for(var i in schema2['service']['schema']['pages']) {
      for(var j in i['elements']) {
        if(j['elements'] != null){
          for(var k in j['elements']) {
            if(k['type'] == 'httplookup') {
              k['lookup'] = [];
              for(var l in schema2['lookup_services']) {
                if(l['id'] == k['lookupServiceId']) {
                  k['lookup'].add(l);
                }
                print("?????K");
                print(k);

              }
            }
          }
          print("?????J");
          print(j);
        }


      }


    }
    print("?????SCHEMA3");
    print("?????SCHEMA2");
    print(schema2);
    print("?????PAGES");
    print(schema2['service']['schema']['pages']);

  }


  //create an object of ActiveMap<String, Map<String, dynamic>> to store the form results

  ActiveMap<String, Map<String, dynamic>> formResults = ActiveMap( {
    "data": {
      "data": "data",
      "data1": "data",
      "data2": "data",
    }
  });

}

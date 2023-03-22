import 'dart:convert';
import 'dart:io';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_ip_address/get_ip_address.dart';
import 'model.dart';

class MainController extends ActiveController {
  GlobalKey globalKey = GlobalKey<FormState>();

  /// Initialise area
  Memory memory = Memory(filename: '${Directory.current.path}activity-data.act');

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

  Map schema = {};
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
    ActiveDateTime activeDateTime = ActiveDateTime(DateTime.now(), typeName: 'dateOfBirth');

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
      ContentType.json: {'url': request.uri.path, 'key': 'Hello, World!... This is about us!'}
    };
  }

  Map<ContentType, dynamic> contactUsPage(HttpRequest request) {
    return {
      ContentType.json: {'url': request.uri.path, 'key': 'Hello, World!... This is contact us!'}
    };
  }

  Map<ContentType, dynamic> notFoundPage(HttpRequest request) {
    var json = jsonEncode({'url': request.uri.path, 'key': 'Hello, World!... Not found!'});

    return {ContentType.json: json};
  }

  /// Map request to response
  Future<Map<ContentType, dynamic>> httpRequests(HttpRequest httpRequest) async {
    switch (httpRequest.uri.path) {
      case '/':
        return homePage(httpRequest);

      case '/contactus':
        return aboutPage(httpRequest);

      case '/about':
        return contactUsPage(httpRequest);

      default:
        return notFoundPage(httpRequest);
    }
  }

  startServer() async {

    var anyIPv4 = InternetAddress.anyIPv4;
    printSuccess('{{{anyIPv4}}}');
    printSuccess(anyIPv4.address);

    // var ipAddress = IpAddress(type: RequestType.json);
    // dynamic data = await ipAddress.getIpAddress();
    // printSuccess(data['ip']);
    // printSuccess('{{{anyIPv4}}}');

    HttpServer.bind('169.254.238.60', 1996).then((server) {
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

  //create an object of ActiveMap<String, Map<String, dynamic>> to store the form results

  ActiveMap<String, Map<String, dynamic>> formResults = ActiveMap({});

  createMemory() async {
    printSuccess(await memory.insertMemory('hellos', 'World'));
    printSuccess(await memory.insertMemory('Jambos', 'Kenya'));
    printSuccess('{{{text}}}');
    updateMemory();
  }

  updateMemory() async {
    printSuccess(await memory.upsertMemory('hello', 'Asia'));
    printSuccess(await memory.upsertMemory('Jambo', DateTime.now().
    subtract(const Duration(days: 5)).toIso8601String()));
    printSuccess('{{{text text}}}');
    getMemory();
  }


  getMemory() async {
    printSuccess(await memory.readMemory('hellos'));
    printSuccess(await memory.readMemory('Jambos'));
    printSuccess(await memory.readMemory('hello'));
    printSuccess(await memory.readMemory('Jambo'));
    printSuccess('{{{}}}');
  }

}



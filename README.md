<h1 align="center">This is Activity</h1>  
<h4 align="center">A simple multiplatform State Manager that allows the full power of MVC with  
ZERO Packages. </h4>

### Badge

Are you using this library on your app? You can use a badge to tell others, you can Add the following code to your README.md or to your website to help others find a quick way to start understanding activity.

<a title="Made with Activity" href="https://github.com/itskenzylimon/Activity">  
  <img  
    src="https://img.shields.io/badge/Activity-State%20Manager-lightgrey"  
  >  
</a>

## Platforms

| Platform | Supported?        |
| -------- | ----------------- |
| Web      | ✅ Tried & Tested |
| MacOS    | ✅ Tried & Tested |
| Windows  | ✅ Tried & Tested |
| Linux    | ✅ Tried & Tested |
| Android  | ✅ Tried & Tested |
| iOS      | ✅ Tried & Tested |

1. [Introduction to Activity](#introduction-to-activity)
2. [Getting Started with Activity](#getting-started-with-activity)

   1. [Add Activity dependency](#1-add-activity-dependency)
   2. [Create Controller](#2-create-controller)
   3. [Create View](#2-create-view)
   4. [Create Main Class](#2-create-main)
   5. [Simple Example](#5-simple-example)

3. [Data Types](#data-types)
   1. [Boolean](#bool)
   2. [DateTime](#datetime)
   3. [Double](#double)
   4. [Int](#int)
   5. [List](#list)
   6. [Map](#map)
   7. [Models](#models)
   8. [String](#strings)
   9. [Type any](#type-any)
4. [Helper functions](#database-migration)
   1. [String](#helper-string)
5. [Cool Color Logger](#cool-color-logger)
6. [Memory](#ActiveMemory)
7. [ActiveSockets](#)
8. [ActiveRequests](#)
9. [Taskan Crud Example](#taskan-crud-example)
10. [Features Request & Bug Reports](#features-request-&-bug-reports)
11. [Contributing](#contributing)
12. [Articles and videos](#articles-and-videos)

## Get Started

Open `pubspec.yaml` and add activity package to your dependencies

```yaml
dependencies:
  activity: ^1.5.2+4
```

## Example app

A simple Crud based app using the Activity dependency.

### controller.dart

```dart
import 'package:activity/activity.dart';

class BaseController extends ActiveController {

}
```

### view.dart

```dart
import 'package:activity/activity.dart';

class TaskView extends ActiveView<BaseController> {
   const TaskView({super.key, required super.activeController});

   @override
   ActiveState<ActiveView<ActiveController>, BaseController> createActivity() =>
           _TaskViewState(activeController);
}

class _TaskViewState extends ActiveState<TaskView, BaseController> {
   _TaskViewState(super.activeController);

   @override
   Widget build(BuildContext context) {

   }

}
```

### main.dart

```dart

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   runApp(const MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});
   @override
   Widget build(BuildContext context) {
      return MaterialApp(
         title: 'Activity Task App',
         theme: ThemeData(primarySwatch: Colors.blue),
         home: Activity(
            BaseController(),
            onActivityStateChanged: ()=>
                    DateTime.now().microsecondsSinceEpoch.toString(),
            child: TaskView(
               activeController: BaseController(),
            ),
         ),
      );
   }
}

```

Activity allows developers to easily implement MVC architecture on there app, it doesn't get any  
harder than what you see, UI will rebuild the specified Widget automatically without stress giving  
you more time for implementation rather than spending countless hours working on your states.

## Global State Management

With Activity you can easily manage global states that affect the app across the apps cycle, states  
like settings configuration, user sessions and user / app data.

Create a MainController, you can place it at the root of the app

### controller.dart

```dart
import 'package:activity/activity.dart';

class MainController extends Controller {

  /// This override is needed
   @override
   List<ActiveType> get activities {
      return [];
   }

}
```

Change the `CupertinoApp` or `MaterialApp` to an `Activity` widget. you can optionally pass a  
unique identifier to track state id. NOTE: If you don't pass a unique identifier, Activity will  
use the current timestamp as the unique identifier.

### main.dart

```dart

import 'package:example/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:activity/activity.dart';

import 'model.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   runApp(const MyApp());
}

class MyApp extends StatelessWidget {
   const MyApp({super.key});

   @override
   Widget build(BuildContext context) {
      return MaterialApp(
         title: 'Activity Task App',
         theme: ThemeData(primarySwatch: Colors.blue),
         home: Activity(
            BaseController(),
            onActivityStateChanged: () =>
                    DateTime
                            .now()
                            .microsecondsSinceEpoch
                            .toString(),
            child: TaskView(
               activeController: BaseController(),
            ),
         ),
      );
   }
}

class TaskView extends ActiveView<BaseController> {
   const TaskView({super.key, required super.activeController});

   @override
   ActiveState<ActiveView<ActiveController>, BaseController> createActivity() =>
           _TaskViewState(activeController);
}

class _TaskViewState extends ActiveState<TaskView, BaseController> {
   _TaskViewState(super.activeController);

   @override
   void initState() {
      // TODO: implement initState
      super.initState();
      activeController.initCalculations();
   }

   // @override
   // void didChangeDependencies() {
   //   Activity.getActivity<BaseController>(context).totalTaskLevels();
   //   super.didChangeDependencies();
   // }

   @override
   Widget build(BuildContext context) {
      return MaterialApp(
         debugShowCheckedModeBanner: true,
         title: 'This is Activity',
         theme: ThemeData(
            primarySwatch: activeController.tasksLevel.value > 100 ? Colors.red : Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
         ),
         home: Scaffold(
            appBar: AppBar(
               title: const Text('Activity App'),
            ),
            body: SafeArea(
                    child: Column(
                       children: [
                          ifRunning(
                                  const CircularProgressIndicator(),
                                  otherwise: Expanded(
                                          child: Align(
                                             alignment: Alignment.topCenter,
                                             child: ListView.builder(
                                                itemCount: activeController.tasks.length,
                                                itemBuilder: (context, i) {
                                                   ActiveModel<Task> taskModel =
                                                   activeController.tasks[i];
                                                   return ListTile();
                                                },
                                             ),
                                          ))
                          )
                       ],
                    )),
         ),
      );
   }
}

```

Activity under the hood relies on Streams to track and update state in their respective widgets,

Apart from State Management, Activity can benefit a developer in many ways including

- Requires simplified development and code maintainability is easy .
- Apps built with Activity have incredibly less code lines.
- You have a wide variety of data types that extend to Activity, just by defining them you don't really need to follow up on UI state.
- You get to write better logic and fast implementation in a Dart, Most developers find it time-consuming tracking UI changes.
- Lastly but not the least, Activity allows developers to practice better  
  MVC architecture.

### How to use Activity effectively

- Create a Controller class that extends `ActiveController`
- Create a View class that extends `ActiveView` / `ActiveState`

---

- to get the controller instance, use `Activity.getActivity<Controller>(context)`
- use `ifRunning` to check if the controller is running
- use `activeAsync` to run a function **asynchronously** in the background. after the function is done, it
  will automatically handle setting **actively** status from true to false once done.
  > This can be helpful when you want to run **asynchronously** function in the background, and you don't want to manually set the **status**
  > to false when done or if you have a loading indicator that depends on the status of the controller.

```dart

/// loadTasks is your function that returns a Future<void>
/// inside this function you can call your service to fetch data from the server or the database.
/// We call activeAsync and pass a function with a isRunningKey key to make it easier to find the controller.
/// The function will run in the background and once done, it will automatically set the status to false and return
/// dynamic value from the function.
Future<void> loadTasks() async {
    final tasks = await activeAsync<Tasks>(
      () async => await taskService.getAllActiveTasks(),
      /// [isRunningKey] is a String value rep Activity running status, this value
      /// could be used to find the active [ActiveController].
      isRunningKey: 'loadTasks'
    );
}

```

- use `activateTypes` to activate controller types at the same time

```dart

  /// [activateTypes] allows multiple [ActiveType] to be updated at once and it
  /// will only trigger a single state change.
  ///
  /// [activeTypeList] is a [List<Map<ActiveType, dynamic>>], where keys are the
  /// properties you want to set, and the values are the new changes. Each map
  /// in the list must contain exactly one key/value pair.
  ///
  ///## Example
  ///
  late final ActiveType<String> taskName;
  late final ActiveType<int> taskScore;

  activateTypes([
     {taskName: 'Write Test Cases'},
     {taskScore: 5.5},
  ]);

```

- use `resetAllActiveTypes` to reset all active types to their default values

```dart
  /// [resetAllActiveTypes] will reset all [ActiveType] to their default values
  /// and trigger a single state change.
  ///
  ///## Example
  ///
  late final ActiveType<String> taskName;
  late final ActiveType<int> taskScore;

  resetAllActiveTypes();

```

- use `Fragment` to create a reactive widget that can be used in multiple places

```dart
  ///## Example Fragment
  ///

Fragment fragment = Fragment(
   activeController: TaskController(),
   viewContext: (BuildContext context) {
      /// access the TaskController() using Activity.getActivity
      TaskController activeController = Activity.getActivity<TaskController>(context);
      return Scaffold(
         appBar: AppBar(
            title: const Text('Activity Task App'),
         ),
         body: Center(
            child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                  const Text(
                     'You have pushed the button this many times:',
                  ),
                  GestureDetector(
                     child: const Text(
                        "close dialog",
                     ),
                     onTap: () {
                        Navigator.pop(context);
                     },
                  ),
               ],
            ),
         ),
      );
   },
);

/// Fragment can be used in multiple places like this
```

- use `ADialog` to create a reactive dialog that can be used in multiple places

```dart
  ///## Example Dialog

ADialog aDialog = ADialog(
   backgroundColor: Colors.red,
   margin: const EdgeInsets.all(100),
   activeController: activeController,
   viewContext: (BuildContext context) {
      return Scaffold(
         appBar: AppBar(
            title: const Text('Activity Task App'),
         ),
         body: Center(
            child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                  const Text(
                     'You have pushed the button this many times:',
                  ),
                  GestureDetector(
                     child: const Text(
                        "close dialog",
                     ),
                     onTap: () {
                        Navigator.pop(context);
                     },
                  ),
               ],
            ),
         ),
      );
   },
);

```

## Data Types

**Activity** will allow you to update your declared variables anywhere on the app code and rebuild the UI for the affected widgets Only.

Active Data Types have a _typeName_ and can be any key you assign the type to. It can really help when you want to update a value based on the assigned key _typeName_

_setToOriginal_ is function that extends any type of Active Type, it is meant to be used when you want to persist a value over
the applications lyfecycle. you can still update the current value but the original value will persist through out and you can easily access the original values. Under the hood it relies on Memory to persist data.

_setOriginalValueToCurrent_ this function function update the original value set by _setToOriginal_ to the current value, it will perform updates on the UI.

#### ActiveBool

- ActiveBool : extends the dart bool data type, meaning you can enjoy the benefits of the built in bool functions.

```dart

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

```

#### ActiveDateTime

- ActiveDateTime : extends the DateTime data type, meaning you can enjoy the benefits of the built in DateTime functions.

```dart
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
```

#### ActiveDouble

- ActiveDouble : extends the dart Double data type, meaning you can enjoy the benefits of the built in Double functions.

```dart
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

/// this will add 0.5 to the current value and does the needed updates activeDouble.add(0.5); // 2.0

/// this will subtract 1.0 to the current value and does the needed updates activeDouble.subtract(1.0); // 1.0

/// this will divide 1.0 by 0.5 to the current value and does the needed updates activeDouble.divide(0.5); // 2.0

/// this will multiply the value with 4 to the current value and does the needed updates
activeDouble.multiply(4); // 8.0

/// You can do updates to a field using [set] func, this will do the update
/// and do the ui rebuild on the affected widgets.
/// passing [notifyChange] as false will not do a UI rebuild
/// passing [setAsOriginal] as true will set the new value as
/// the original value.
activeDouble.set(99.99,
  notifyChange: false, setAsOriginal: true);

/// [value] will give you the current value
activeDouble.value;

```

#### ActiveInt

- ActiveInt : extends the dart Int data type, meaning you can enjoy the benefits of the built in Int functions.

```dart
/// INT
/// The [typeName] can be any key you assign the type to.
/// It can really help when you want to update a value based on the
/// assigned [typeName]
/// [ActiveDateTime] extends the dart int, meaning you can enjoy the benefits
/// of the built in int functions
/// [Activity] will allow you to update anywhere on the app code and rebuild UI
/// for the affected widgets Only
ActiveInt activeInt = ActiveInt(100, typeName: 'score'); // 1.5

/// You can easily [setOriginalValueToCurrent] ActiveInt back to original value
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
activeInt.set(50,
  notifyChange: false, setAsOriginal: true);

/// [value] will give you the current value
activeInt.value;
```

#### ActiveList

- ActiveList : extends the dart bool data type, meaning you can enjoy the benefits of the built in List functions.

```dart
/// List
/// The [typeName] can be any key you assign the type to.
/// It can really help when you want to update a value based on the
/// assigned [typeName]
/// [ActiveList] extends the dart bool, meaning you can enjoy the benefits
/// of the built in List functions
/// [Activity] will allow you to update anywhere on the app code and rebuild UI
/// for the affected widgets Only
ActiveList activeList = ActiveList([1,2,3], typeName: 'score'); // 1.5

/// You can easily [setOriginalValueToCurrent] ActiveDateTime back to original value
activeList.setOriginalValueToCurrent();
activeList.reset(notifyChange: true);

/// You can do updates to a field using [set] func, this will do the update
/// and do the ui rebuild on the affected widgets.
/// passing [notifyChange] as false will not do a UI rebuild
/// passing [setAsOriginal] as true will set the new value as
/// the original value.
activeList.set([0,9,8],
  notifyChange: false, setAsOriginal: true);

/// [value] will give you the current value
activeList.value;
```

#### ActiveMap

- ActiveMap : extends the dart bool data type, meaning you can enjoy the benefits of the built in Map functions.

```dart
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
activeMap.set({'key': 100},
  notifyChange: false, setAsOriginal: true);

/// [value] will give you the current value
activeMap.value;
```

#### ActiveModel

- ActiveModel : This is a user specified Model class, you can save a Model and have it reactive across the app cycle while enjoying the benefits that come with Model class.

```dart

Its a work in progress, should work as ActiveType for now, but more
features will be added soon. To make more data types reactive. and built
in functions to sync data.

Docs coming soon
```

#### ActiveString

- ActiveString : extends the dart String data type, meaning you can enjoy the benefits of the built in String functions.

```dart

/// ActiveString extend the normal String Type with activity helper functions
  ActiveString appTitle = ActiveString('First Title');

/// [Contains] Whether the string value contains a match of [other].
  appTitle.contains('First');

/// [isEmpty] Whether the string value is empty.
  appTitle.isEmpty;

/// [isNotEmpty] Whether the string value is not empty.
  appTitle.isNotEmpty;

/// [length] The length of the string value.
  appTitle.length;

/// To get the value of the string
  appTitle.value;

/// To set the value of the string
  appTitle.set('New Title');

```

#### ActiveType

- ActiveType : This is a Type Any data data type, It supports any kind of data be it a Color, Widget, Map, Styles...

```dart
/// ActiveType is a Type any with activity helper functions
  ActiveType appBackgroundColor = ActiveType(Colors.white);

  /// ActiveType is a Type any with activity helper functions
  ActiveType appBackgroundColor = ActiveType(Colors.white);

  ActiveType dateTime = ActiveType(DateTime.now());

```

## ActiveMemory

Active memory is meant to make data management of [activeTypes] fast and easy. You can easily get any type of datatype (Int, Strings, Booleans, Doubles, Map, Models and T Any kind of data) from within any state of the app.

### Instantiation

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Memory.instance(filename:"ttt.act").initMemory();
  runApp(const MyApp());
}
```

To reference an instance of Memory, use one of the following methods

```dart
///No need to pass [filename:"memory.txt"] since the filename created when initMemory() was called will not be overwritten
///Note: this will retrieve the current initialization of the Memory object
///It is not assured you will get the most current data using synchronous functions getString(), getBool(), getInt() and getDouble()
///To get most current data, either use the instantiation below or retrieve data using async function await memory.readMemory('key')
Memory memory = Memory.instance();
///Note: this will retrieve the current initialization of the Memory object as well as refetch data stored in memmory: use
///this if you want to access most current data using synchronous functions getString(), getBool(), getInt() and getDouble()
var memory = await Memory.instance().initMemory();
```

### Methods

Storage and retrieval methods are demonstrated in the code snippet below:

```dart

/// initialise Memory instance

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ///initialize memory
  await Memory.instance(filename:"memory.txt").initMemory();
  runApp(const MyApp());
}

///To retrieve an instance of Memory in another dart file, use one of the following ways:
///No need to pass [filename:"memory.txt"] since the filename created when initMemory() was called will not be overwritten
///Note: this will retrieve the current initialization of the Memory object
///It is not assured you will get the most current data using synchronous functions getString(), getBool(), getInt() and getDouble()
///To get most current data, either use the instantiation below or retrieve data using async function await memory.readMemory('key')
Memory memory = Memory.instance();
///Note: this will retrieve the current initialization of the Memory object as well as refetch data stored in memmory: use
///this if you want to access most current data using synchronous functions getString(), getBool(), getInt() and getDouble()
var memory = await Memory.instance().initMemory();

/// you can easily check if any data is saved on memory
memory.isDataEmpty

///Storing data
///Note: [Duration] is used to set length of time of validity of the data stored.
///String
///Future<bool> setString(String key, String value, {Duration? duration})
bool isStringSaved = await memory.setString('key', 'value');
///Bool
///Future<bool> setBool(String key, bool value, {Duration? duration})
bool isBoolSaved = await memory.setBool('key', true);
///Double
///Future<bool> setDouble(String key, Double value, {Duration? duration})
bool isDoubleSaved = await memory.setDouble('key', 3.2);
///Int
///Future<bool> setInt(String key, Int value, {Duration? duration})
bool? isIntSaved = await memory.setInt('key',9);

///store any type of data
///Future upsertMemory<T>(String key, T mem, {Duration? duration})
var savedData = await memory.upsertMemory('key', 'data');



///Reading data
///synchronous methods : no awaiting
String? stringVal = memory.getString('key');
bool? boolVal = memory.getBool('key');
Double? doubleVal = memory.getDouble('key');
Int? intVal = memory.getInt('key');

///asynchronous methods : needs awaiting : can be used to retrieve any data type
var data = await memory.readMemory('key');

```

```dart
Memory memory = Memory.instance();
memory.readMemories(); // Returns a a list of all memories stored
memory.readMemory('key'); // Returns the value of the key with its declared type
memory.readMemory('key',{bool value = false}); // Returns a key value map of the retrieved memory entry with it's createdAt and updatedAt dateTimes e.g:-
//{value: Asia, createdAt: 2023-06-14T14:00:37.920852, updatedAt: 2023-06-14T14:07:14.506855}

memory.insertMemory('key', value, {Duration? duration, bool persist = true}); // Creates an entry with the assigned value and key
memory.upsertMemory('key', value, {Duration? duration}); // Creates an entry and if the value exist it performs an upsert
memory.deleteMemory('key'); // Remove an entry from ActiveMemory
memory.resetMemory(); // This resets all the entries on ActiveMemory
memory.hasMemory(); // Checks if a key exists in ActiveMemory

```

## ActiveNavigation

Active Navigation is an abstraction on top of the flutter's Navigation API's to reduce boilerplate

```dart

/// Call the Nav class when depending on Activity
Nav.to(context,()=> View());

```

```dart
//Navigates to the next view in this case page View()
  Nav.to(context,()=> View());

///You can also pass arguments to the next page
    Nav.to(context,()=> View(),"Hello from First view");//takes arguments as Objects so you can pass any data type

//To get arguments passed on the second creen use this api
 Sreing argument =   Nav.getArguments();
 print(argument);//"Hello from First view"

//Pop off from a view
Nav.off(context);
//pop off all pages on the navigation stack to the page provided
Nav.offAll(context,()=> FirstView());

// Corresponding alternative for pushUntill api :
Nav.pushUntil(context,()=> FirstView(),()=> AnotherView());

```

## ActiveSockets

Activity allows you to connect with your severs using websocket easily, you can have full controll over the connection. ActiveSockets allows for easy integration between android/ios, windows/linux/macos and web.

```dart

/// You can have as many WebSocket instance as you wish and
/// they wont let you down.

/// initialise an ActiveSocket instance
ActiveSocket activeSocket = WebSocket();

// create an activeSocket connection to a wss/ws endpoint
activeSocket.open('wss://demo.piesocket.com/v3/channel_123?api_key=VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self');

// onSuccess callback to alert you when a successfull connection is made
activeSocket.onSuccess(() {
  print("onSuccess");
});

// onFailure callback to alert you when a failed connection is made
activeSocket.onFailure(() {
  print("onFailure");
});

// onMessage callback to alert you on new messages and pass data from server
activeSocket.onMessage((data) {
  print('onMessage @@@');
  print(data);
  if(data == 'Hello Activity'){
  activeSocket.send('Hello world....');
 }  print('onMessage');
});

// send function is used to send data to the channel you are connected to.
activeSocket.send('Hello world....');

// onClose callback used to alert you when a connection is closed.
activeSocket.onClose(() {
  print('onClose');
});
```

## ActiveRequests

Activity allows you to connect with your severs using HTTP Request easily, you can have full controll over the connection. ActiveRequests allows for easy integration between android/ios, windows/linux/macos and web.

```dart

/// initialise an ActiveRequest instance
ActiveRequest activeRequest = ActiveRequest();

/// setup  activeRequest instance with your prefered configuration.
/// you can setup as many setups as you want for the different use
/// cases, like authenticationSetup where you want each request to
/// pass authorization hearders ( Bearer Token ) or have another
/// setup contain return type specifics, or have different
/// baseURL. The use cases are as many as you want (i.e)

/// 1. int? idleTimeout = 1;
/// 2. int? connectionTimeout = 1;
/// 3. bool? logResponse = false;
/// 4. bool? withTrustedRoots = false;
/// 5. Map<String, String>? httpHeaders = {};
/// 6. String? privateKeyPath = '';
/// 7. String? schemePath = 'https';
/// 8. String? baseURL = '';
/// 9. String? privateKeyPassword = '';


/// request
  activeRequest.setUp = RequestSetUp(
          idleTimeout: 10,
          connectionTimeout: 20,
          logResponse: true,
          withTrustedRoots: true,
          httpHeaders: {
            "Authorization": "Bearer $access_token",
            "Content-type": "application/json"
          });
  /// you can do the complete [getApi], [postApi], [putApi] and
/// [deleteApi] and still get a successful [activeResponse].

///here is an implementation of [postApi]
/// set your parameters
Map<String, String> params = {
      'client_id': clientID.value,
      'client_secret': clientSecrete.value,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': callBackURL.value,
    };

///make the request
 ActiveResponse response = await activeRequest
   .postApi(Params(endpoint: 'https://catfact.ninja/fact', queryParameters: params));

///here is an implementation of [putApi]
/// initialise an ActiveRequest instance then setup
ActiveRequest activeRequest = ActiveRequest();
  activeRequest.setUp = RequestSetUp(
          idleTimeout: 10,
          connectionTimeout: 20,
          logResponse: true,
          withTrustedRoots: true,
          httpHeaders: {
            "Authorization": "Bearer $access_token",
            "Content-type": "application/json"
          });
 ActiveResponse activeResponse = await activeRequest.putApi(
  Params(endpoint: 'https://catfact.ninja/fact'),


  /// Makes a DELETE request.
  ///
  /// The [deleteApi] function performs a DELETE request using the specified [params].
  /// Set [saveResponse] to `true` if you want to save the response data.
  ///
  /// Returns an [ActiveResponse] representing the response data.
  ///
  /// Example:
/// initialise an ActiveRequest instance then setup
ActiveRequest activeRequest = ActiveRequest();
  activeRequest.setUp = RequestSetUp(
          idleTimeout: 10,
          connectionTimeout: 20,
          logResponse: true,
          withTrustedRoots: true,
          httpHeaders: {
            "Authorization": "Bearer $access_token",
            "Content-type": "application/json"
          });

   ActiveResponse activeResponse = await activeRequest.deleteApi(
     Params(endpoint: 'https://catfact.ninja/fact'),
     saveResponse: true,
   );
     /// Makes a Get request.
  ///
  /// The [getApi] function performs a DELETE request using the specified [params].
  /// Set [saveResponse] to `true` if you want to save the response data.

  /// initialise an ActiveRequest instance then setup
ActiveRequest activeRequest = ActiveRequest();
  activeRequest.setUp = RequestSetUp(
          idleTimeout: 10,
          connectionTimeout: 20,
          logResponse: true,
          withTrustedRoots: true,
          httpHeaders: {
            "Authorization": "Bearer $access_token",
            "Content-type": "application/json"
          });

  ActiveResponse activeResponse = await activeRequest.uploadFileApi(
     Params(endpoint: 'https://catfact.ninja/fact'),
     saveResponse: true,
     savedResponseName: 'cat_fact',
   );
     /// post a file request.
/// The [uploadFileApi] function uploads a file using the specified [params], [file],
  /// and [fileName]. You can provide additional [setUp] parameters for this specific upload request.
  /// Set [saveResponse] to `true` if you want to save the response data.

  /// initialise an ActiveRequest instance then setup
ActiveRequest activeRequest = ActiveRequest();
  activeRequest.setUp = RequestSetUp(
          idleTimeout: 10,
          connectionTimeout: 20,
          logResponse: true,
          withTrustedRoots: true,
          httpHeaders: {
            "Authorization": "Bearer $access_token",
            "Content-type": "application/json"
          });


    ActiveResponse activeResponse = await activeRequest.uploadFileApi(
     Params(endpoint: 'https://catfact.ninja/fact'),
        io.File('path/to/file'),
       'file.png',
     saveResponse: true,
     savedResponseName: 'cat_fact',
   );


```

## Helpers

Helpers are function that performs part of the computation of another function .  
Activity has helper functions that make programing fun while making your code much easier to read

### String Helper

```dart
import 'package:super_string/super_string.dart';

void main() {

    /// isUpperCase checks if a string is in uppercase
  _value = 'ACTIVITY'.isUpperCase; /// => true
  /// isLowerCase checks if a string is in lowercase
  _value = 'activity'.isLowerCase; /// => true
  /// toCamelCase converts a string to camelCase
  _value = 'I_love activity'.toCamelCase(); /// => 'iLoveActivity'
  /// containsAll checks if a string contains all the words in a list
  _value = 'I love activity'.containsAll(['activity','love']); /// => true
  /// containsAny checks if a string contains any of the words in a list
  _value = 'I love activity'.containsAny(['hello','activity']); /// => true
  /// title converts a string to title case
  _value = 'I loVE ACTIVITY'.title(); /// => I Love Activity
  /// capitalize converts a string to capitalize case
  _value = 'activity'.capitalize(); /// => Activity

    /// isAlNum checks if a string is alphanumeric
  _value = '123Activity'.isAlNum; /// => true
  /// isAlpha checks if a string is alphabetic
  _value = 'Activity'.isAlpha; /// => true
  /// isInteger checks if a string is an integer
  _value = '111'.isInteger; /// => true

  /// count counts the number of times a word appears in a string
  _value = 'activity'.count('i'); /// => 2
  /// iterable converts a string to a list of characters
  _value = 'Activity'.iterable; /// => ['A','c','t','i','v', 'i', 't', 'y']
  /// first returns the first character of a string
  _value = 'Activity'.first; /// => A
  /// last returns the last character of a string
  _value = 'Activity'.last; /// => y
  /// charAt returns the character at a given index
  _value = 'Activity'.charAt(0); /// => A

}
```

## Env Helper

Env helper is a helper that allows you to access your environment variables easily.
its ideal for storing sensitive information like API keys, database credentials, etc.

Store the .env file in the root of your project and add it to your .gitignore file.
data type is automatically detected and converted to the appropriate type.

Expect a Future Map<String, dynamic> with the following format.

```dart

import 'package:activity/activity.dart';

ENVSetup envSetup = ENVSetup();

/// if you change the path to the .env file,
/// you can pass it as a [filePath] parameter. Remember to use the
/// absolute path to the file. .env file must be in the root of your project build file if
/// not you can pass the path to the file as a parameter to the [readENVFile] function.

print(envSetup.readENVFile('your_project/build_root_path/.env'));

/// Example .env file
ID=123
KEY=QWE

/// returns a Future<Map<String, String>> with the following format.
{ID: 123, KEY: QWE}

```

## Activity Validation Setup:

**Activity** has a first-class support for object data validation, it works by defining a scheme with rules and assigning an object to [SchemaValidator.validate] for validation.

> Just define the **validation schema** and validate your **object** against it.

**SchemaValidator** supports a number of data types like String, Numbers, bool, Date, Email and Phone validations, and apart from those, it also supports Max and Min checks with optional and mandatory fields.

```dart

/// a sample json object to be validated, you can use any object.
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

  /// you can use the required to make a field mandatory.
  "name": {
  "type": String,
  "required": true,
  "min": 2,
  "max": 20
  },

   /// you can also use the email to validate the email address.
  "email": {
  "type": String,
  "required": true,
  "email": true,
 },

   /// you can also use the phone to validate the phone number.
"phone": {
  "type": String,
  "required": true,
  "phone": true,
 },

   /// you can also use the date to validate the date format.
"birthdate": {
  "type": String,
  "required": true,
  "date": true,
 },

   /// you can also use the min and max to validate the length of a string.
"address": {
  "type": String,
  "required": true,
  "min": 5,
  "max": 100
}
};

/// to validate the object against the schema, just pass the schema and the object to be validated.
/// returns a SchemaResponse object with the following format.
/// SchemaResponse({required this.valid, required this.schema, required this.errors});

/// Example validation function. that validates the sampleJSON against the registerSchema above.
validateJSON() async {
   SchemaValidator schemaValidator = SchemaValidator(registerSchema);
   // schemaValidator.customErrors = customErrorMessage;

   /// returns a SchemaResponse object with the following format.
   /// SchemaResponse({required this.valid, required this.schema, required this.errors});
   SchemaResponse schemaResponse = schemaValidator.validate(sampleJSON);
   if (schemaResponse.valid == false) {
     /// do something with the errors.
   } else {
     /// do something with the schema. at this point the schema is valid.
   }
}


```

**SchemaValidator** returns a **SchemaResponse** response Model that contains the need fields for your next steps, be it, database insert or parsing to the server.

##### Example Schema Response Model.

```dart
SchemaResponse({
  required this.valid,// boolean, a flag for checking valididty
  required this.schema,// dynamic Object, returns validated entries
  required this.errors,// dynamic Object, returns error entries
});
```

##### Custom Error Messages.

**SchemaValidator** also accepts passing your own **custom error messages**, this might help to make the responses a bit friendly than the generic ones.

```dart
/// You can pass your own [customErrorMessage] custom error messages to make
/// the return errors more readable and friendlier.
/// Keys have to match the ones on [Schema] and You [Object] Payload.
var customErrorMessage = {
  'name': 'Kindly Enter your Full Names',
  'birthdate': 'Enter a valid date',
};
```

In the bellow example we can see how easy it is to validate an object and get the right response to handle on your end, failed checks will still return a failed **SchemaResponse** with the specific errors and valid flag as false.

```dart
validateJSON(){
  SchemaValidator schemaValidator = SchemaValidator(registerSchema);
  // schemaValidator.customErrors = customErrorMessage;

  SchemaResponse schemaResponse = schemaValidator.validate(sampleJSON);
  if (schemaResponse.valid == false) {
  printError(schemaResponse.toString());
 } else {
  printSuccess(schemaResponse.toString());
 }}
```

Using a **SchemaValidator** is very easy and straight forward, you can use it to validate your **JSON** objects before sending them to the server, or before inserting them to the database.

#### Example Process Flow.

```mermaid
graph LR
A[Define A Schema with Payload] -- Pass Payload --> B((SchemaResponse))
B -- bool --> C(valid)
B -- valid Payload objects --> D{ schema }
B -- invalid Payload objects --> E{ errors }
```

# Example Apps

- [Example App](https://github.com/itskenzylimon/Taskan/example)

> **ProTip:** You can use **Activity** with your prefered router package **It will still work**.

## Features Request & Bug Reports

Feature requests and bugs at the [issue tracker](https://github.com/itskenzylimon/Activity/issues).

## Contributing

Activity is an open source project, and thus contributions to this project are welcome - please feel free to [create a new issue](https://github.com/itskenzylimon/Taskan/issues/new/choose) if you encounter any problems, or [submit a pull request](https://github.com/itskenzylimon/Taskan/pulls). For community contribution guidelines, please review the [Code of Conduct](CODE_OF_CONDUCT.md).

If submitting a pull request, please ensure the following standards are met:

1. Code files must be well formatted (run `flutter format .`).

2. Tests must pass (run `flutter test`). New test cases to validate your changes are highly recommended.

3. Implementations must not add any project dependencies.

4. Project must contain zero warnings. Running `flutter analyze` must return zero issues.

5. Ensure docstrings are kept up-to-date. New feature additions must include docstrings.

### Additional information

This package has **NO** dependencies.

© 2023
Developed by: [Kenzy Limon](https://kenzylimon.com)

Top Contributors: [Contributors](), [Contributors](), [Contributors](), [Contributors](), [Contributors]()

### Articles and videos

[Flutter Articles](https://medium.com/@itskenzylimon) - Medium Article

## Found this project useful? ❤️

If you found this project useful, then please consider giving it a ⭐️ on Github and sharing it with your friends via social media.

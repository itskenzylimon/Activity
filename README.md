<h1 align="center">This is Activity</h1>
<h4 align="center">A simple multiplatform State Manager that allows the full power of MVC with
ZERO Packages. </h4>

### Badge
Are you using this library on your app? You can use a badge to tell others, you can Add the following code to your README.md or to your website

<a title="Made with Activity" href="https://github.com/itskenzylimon/Activity">
  <img
    src="https://img.shields.io/badge/Activity-State%20Manager-lightgrey"
  >
</a>


## Platforms

| Platform 	| Supported? 	               |
|----------	|----------------------------|
| Web      	| ✅ Tried & Tested        	     |
| MacOS    	| ✅ Tried & Tested         	 |
| Windows  	| ✅ Tried & Tested         	               |
| Linux    	| ✅ Tried & Tested         	      |
| Android  	| ✅ Tried & Tested         	      |
| iOS      	| ✅ Tried & Tested         	      |

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
6. [Taskan Crud Example](#taskan-crud-example)
7. [Features Request & Bug Reports](#features-request-&-bug-reports)
8. [Contributing](#contributing)
9. [Articles and videos](#articles-and-videos)

## Get Started

Open `pubspec.yaml` and add activity package to your dependencies

```yaml
  dependencies:
    activity: ^1.0.0
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

* Requires simplified development and code maintainability is easy .
* Apps built with Activity have incredibly less code lines.
* You have a wide variety of data types that extend to Activity, just by defining them
you don't really need to follow up on UI state.
* You get to write better logic and fast implementation in a Dart, Most developers 
find it time-consuming tracking UI changes.
* Lastly but not the least, Activity allows developers to practice better
MVC architecture.
* Lastly again. 

## ActiveMemory

Active memory is meant to make data management of [activeTypes] fast and easy. You can easily get any type
of datatype (Int, Strings, Booleans, Doubles, Map, Models and T) from any state of the app.

```dart
Memory memory = Memory.memory;

memory.isDataEmpty

```

```dart

memory.readMemories(); // Returns a a list of all memories stored
memory.readMemory('key'); // Returns the value of the key with its declared type
memory.createMemory('key', value); // Creates an entry with the assigned value and key
memory.upsertMemory('key', value); // Creates an entry and if the value exist it performs an upsert
memory.updateMemory('key', value); // Performs an update on the key value 
memory.deleteMemory('key'); // Remove an entry from ActiveMemory
memory.resetMemory(); // This resets all the entries on ActiveMemory
memory.hasMemory(); // Checks if a key exists in ActiveMemory

```

## Helpers

Helpers are function that performs part of the computation of another function . 
Activity has helper functions that make programing fun while making your code much easier to read 
### String Helper

```dart
import 'package:super_string/super_string.dart';

void main() {
  
  _value = 'ACTIVITY'.isUpperCase; /// => true
  _value = 'activity'.isLowerCase; /// => true
  _value = 'I_love activity'.toCamelCase(); /// => 'iLoveActivity'
  _value = 'I love activity'.containsAll(['activity','love']); /// => true
  _value = 'I love activity'.containsAny(['hello','activity']); /// => true
  _value = 'I loVE ACTIVITY'.title(); /// => I Love Activity
  _value = 'activity'.capitalize(); /// => Activity
  
  _value = '123Activity'.isAlNum; /// => true
  _value = 'Activity'.isAlpha; /// => true
  _value = '111'.isInteger; /// => true

  _value = 'activity'.count('i'); /// => 2
  _value = 'Activity'.iterable; /// => ['A','c','t','i','v', 'i', 't', 'y']
  _value = 'Activity'.first; /// => A
  _value = 'Activity'.last; /// => y
  _value = 'Activity'.charAt(0); /// => A

}
```

# Example Apps

- [Example App](https://github.com/itskenzylimon/Taskan/example)

## Features Request & Bug Reports

Feature requests and bugs at the [issue tracker](https://github.com/itskenzylimon/Activity/issues).

## Contributing

Activity is an open source project, and thus contributions to this project are welcome - please feel free to [create a new issue](https://github.com/itskenzylimon/Taskan/issues/new/choose) if you encounter any problems, or [submit a pull request](https://github.com/itskenzylimon/Taskan/pulls). For community contribution guidelines, please review the [Code of Conduct](CODE_OF_CONDUCT.md).

If submitting a pull request, please ensure the following standards are met:

1) Code files must be well formatted (run `flutter format .`).

2) Tests must pass (run `flutter test`).  New test cases to validate your changes are highly recommended.

3) Implementations must not add any project dependencies.

4) Project must contain zero warnings. Running `flutter analyze` must return zero issues.

5) Ensure docstrings are kept up-to-date. New feature additions must include docstrings.



### Additional information

This package has **NO** dependencies.

Developed by:

© 2022 [Kenzy Limon](https://kenzylimon.com)

### Articles and videos

[Flutter Articles](https://medium.com/@itskenzylimon) - Medium Article

## Found this project useful? ❤️

If you found this project useful, then please consider giving it a ⭐️ on Github and sharing it with your friends via social media.
import 'package:activity/activity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// [Activator] :
/// intended to be used by [Activity]

class Activator<T extends ActiveController> extends InheritedWidget {
  const Activator(
    this._trackID, {
    Key? key,
    required super.child,
    required this.activeController,
  }) : super(key: key);

  final String? _trackID;
  final T Function() activeController;

  @override
  bool updateShouldNotify(covariant Activator oldWidget) {
    return oldWidget._trackID != _trackID;
  }
}

/// [Activity] :
/// Brings shared state to your application.
///
/// [activeController] : controller needed for state rebuilds when an [ActiveType]
/// [child] : is the widget intended to be rendered.
/// [onActivityStateChanged] : this function is called whenever an [ActiveType] is
/// updated on the state. Gets [Activity] inherited widget needs to be updated.
/// The _trackId needs to be updated uniquely to allow UI rebuilds to happen,
/// if you update with the same value a UI rebuild wont happen
/// [developerMode] : this is a flag that is responsible in debug print
///
///### Example Using Timestamp
///
///```dart
///
///      Activity(
///         BaseController(),
///         onActivityStateChanged: ()=>
///             DateTime.now().microsecondsSinceEpoch.toString(),
///         child: TaskView(
///           activeController: BaseController(),
///         ),
///       ),
///
///```
///
///
///```dart
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///  @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       title: 'Activity Task App',
///       theme: ThemeData(primarySwatch: Colors.blue),
///       home: Activity(
///         BaseController(),
///         onActivityStateChanged: ()=>
///             DateTime.now().microsecondsSinceEpoch.toString(),
///         child: TaskView(
///           activeController: BaseController(),
///         ),
///       ),
///     );
///   }
/// }
///
///```
class Activity<T extends ActiveController> extends StatefulWidget {
  final T activeController;
  final Widget child;
  final String Function() onActivityStateChanged;
  final bool developerMode;

  const Activity(
    this.activeController, {
    Key? key,
    required this.child,
    required this.onActivityStateChanged,
    this.developerMode = false,
  }) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState<T>();

  ///Gets the instance of the [Activator] that matches the generic type argument [T].
  ///
  ///You can access the associated view model via the returned
  ///[Activator]. However you'll most likely want to use
  ///the shorthand [getActivity] function to do so.

  /// Gets the current Controller based on the [Activator] and context.
  ///```dart
  /// Activity.getActivity<BaseController>(context).totalTaskLevels();
  ///```

  static Activator<T> of<T extends ActiveController>(BuildContext context) {
    final Activator<T>? result =
        context.dependOnInheritedWidgetOfExactType<Activator<T>>();
    assert(result != null, 'No Activity found in context');
    return result!;
  }

  /// Gets the current Controller based on the [Activator] and context.
  ///```dart
  /// Activity.getActivity<BaseController>(context).totalTaskLevels();
  ///```

  static T getActivity<T extends ActiveController>(BuildContext context) {
    final Activator<T> result = of(context);
    return result.activeController();
  }
}

class _ActivityState<T extends ActiveController> extends State<Activity> {
  String? _applicationStateId;

  @override
  void initState() {
    /// listen to the controller state changes
    widget.activeController.addOnStateChangedListener((events) {
      if (widget.developerMode && kDebugMode) {
        for (var event in events) {
          printInfo(event);
        }
      }
      if (mounted) {
        setState(() {
          _applicationStateId = widget.onActivityStateChanged();
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Activator<T>(
      _applicationStateId,
      activeController: <E extends ActiveController>() => widget.activeController as E,
      child: Builder(builder: (context) {
        return widget.child;
      }),
    );
  }
}

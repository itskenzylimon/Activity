import 'dart:async';
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
    return oldWidget._trackID != _trackID ||
        !identical(oldWidget.activeController(), activeController());
  }
}

/// Expose an existing shared controller to descendant consumers.
///
/// Create the controller outside build. Descendants borrow it; the owner disposes it. Replacing the controller rebinds scope subscriptions. Widget examples require Flutter, including Flutter web, rather than a plain Dart console.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#start) · browser route `/#/start`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Share a controller through a scope
///
/// <!-- activity-snippet: class-activity-t-1 -->
/// ```dart
/// import 'dart:async';
/// import 'package:activity/activity.dart';
/// import 'package:flutter/material.dart';
///
/// class CounterController extends ActiveController {
///   final count = ActiveInt(0);
///   @override
///   Iterable<ActiveType> get activities => [count];
/// }
///
/// void main() => runApp(const MaterialApp(home: CounterOwner()));
///
/// class CounterOwner extends StatefulWidget {
///   const CounterOwner({super.key});
///   @override
///   State<CounterOwner> createState() => _CounterOwnerState();
/// }
///
/// class _CounterOwnerState extends State<CounterOwner> {
///   final controller = CounterController();
///   @override
///   void dispose() {
///     unawaited(controller.dispose());
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) => Scaffold(
///     body: Activity<CounterController>(
///       controller,
///       child: Builder(
///         builder: (context) {
///           final shared = Activity.getActivity<CounterController>(context);
///           return TextButton(
///             onPressed: shared.count.increment,
///             child: Text('Count ${shared.count.value}'),
///           );
///         },
///       ),
///     ),
///   );
/// }
/// ```
///
/// ### Combine a scope and selective view
///
/// <!-- activity-snippet: class-activity-t-2 -->
/// ```dart
/// import 'dart:async';
/// import 'package:activity/activity.dart';
/// import 'package:flutter/material.dart';
///
/// class CounterController extends ActiveController {
///   final count = ActiveInt(0);
///   @override
///   Iterable<ActiveType> get activities => [count];
/// }
///
/// void main() => runApp(const MaterialApp(home: CounterOwner()));
///
/// class CounterOwner extends StatefulWidget {
///   const CounterOwner({super.key});
///   @override
///   State<CounterOwner> createState() => _CounterOwnerState();
/// }
///
/// class _CounterOwnerState extends State<CounterOwner> {
///   final controller = CounterController();
///   @override
///   void dispose() {
///     unawaited(controller.dispose());
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) => Scaffold(
///     body: Activity<CounterController>(
///       controller,
///       child: ActivitySelector<CounterController, int>(
///         controller: controller,
///         select: (c) => c.count.value,
///         builder:
///             (_, count, child) => TextButton(
///               onPressed: controller.count.increment,
///               child: Text('Count $count'),
///             ),
///       ),
///     ),
///   );
/// }
/// ```
class Activity<T extends ActiveController> extends StatefulWidget {
  final T activeController;
  final Widget child;
  final String Function()? onActivityStateChanged;
  final bool developerMode;

  const Activity(
    this.activeController, {
    Key? key,
    required this.child,
    this.onActivityStateChanged,
    this.developerMode = false,
  }) : super(key: key);

  @override
  State<Activity<T>> createState() => _ActivityState<T>();

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
    if (result == null) throw StateError('No Activity<$T> found in context');
    return result;
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

class _ActivityState<T extends ActiveController> extends State<Activity<T>> {
  StreamSubscription? _subscription;
  int _revision = 0;
  String? _applicationStateId;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _subscription = widget.activeController.addOnStateChangedListener((events) {
      if (widget.developerMode && kDebugMode) {
        for (var event in events) {
          printInfo(event);
        }
      }
      if (mounted) {
        setState(() {
          _applicationStateId =
              widget.onActivityStateChanged?.call() ?? "${++_revision}";
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant Activity<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.activeController, widget.activeController)) {
      unawaited(oldWidget.activeController.cancelSubscription(_subscription));
      _subscribe();
    }
  }

  @override
  void dispose() {
    unawaited(widget.activeController.cancelSubscription(_subscription));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.activeController;
    return Activator<T>(
      _applicationStateId,
      activeController: () => controller,
      child: Builder(
        builder: (context) {
          return widget.child;
        },
      ),
    );
  }
}

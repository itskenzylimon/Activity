import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// --------------------------------------------
/// Base Abstract View (for consistency only)
/// --------------------------------------------
abstract class ActiveViewBase extends StatefulWidget {
  const ActiveViewBase({super.key});
}

/// A stateful consumer bound to an existing typed controller.
///
/// Flutter owns State disposal; the application owns controller disposal. A view cancels its own subscription and must not dispose a shared controller. Use ActivitySelector when only a small derived value should rebuild.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#views) · browser route `/#/views`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Bind a whole view
///
/// <!-- activity-snippet: abstract-class-activeview-t-extends-1 -->
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
///   Widget build(BuildContext context) =>
///       Scaffold(body: CounterView(activeController: controller));
/// }
///
/// class CounterView extends ActiveView<CounterController> {
///   const CounterView({super.key, required super.activeController});
///   @override
///   ActiveState<ActiveView<CounterController>, CounterController>
///   createActivity() => _CounterViewState(activeController);
/// }
///
/// class _CounterViewState extends ActiveState<CounterView, CounterController> {
///   _CounterViewState(super.activeController);
///   @override
///   Widget build(BuildContext context) => TextButton(
///     onPressed: activeController.count.increment,
///     child: Text('Count ${activeController.count.value}'),
///   );
/// }
/// ```
///
/// ### Share the same owner with a scope
///
/// <!-- activity-snippet: abstract-class-activeview-t-extends-2 -->
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
///       child: CounterView(activeController: controller),
///     ),
///   );
/// }
///
/// class CounterView extends ActiveView<CounterController> {
///   const CounterView({super.key, required super.activeController});
///   @override
///   ActiveState<ActiveView<CounterController>, CounterController>
///   createActivity() => _CounterViewState(activeController);
/// }
///
/// class _CounterViewState extends ActiveState<CounterView, CounterController> {
///   _CounterViewState(super.activeController);
///   @override
///   Widget build(BuildContext context) => TextButton(
///     onPressed: activeController.count.increment,
///     child: Text('Count ${activeController.count.value}'),
///   );
/// }
/// ```
abstract class ActiveView<T extends ActiveController> extends ActiveViewBase {
  final T activeController;
  final bool developerMode;

  const ActiveView({
    Key? key,
    required this.activeController,
    this.developerMode = false,
  }) : super(key: key);

  @override
  // The factory is a supported public extension point.
  // ignore: no_logic_in_create_state
  ActiveState<ActiveView<T>, T> createState() => createActivity();

  /// Return your strongly typed [ActiveState] instance.
  ActiveState<ActiveView<T>, T> createActivity();
}

/// --------------------------------------------
/// Legacy ActiveView (no generic relation)
/// --------------------------------------------
///
/// Use this for older code where you can't refactor views to match
/// `ActiveView<T>` and `ActiveState<ActiveView<T>, T>` constraints.
abstract class ActiveViewLegacy<T extends ActiveController>
    extends ActiveViewBase {
  final T activeController;
  final bool developerMode;

  const ActiveViewLegacy({
    Key? key,
    required this.activeController,
    this.developerMode = false,
  }) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  ActiveState<ActiveViewLegacy<T>, T> createState() => createActivity();

  /// Return your loosely-typed legacy [ActiveState] instance.
  ActiveState<ActiveViewLegacy<T>, T> createActivity();
}

/// --------------------------------------------
/// Shared ActiveState<T, E>
/// --------------------------------------------
///
/// Works with both modern and legacy views via generic constraints.
abstract class ActiveState<T extends ActiveViewBase, E extends ActiveController>
    extends State<T> {
  /// The controller attached to this state.
  E activeController;

  /// Listener for state change events.
  StreamSubscription? _stateSubscription;

  /// Indicates whether controller is running async operations.
  bool get isRunning => activeController.actively;

  /// Constructor to inject the controller.
  ActiveState(this.activeController);

  @override
  void initState() {
    super.initState();

    _subscribe();
  }

  void _subscribe() {
    _stateSubscription = activeController.addOnStateChangedListener((events) {
      if (!mounted) return;

      // Print debug logs if developerMode is enabled
      final devMode =
          (widget is ActiveView && (widget as ActiveView).developerMode) ||
          (widget is ActiveViewLegacy &&
              (widget as ActiveViewLegacy).developerMode);

      if (devMode && kDebugMode) {
        for (final event in events) {
          debugPrint('[Activity] ${event.toString()}');
        }
      }

      setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = widget;
    final E next =
        (current is ActiveView
                ? current.activeController
                : current is ActiveViewLegacy
                ? current.activeController
                : activeController)
            as E;
    if (!identical(next, activeController)) {
      unawaited(activeController.cancelSubscription(_stateSubscription));
      activeController = next;
      _subscribe();
    }
  }

  /// Conditionally render a busy indicator or fallback widget.
  Widget ifRunning(Widget busyIndicator, {required Widget otherwise}) {
    return isRunning ? busyIndicator : otherwise;
  }

  /// Restore original values without disposing this view or its shared controller.
  void resetActivities() {
    activeController.resetAllActiveTypes();
  }

  @override
  void dispose() {
    unawaited(activeController.cancelSubscription(_stateSubscription));
    super.dispose();
  }
}

import 'package:activity/activity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';


/// [ActiveView]
///
/// The starting class for widgets that need to be active when state changes
///
/// [ActiveView] Requires a class that extends [ActiveController] to be passed
/// to the [activeController]. [ActiveController] is responsible for
/// notifying when UI needs to be updated.
///
///### [CaseStudy]
///
///```dart
///class MainView extends ActiveView<MainController> {
///
///    const MainView({super.key, required super.activeController});
///
///    @override
///    ActiveState<ActiveView<ActiveController>, MainController> createActivity() => _MyWidgetState(activeController);
///
///}
///```
abstract class ActiveView<T extends ActiveController> extends StatefulWidget {
  final T activeController;
  final bool developerMode;
  const ActiveView({
    Key? key,
    required this.activeController,
    this.developerMode = false,
  }) : super(key: key);

  ///Create an instance of [ActiveState] for the UI.
  ///
  ///**NOTE**
  ///[createActivity] overrides the [createState] function. Overriding this
  ///function and the [createState] function can have unintended side affects.
  ActiveState<ActiveView, T> createActivity();

  /// [createActivity]
  /// handles the creation of the UI state.
  ///**NOTE**
  /// Avoid overriding this function. Overriding this function can have
  /// unintended exceptions.

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return createActivity();
  }
}

/// [ActiveState]
/// Base class for your [ActiveView] State class. Will automatically trigger a
/// rebuild when objects change in [ActiveController] [ActiveType]
///
///### Usage
///
///```dart
///class _CounterPageState extends ActiveState<CounterPage, CounterViewModel> {
///  _CounterPageState(super.activeController);
///
///  @override
///  Widget build(BuildContext context) {
///    return Scaffold(
///      appBar: AppBar(
///        title: Text(activeController.title),
///      ),
///      body: Center(
///        child: Column(
///          mainAxisAlignment: MainAxisAlignment.center,
///          children: <Widget>[
///            const Text(
///              'You have pushed the button this many times:',
///            ),
///            Text(
///              '${activeController.count}',
///            ),
///          ],
///        ),
///      ),
///      floatingActionButton: FloatingActionButton(
///        onPressed: activeController.incrementCounter,
///        tooltip: 'Increment',
///        child: const Icon(Icons.add),
///      ),
///    );
///  }
///}
///```
abstract class ActiveState<T extends ActiveView, E extends ActiveController>
    extends State<T> {
  late final E activeController;

  /// [isRunning]
  /// Used to determine if the [activeController] is actively running
  bool get isRunning => activeController.actively;

  ActiveState(this.activeController) {
    activeController.addOnStateChangedListener((events) {
      if (widget.developerMode && kDebugMode) {
        // ignore: avoid_print
        events.forEach(print);
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// [ifRunning]
  /// Shows [busyIndicator] when [activeController] is Running a long task

  Widget ifRunning(Widget busyIndicator, {required Widget otherwise}) {
    return isRunning ? busyIndicator : otherwise;
  }

  /// [resetActivities]
  /// Reset States. It is what it is
  void resetActivities() {
    activeController.resetActivities();
    super.dispose();
  }
}

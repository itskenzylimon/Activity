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

/// --------------------------------------------
/// Modern ActiveView<T>
/// --------------------------------------------
///
/// Preferred for all new views.
///
/// Provides tight binding between the controller and the view.
abstract class ActiveView<T extends ActiveController> extends ActiveViewBase {
  final T activeController;
  final bool developerMode;

  const ActiveView({
    Key? key,
    required this.activeController,
    this.developerMode = false,
  }) : super(key: key);

  @override
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
  late final E activeController;

  /// Listener for state change events.
  late final StreamSubscription _stateSubscription;

  /// Indicates whether controller is running async operations.
  bool get isRunning => activeController.actively;

  /// Constructor to inject the controller.
  ActiveState(this.activeController);

  @override
  void initState() {
    super.initState();

    // Safe listener registration after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stateSubscription = activeController.addOnStateChangedListener((events) {
        if (!mounted) return;

        // Print debug logs if developerMode is enabled
        final devMode = (widget is ActiveView && (widget as ActiveView).developerMode) ||
            (widget is ActiveViewLegacy && (widget as ActiveViewLegacy).developerMode);

        if (devMode && kDebugMode) {
          for (final event in events) {
            debugPrint('[Activity] ${event.toString()}');
          }
        }

        setState(() {});
      });
    });
  }

  /// Conditionally render a busy indicator or fallback widget.
  Widget ifRunning(Widget busyIndicator, {required Widget otherwise}) {
    return isRunning ? busyIndicator : otherwise;
  }

  /// Manually reset the controller and dispose the view.
  void resetActivities() {
    activeController.resetActivities();
    dispose();
  }

  @override
  void dispose() {
    _stateSubscription.cancel();
    super.dispose();
  }
}

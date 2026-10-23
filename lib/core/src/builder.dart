import 'dart:async';
import 'package:flutter/widgets.dart';
import 'controller.dart';

/// Rebuild a subtree only when its immutable selected value changes under ==.
///
/// Select scalars or immutable records, not a collection mutated in place. The application owns the shared controller and the selector owns its subscription.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#views) · browser route `/#/views`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Select a counter
///
/// <!-- activity-snippet: class-activityselector-c-1 -->
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
///     body: ActivitySelector<CounterController, int>(
///       controller: controller,
///       select: (c) => c.count.value,
///       builder:
///           (_, count, child) => TextButton(
///             onPressed: controller.count.increment,
///             child: Text('Count $count'),
///           ),
///     ),
///   );
/// }
/// ```
///
/// ### Select a derived property
///
/// <!-- activity-snippet: class-activityselector-c-2 -->
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
///     body: ActivitySelector<CounterController, bool>(
///       controller: controller,
///       select: (c) => c.count.value.isEven,
///       builder:
///           (_, even, child) => TextButton(
///             onPressed: controller.count.increment,
///             child: Text(even ? 'Even' : 'Odd'),
///           ),
///     ),
///   );
/// }
/// ```
class ActivitySelector<C extends ActiveController, V> extends StatefulWidget {
  final C controller;
  final V Function(C) select;
  final Widget Function(BuildContext, V, Widget?) builder;
  final Widget? child;
  const ActivitySelector({
    super.key,
    required this.controller,
    required this.select,
    required this.builder,
    this.child,
  });
  @override
  State<ActivitySelector<C, V>> createState() => _ActivitySelectorState<C, V>();
}

class _ActivitySelectorState<C extends ActiveController, V>
    extends State<ActivitySelector<C, V>> {
  StreamSubscription? _subscription;
  late V _selected;
  void _subscribe() {
    _selected = widget.select(widget.controller);
    _subscription = widget.controller.addOnStateChangedListener((_) {
      if (!mounted) return;
      final next = widget.select(widget.controller);
      if (next != _selected) setState(() => _selected = next);
    });
  }

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant ActivitySelector<C, V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      unawaited(oldWidget.controller.cancelSubscription(_subscription));
      _subscribe();
    } else {
      _selected = widget.select(widget.controller);
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _selected, widget.child);
  @override
  void dispose() {
    unawaited(widget.controller.cancelSubscription(_subscription));
    super.dispose();
  }
}

# Activity counter

This standalone example requires only Activity 2.0.0 and Flutter. Copy it into an
app's `lib/main.dart` after adding `activity: ^2.0.0` to its pubspec (use the local
checkout until publication). The root owns the controller; the selector borrows it.

[Source file](activity_example.dart) · [Full workspace gallery](README.md)

```dart
import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';

/// Standalone pub.dev example: only Activity and Flutter are required.
/// Copy into your app's lib/main.dart after adding activity: ^2.0.0.
void main() => runApp(const ActivityExample());

class CounterController extends ActiveController {
  final count = ActiveInt(0);
  @override
  Iterable<ActiveType> get activities => [count];
}

class ActivityExample extends StatefulWidget {
  const ActivityExample({super.key});
  @override
  State<ActivityExample> createState() => _ActivityExampleState();
}

class _ActivityExampleState extends State<ActivityExample> {
  // This owner creates and disposes one controller. Views borrow it.
  final controller = CounterController();
  @override
  void dispose() {
    unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: const Color(0xFF1888B0)),
    home: Scaffold(
      appBar: AppBar(title: const Text('Activity counter')),
      body: Center(
        child: ActivitySelector<CounterController, int>(
          controller: controller,
          select: (c) => c.count.value,
          builder: (_, count, child) => Text('Count: $count'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.count.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    ),
  );
}
```

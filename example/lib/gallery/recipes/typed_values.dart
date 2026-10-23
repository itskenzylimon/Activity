import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import '../result_terminal.dart';
import '../source_panel.dart';
import '../widgets.dart';

/// Nullable metadata from an optional profile endpoint. Register every wrapper
/// so resets and updates participate in the feature's lifecycle.
class OptionalProfileController extends ActiveController {
  final age = ActiveNullableInt();
  final score = ActivityNullableDoubleProperty();
  final consent = ActiveNullableBool();
  final nickname = ActiveNullableString();
  final seen = ActivityNullableDateTimeProperty();
  final role = createActiveNullableType<String>();
  final metadata = createActiveNullableModel<Map<String, String>>();
  @override
  Iterable<ActiveType> get activities => [
    age,
    score,
    consent,
    nickname,
    seen,
    role,
    metadata,
  ];
  void populate() => activate([
    age.changeTo(28),
    score.changeTo(4.5),
    consent.changeTo(true),
    nickname.changeTo('Kenzy'),
    seen.changeTo(DateTime.utc(2026, 10, 20)),
    role.changeTo('member'),
    metadata.changeTo({'source': 'sample endpoint'}),
  ]);
  Map<String, Object?> get snapshot => {
    'age': age.value,
    'score': score.value,
    'consent': consent.value,
    'nickname': nickname.value,
    'lastSeen': seen.value?.toIso8601String(),
    'role': role.value,
    'metadata': metadata.value,
  };
}

class OptionalProfileDemo extends StatefulWidget {
  const OptionalProfileDemo({super.key});
  @override
  State<OptionalProfileDemo> createState() => _OptionalProfileDemoState();
}

class _OptionalProfileDemoState extends State<OptionalProfileDemo> {
  final controller = OptionalProfileController();
  @override
  void dispose() {
    unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SourceLocation(
    page: 'lib/gallery/recipes/typed_values.dart',
    child: DemoCard(
      title: 'Optional profile · all nullable wrappers',
      description:
          'Combine nullable numbers, booleans, text, dates and typed factories. Populate in a batch; reset to the original absent values.',
      code: '''import 'package:activity/activity.dart';
final age = ActiveNullableInt();
final score = ActivityNullableDoubleProperty();
final seen = ActivityNullableDateTimeProperty();
final role = createActiveNullableType<String>();
// Register fields in activities; prefer immutable models for nested data.
age.setIfNull(() => 28);
role('member');
// The full source contains the owning controller, every wrapper and cleanup.''',
      child: ActivitySelector<OptionalProfileController, Map<String, Object?>>(
        controller: controller,
        select: (c) => c.snapshot,
        builder: (context, state, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: controller.populate,
                  child: const Text('Populate optional profile'),
                ),
                OutlinedButton(
                  onPressed: controller.resetAllActiveTypes,
                  child: const Text('Reset nullable profile'),
                ),
              ],
            ),
            ResultTerminal(status: 'Nullable profile snapshot', output: state),
          ],
        ),
      ),
    ),
  );
}

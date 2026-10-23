import 'active_type.dart';

abstract class ActiveModelValue<T> {
  T? get value;
}

/// Reactive application models, including immutable records.
///
/// Register models with scalar fields. Prefer copyWith or immutable replacements; nested objects are not automatically deep-copied.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#models) · browser route `/#/models`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Replace an immutable record
///
/// <!-- activity-snippet: class-activemodel-t-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = ActiveModel<(String, int)>(('Ada', 1));
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value.updateValue((profile) => (profile.$1, profile.$2 + 1));
///     assert(controller.value.value.$2 == 2);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
///
/// ### Snapshot a nullable model
///
/// <!-- activity-snippet: class-activemodel-t-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// class SampleController extends ActiveController {
///   final value = createActiveNullableModel<String>();
///   @override
///   Iterable<ActiveType> get activities => [value];
/// }
///
/// Future<void> main() async {
///   final controller = SampleController(); // This function owns it.
///   try {
///     controller.value('Ready');
///     controller.value.reset();
///     assert(controller.value.isNull);
///   } finally {
///     await controller.dispose(); // Views borrowing it must not dispose it.
///   }
/// }
/// ```
class ActiveModel<T> extends ActiveType<T> implements ActiveModelValue<T> {
  ActiveModel(super.value, {super.typeName});
}

ActiveModel<T> createActiveModel<T>(T value, {String? typeName}) =>
    ActiveModel(value, typeName: typeName);
ActiveModel<T?> createActiveNullableModel<T>({String? typeName}) =>
    ActiveModel<T?>(null, typeName: typeName);

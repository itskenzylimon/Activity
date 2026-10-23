import 'dart:math';

/// Generate a fresh random RFC 4122 version 4 identifier per call.
///
/// Random UUIDs have probabilistic uniqueness. They are identifiers, not authentication credentials.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#helpers) · browser route `/#/helpers`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Create a draft identifier
///
/// <!-- activity-snippet: class-uniqueid-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// void main() {
///   final id = UniqueID.generateUuid();
///   assert(id.length == 36 && id[14] == '4');
/// }
/// ```
///
/// ### Assign identifiers to independent drafts
///
/// <!-- activity-snippet: class-uniqueid-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
///
/// void main() {
///   final drafts = List.generate(
///     3,
///     (_) => {'id': UniqueID.generateUuid(), 'title': ''},
///   );
///   assert(drafts.map((draft) => draft['id']).toSet().length == 3);
/// }
/// ```
class UniqueID {
  static final Random _random = Random.secure();
  static String generateUuid() {
    final bytes = List.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

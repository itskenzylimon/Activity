# Feature workflows

[Package guide](../README.md) · [Gallery source](../example/lib/gallery) ·
[Routing cookbook](ROUTING.md) · [API example checks](API_SNIPPETS.md)

These recipes connect individual APIs into application workflows. The gallery's
19 sections provide live controls, source tabs and results; library Dartdoc has
complete runnable programs checked by `tool/check_doc_examples.dart`.

## 1. Register state, then select the smallest meaningful result

```dart
class Basket extends ActiveController {
  final quantities = ActiveMap<String, int>({});
  final coupon = ActiveString('');
  @override
  Iterable<ActiveType> get activities => [quantities, coupon];
}
```

Register every wrapper in `activities`; unregistered wrappers do not participate
in controller notification/reset. Provide one Basket through `Activity(basket,
child: ...)`, then use an ActivitySelector that returns a scalar/immutable record,
for example `(itemCount, coupon)`. Returning the mutable map itself can hide a
change behind unchanged identity. Prefer `snapshot` or derived immutable values.
Batch related changes when they represent one user action; the controller batch
is a notification boundary, not an ACID database transaction.

Expected result: editing the coupon rebuilds coupon-dependent UI, while unrelated
consumers remain unchanged. See [values/collections](../example/README.md#values-and-collections)
and [selector regressions](../test/state/regressions_test.dart).

## 2. Keep form drafts until persistence succeeds

Keep editable TextEditingController state in the form owner. Validate input,
await the save service, then publish the confirmed result into controller state.
Keep draft text on error; surface the error beside the form. For local SQLite,
the gallery's [database recipe](../example/lib/gallery/recipes/database_controller.dart)
borrows an application-owned QuickeyDB database and awaits writes before reload.
The repository/controller should not close a shared database after each query.

Navigation `onExit` handles unsaved drafts; it does not save automatically. A
route redirect should never perform an irreversible save. On success, return a
typed result to the calling screen and check `context.mounted` before showing UI.

## 3. Handle overlapping searches deliberately

`activeAsync` reports tracked work; it cannot cancel a service request. Give each
search a generation token and only apply a response if it still belongs to the
current query and the controller is open. A finally block from an obsolete
request must not clear the newest request's state. The
[workbench](../example/lib/gallery/recipes/workbench.dart) demonstrates this pattern.

Decide whether requests can overlap, replace one another or queue. Transport
cancellation belongs to your HTTP/database service; controller disposal merely
prevents stale state publication. Test both completion orders and the case where
a controller is disposed before an asynchronous error arrives.

## 4. Communicate with scoped events

Use Deamon for transient, isolate-local notifications where a shared controller
would create unnecessary coupling. Subscribe once in the consumer lifecycle and
cancel that subscription on disposal. Use sticky replay only for a deliberate
latest-value cache, and reset it when its owner/session ends. Sticky caches use
an exact generic type: a subscriber to one type does not receive every subtype's
cached event. Events do not persist, cross isolates or synchronize browser tabs.

See [events](../example/README.md#events-and-async-work) and
[replay contracts](../test/events/replay_test.dart). Persistent domain state belongs
in a controller/store rather than a hidden chain of event handlers.

## 5. Translate meaning, not English string fragments

```dart
final sentence = IcuMessage(
  '{count, plural, =0{No messages} one{# message} other{# messages}}',
).format(locale: 'en', parameters: {'count': 2}); // 2 messages
```

Give translators the complete sentence and an `other` branch. Locale cardinal
categories differ; a fallback message uses the fallback locale's rules. Nested
select/plural supports gender/category variation. Quote literal ICU syntax in
translations. Keep generated/user text as parameters rather than appending it to
the pattern. Format dates/currency before interpolation: date/number skeletons,
selectordinal, rich text and MessageFormat 2 are outside the supported scope.

See the gallery's four locale assets and [ICU tests](../test/localization/icu_message_test.dart).
Cache compiled patterns if formatting repeatedly; do not repeatedly read asset
files inside a widget build.

## 6. Separate navigation restoration from durable domain state

A tab history remembers where you were. RestorableInt remembers a restorable
widget counter. Neither guarantees that an unsaved record or controller model
survives a full browser reload. Store durable application data explicitly, await
writes, and reload it on startup. Keep stable identifiers in URLs and handle a
direct link to a deleted/missing record with a recoverable empty state.

Use [the routing cookbook](ROUTING.md) for retained tabs, typed results, transition
pages and extra codecs. Avoid placing whole mutable models in path/query values.
A pending picker future is tied to its current process and cannot be restored.

## 7. Own resources once and test the failure paths

Create controllers, routers, localization delegates, event subscriptions and
service handles in their owner, outside build. Dispose only resources that owner
created. Resetting values and disposing are different operations: a disposed
controller must not be reused after reset. Inject a fake service for deterministic
UI tests, then retain a smaller integration suite for real I/O.

| Workflow | Essential cases |
| --- | --- |
| Save form | Success, validation, service error, double tap, disposed owner |
| Search | Both completion orders, empty result, cancellation, late error |
| Routing | Encoded IDs, direct link, guards, back, result, stale guard, restart |
| Localization | Missing key, fallback locale, malformed pattern, plural categories |
| Event consumer | Replay, no replay, cancellation, owner replacement |

ENV assets and browser source are public configuration; they are unsuitable for
secrets. Client-side guards improve navigation UX and do not authorize server
operations. Local validation is not proof a remote service will accept a value.

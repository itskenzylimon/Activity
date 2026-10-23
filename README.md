# Activity

<img src="https://raw.githubusercontent.com/itskenzylimon/Activity/main/assets/activity.svg" width="112" alt="Activity logo">

**Flutter application state — typed controllers, nested navigation, ICU messages.**

[Start learning](#new-to-activity) · [Complete example](#setup-and-a-complete-example) ·
[Nested routes](#nested-routes-and-named-navigation) · [Shells and tabs](#shell-layouts-and-independent-tabs) ·
[Restoration](#state-restoration-and-browser-urls) · [ICU messages](#icu-pluralization-and-select-messages) ·
[Runnable app](https://github.com/itskenzylimon/Activity/blob/main/example/README.md) · [Test map](https://github.com/itskenzylimon/Activity/blob/main/test/README.md) · [Compatibility notes](https://github.com/itskenzylimon/Activity/blob/main/CHANGELOG.md) · [Publishing checklist](https://github.com/itskenzylimon/Activity/blob/main/doc/RELEASING.md)

| Build with | Use it for |
| --- | --- |
| Controllers and reactive values | Typed application state, shared logic and asynchronous task tracking |
| ActiveView, Activity and selectors | Whole-view updates, inherited controller access and targeted rebuilds |
| Nested routes and shell layouts | Deep links, shared navigation chrome and independent tab histories |
| Restorable navigation and async guards | Restoring destinations, checking sessions and confirming route exits |
| Configurable localization and ICU messages | Asset/existing-project translations, language fallback, plural and gender selection |
| Validation, ENV and typed helpers | Form checks, configuration parsing and observable value transformations |

> Explore the [Material feature gallery](https://github.com/itskenzylimon/Activity/blob/main/example/README.md): 19 searchable
> sections with live previews, copyable source, state helpers, events, async work,
> nested routing, restoration, four ICU locales and a practical to-do/do-not-do
> checklist. Includes responsive navigation, theme/accent settings and a live console.

Activity is a Flutter library for controller-owned state and application plumbing.
Routing is implemented directly with Flutter's **Router, Navigator and PopScope**:
nested paths, retained tabs, typed results, asynchronous guards and restoration
are Activity APIs. **intl** supplies locale cardinal rules and number formatting.
The declared minimum remains **Dart 3.7.2 / Flutter 3.29.0**. This guide describes
**2.0.0**; follow the [release checklist](https://github.com/itskenzylimon/Activity/blob/main/doc/RELEASING.md) before uploading it.
`intl >=0.19.0 <0.21.0` accommodates Flutter's localization SDK pins.

Read the [routing cookbook](https://github.com/itskenzylimon/Activity/blob/main/doc/ROUTING.md) for complete setup, deep links,
transitions, guards and integration boundaries, and the
[feature recipes](https://github.com/itskenzylimon/Activity/blob/main/doc/FEATURE_RECIPES.md) for controller, async, event and ICU workflows.

See [Observations.md](https://github.com/itskenzylimon/Activity/blob/main/Observations.md) for implementation status and validation
limits. Navigation restoration does not persist controller models, and client
configuration does not provide server-side authorization or secret storage.

## Feature examples and API comments

Public feature comments include **2–3 complete Dart examples** with imports,
controller ownership and disposal, and links to the corresponding
[gallery walkthroughs](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#feature-walkthroughs). Browse them in
editor hovers or generated Dartdoc; the [snippet index](https://github.com/itskenzylimon/Activity/blob/main/doc/API_SNIPPETS.md)
explains browser requirements and how all 57 marked examples are checked.

| Feature | Example walkthrough | API source |
| --- | --- | --- |
| Scalars, nullable values and helpers | [Reactive values](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#values) | [Typed values](https://github.com/itskenzylimon/Activity/blob/main/lib/core/types/active_type.dart) |
| Lists, maps and immutable models | [Collections](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#collections), [models](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#models) | [List](https://github.com/itskenzylimon/Activity/blob/main/lib/core/types/active_list.dart), [map](https://github.com/itskenzylimon/Activity/blob/main/lib/core/types/active_map.dart) |
| Scopes, views and selectors | [Rebuild behavior](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#views) | [Selector](https://github.com/itskenzylimon/Activity/blob/main/lib/core/src/builder.dart) |
| Async work, errors and cleanup | [Tasks and recovery](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#async) | [Controller](https://github.com/itskenzylimon/Activity/blob/main/lib/core/src/controller.dart) |
| Events and subscriptions | [Events and replay](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#events) | [Deamon](https://github.com/itskenzylimon/Activity/blob/main/lib/core/events/deamon.dart) |
| Routes and typed results | [Navigation](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#navigation) | [Router](https://github.com/itskenzylimon/Activity/blob/main/lib/core/navigation/activity_router.dart) |
| Locale loading, interpolation and ICU | [Localization](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#localization) | [Delegate](https://github.com/itskenzylimon/Activity/blob/main/lib/core/localization/localizations.dart), [formatter](https://github.com/itskenzylimon/Activity/blob/main/lib/core/localization/icu_message.dart) |
| Forms and configuration | [Validation](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#validation), [ENV](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#environment) | [Validator](https://github.com/itskenzylimon/Activity/blob/main/lib/core/helpers/schema_validator.dart), [ENV](https://github.com/itskenzylimon/Activity/blob/main/lib/core/helpers/env.dart) |

[Open the example guide](https://github.com/itskenzylimon/Activity/blob/main/example/README.md) to run these examples and inspect live
results beside copyable source. The gallery uses the supplied Activity SVG and
its blue palette.

![Activity gallery with blue branding](https://raw.githubusercontent.com/itskenzylimon/Activity/main/example/gallery-overview.jpg)

![API code with live results](https://raw.githubusercontent.com/itskenzylimon/Activity/main/example/gallery-examples.jpg)

[Try the illustrated feature](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#values) ·
[Phone preview](https://github.com/itskenzylimon/Activity/blob/main/example/gallery-mobile.jpg) · [Run the gallery](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#run-it)

## Gallery recipes and integration templates

The [gallery guide](https://github.com/itskenzylimon/Activity/blob/main/example/README.md) maps every section to its compiled source.
Each example separates **API fragments**, **complete view code**,
**model/controller code**, and **application setup**. Local result terminals show
status, structured results, timing and copy controls. The docked developer
console is opt-in and disabled in release builds.

Start with the [form/search/pagination workbench](https://github.com/itskenzylimon/Activity/blob/main/example/lib/gallery/recipes/workbench.dart)
and its [controller](https://github.com/itskenzylimon/Activity/blob/main/example/lib/gallery/recipes/workbench_controller.dart):
validation preserves a draft, filtered/sorted results are derived, asynchronous
loads support retry, and generation tokens reject stale responses after newer
work or cancellation. This cancels result application; it does not cancel I/O.
The existing events, guarded routes, shell layout, localization and restoration
sections supply the related application patterns.

The [QuickeyDB recipe](https://github.com/itskenzylimon/Activity/blob/main/example/lib/gallery/recipes/database_page.dart) and
[complete model/DAO/controller](https://github.com/itskenzylimon/Activity/blob/main/example/lib/gallery/recipes/database_controller.dart)
use real SQLite with explicit conflict handling and atomic rollback. The app owns
the database and controller, views borrow them, failures retain drafts, and record
details return a typed `RecordResult`. Database operations drain before closure.
Its records are plaintext and session-only. QuickeyDB remains an **example-only**
local dependency; Activity's library dependencies and release version are unchanged.

Latest published Activity checked on **20 October 2026**: **1.5.3+5**;
QuickeyDB: **1.2.0+8**. This gallery requires the local Activity 2.0.0 and
QuickeyDB 3.0.0 checkouts. See [upgrade and platform notes](https://github.com/itskenzylimon/Activity/blob/main/doc/GALLERY_MIGRATION.md)
and the [public API coverage checklist](https://github.com/itskenzylimon/Activity/blob/main/doc/GALLERY_COVERAGE.md) before adapting
these examples to a published-version application.

## New to Activity?

A **controller** owns application logic. A **reactive value** wraps a Dart value
and notifies its controller when changed. A **view** listens and rebuilds; a
**selector** rebuilds only when its selected immutable value changes.

```text
Controller → registered values → change notifications → view / scope / selector
                       ↓
                router refresh → async guards → destination
```

1. Create final reactive fields and list them in `activities`. Base construction
   attaches them automatically; initialize them before the constructor body.
2. Keep one owner for the controller. Pass that instance to a view or an Activity
   scope; descendants read it with `Activity.getActivity<MyController>(context)`.
3. Update through `set`, call syntax or typed helpers. Values change immediately;
   notification delivery and widget rebuilds happen asynchronously.
4. Use `ActivitySelector` for small subtrees. Select immutable scalars/records,
   rather than mutating a selected list in place.
5. Own routers and localization delegates once. Dispose the controller/router
   when their application owner finishes; widgets cancel their own listeners.

Wrappers use identity equality; compare values explicitly with `.equals(...)` or
`.value`. Collection snapshots are shallow. Controller task bookkeeping keeps
busy state correct but does not cancel network requests or persist models.

## Standalone pub.dev example

[activity_example.dart](https://github.com/itskenzylimon/Activity/blob/main/example/activity_example.dart) is a complete counter app
using only Activity and Flutter. Copy it into an application's `lib/main.dart`;
use `activity: ^2.0.0` once this release is published. For local verification,
point the dependency at this checkout. It creates one controller, selects its
count and disposes the controller from its owner.

The full gallery remains a workspace application. Its QuickeyDB 3.0.0 path
dependency is **not** a dependency of the Activity library or standalone example;
clone both sibling repositories to run the database gallery recipe. The gallery's
workspace-only pubspec is excluded from the uploaded package. In an Activity-only
repository checkout, run `flutter pub get --no-example` for package checks.

## Run the example in Chrome

Run from the package's `example/` directory:

```sh
cd plugins/external/Activity/example
flutter pub get
flutter run -d chrome
```

The app uses the same public barrel as consumers. The Flutter
`flutter_localizations` SDK delegates localize built-in controls alongside
Activity translations. No translation generation or web setup script is needed.

## Setup and a complete example

Add a local dependency (adjust the path), then run `flutter pub get`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  activity:
    path: ../Activity
```

Use a separately verified published version when installing from pub.dev; a
checkout version alone does not establish release availability.

Place this in your application's `lib/main.dart`. The root owns one controller
and passes the same instance to the view. An `Activity` wrapper is optional when
the view already uses `ActiveState`.

```dart
import 'dart:async';

import 'package:activity/activity.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CounterApp());

class CounterController extends ActiveController {
  final count = ActiveInt(0, typeName: 'count');

  @override
  Iterable<ActiveType> get activities => [count];

  void increment() => count.set(count.value + 1);
}

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  final controller = CounterController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterPage(activeController: controller),
    );
  }

  @override
  void dispose() {
    unawaited(controller.resetActivities());
    super.dispose();
  }
}

class CounterPage extends ActiveView<CounterController> {
  const CounterPage({super.key, required super.activeController});

  @override
  ActiveState<CounterPage, CounterController> createActivity() =>
      _CounterPageState(activeController);
}

class _CounterPageState extends ActiveState<CounterPage, CounterController> {
  _CounterPageState(super.activeController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity counter')),
      body: Center(child: Text('${activeController.count.value}')),
      floatingActionButton: FloatingActionButton(
        onPressed: activeController.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

`createActivity()` is the view extension point; do not override `createState()`
as well. `ActiveViewLegacy<T>` also exists for older view hierarchies. Prefer
`ActiveView<T>` for new code.

## Sharing a controller with Activity

Use `Activity<T>` to expose an existing controller to descendants. The callback
`onActivityStateChanged` is optional; by default an internal revision counter
invalidates dependents for each notification. A custom callback must return a
different string for each notification.

This alternative root uses `CounterController` from the counter example:

```dart
class SharedCounterRoot extends StatefulWidget {
  const SharedCounterRoot({super.key});

  @override
  State<SharedCounterRoot> createState() => _SharedCounterRootState();
}

class _SharedCounterRootState extends State<SharedCounterRoot> {
  final controller = CounterController();
  int revision = 0;

  @override
  Widget build(BuildContext context) {
    return Activity<CounterController>(
      controller,
      onActivityStateChanged: () => '${++revision}',
      child: const MaterialApp(home: SharedCounterPage()),
    );
  }

  @override
  void dispose() {
    unawaited(controller.resetActivities());
    super.dispose();
  }
}

class SharedCounterPage extends StatelessWidget {
  const SharedCounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Activity.getActivity<CounterController>(context);
    return Scaffold(
      body: Center(child: Text('${controller.count.value}')),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

Read the scope from a descendant's `build` or `didChangeDependencies`, using the
same controller type as the wrapper. `getActivity` establishes an inherited
widget dependency. Scopes and views rebind their subscriptions when the controller changes under
the same widget key. One owner must dispose the old controller when it is unused.

## Reactive values and collections

| Value | API examples |
| --- | --- |
| General value | `ActiveType<T>(value)`, `createActiveType(value)` |
| Nullable value | `createActiveNullableType<T>()` |
| Boolean | `ActiveBool(false)`, `ActiveNullableBool()` |
| Integer | `ActiveInt(0)`, `ActiveNullableInt()` |
| Double | `ActiveDouble(0.0)`, `ActivityNullableDoubleProperty()` |
| String | `ActiveString('')`, `ActiveNullableString()` |
| Date/time | `ActiveDateTime(DateTime.now())` |
| Collection | `ActiveList<T>([])`, `ActiveMap<K, V>({})` |

For example, register these fields in a controller:

```dart
class ProfileController extends ActiveController {
  final name = ActiveString('Kenzy', typeName: 'name');
  final age = ActiveInt(20, typeName: 'age');
  final tags = ActiveList<String>([], typeName: 'tags');
  final scores = ActiveMap<String, int>({}, typeName: 'scores');

  @override
  Iterable<ActiveType> get activities => [name, age, tags, scores];

  void updateProfile() {
    name('Grace');                 // Callable shorthand for set().
    age.set(21);                  // set() returns the updated value.
    tags.add('flutter');          // Collection helpers notify listeners.
    scores.addEntry(const MapEntry('completed', 1));
  }
}
```

A changed scalar emits when `oldValue != newValue`. `notifyChange: false`
suppresses that notification. A standalone field must be attached to a controller
before an operation that notifies; otherwise it throws
`ActiveTypeNotAssignedException`.

Mutating `tags.value` or `scores.value` directly bypasses notifications. Prefer
wrapper methods or replace the entire value with a fresh collection. Collections
and model reset values are not deep snapshots; use immutable nested objects.
Wrappers use identity equality and stable identity hashes. Compare values with
`field.equals(other)` or `field.value == expected`. List/map snapshots are shallow.

## Batch updates and resets

Using the `ProfileController` above:

```dart
final profile = ProfileController();
profile.activateTypes([
  {profile.name: 'Grace'},
  {profile.age: 30},
]);

profile.name.set('Saved name', setAsOriginal: true);
profile.name('Unsaved name');
profile.name.reset(); // Restores 'Saved name'.
profile.resetAllActiveTypes(); // Resets all registered values in one batch.
```

Each batch entry must contain exactly one field/value pair. A batch validates all dynamic assignments before applying them and emits one
list of events. Prefer `activate` with typed `changeTo` assignments (below).
Custom subclasses overriding setters must validate their own invariants; these
APIs do not roll back arbitrary user-defined setter side effects.

`resetAllActiveTypes()` restores values. `dispose()` (also available as `resetActivities()`) permanently closes
the controller's streams; it is cleanup, not a way to reset a form for reuse.

## Async tasks and errors

`activeAsync` marks a named task as running, awaits the operation, and clears the
key in `finally`. It returns the task result and propagates exceptions.

```dart
class SearchController extends ActiveController {
  final results = ActiveList<String>([]);
  final message = ActiveString('');

  @override
  Iterable<ActiveType> get activities => [results, message];

  Future<void> search(Future<List<String>> Function() fetch) async {
    if (isTaskRunning(isRunningKey: 'search')) return;
    try {
      final items = await activeAsync(fetch, isRunningKey: 'search');
      if (isDisposed) return;
      results.set(List<String>.from(items));
      message('');
    } on Exception catch (error) {
      message('Search failed: $error');
    }
  }
}
```

An `ActiveState` can display
`ifRunning(const CircularProgressIndicator(), otherwise: content)` or inspect
`activeController.isTaskRunning(isRunningKey: 'search')`. Overlapping operations, including calls with the same key, are reference counted.
`activeTasks` is an unmodifiable snapshot of distinct keys. Disposing prevents new
work immediately. Pending tasks continue and preserve their result or original
exception; final busy notifications are skipped after disposal. Your async code
should check `isDisposed` after awaiting work before writing controller values.

`activeAsync` does not automatically emit `ErrorEvent`s. Controllers expose
`onActiveError` and `onActiveErrorListener` for explicit error reporting. Custom
listeners return subscriptions; release them with
`await controller.cancelSubscription(subscription)` when their owner finishes.

## Models

`ActiveModel<T>` extends `ActiveType<T>` and can appear in `activities`. It
supports the same typed updates, resets, selection, and automatic registration:

```dart
class Person {
  const Person(this.name);
  final String name;
}

class PersonController extends ActiveController {
  final person = ActiveModel<Person>(const Person('Kenzy'));

  @override
  Iterable<ActiveType> get activities => [person];

  void rename(String name) => person(Person(name));
}
```

Replace objects rather than mutating them in place so comparisons and resets
have meaningful values.

## Validation

`SchemaValidator` checks a map synchronously. Results contain `valid`, `data`
(a shallow copy of the input), `schema` (input with invalid or absent optional
fields removed), and `errors` (the first message for each failing field).

```dart
final validator = SchemaValidator({
  'email': {'type': String, 'required': true, 'email': true},
  'age': {'type': int, 'min': 18},
  'password': {'type': String, 'required': true, 'minLength': 8},
  'confirmation': {'required': true, 'equalsTo': 'password'},
}, customErrors: {
  'email.required': 'Enter your email address.',
  'age.min': 'You must be at least 18.',
});

final result = validator.validate({
  'email': 'itskenzylimon@gmail.com',
  'age': 28,
  'password': 'example-password',
  'confirmation': 'example-password',
});
if (result.valid) {
  // Use result.schema as input for your next application step.
} else {
  printError(result.errors.toString());
}
```

Additional rules include `notEmpty`, `requiredIf`, `requiredWhen`, `max`,
`maxLength`, `minItems`, `maxItems`, `pattern`, `in`, `date`, `before`, `after`,
`url`, `phone`, `uuid`, `ipv4`, and `ipv6`. Custom error precedence is
`field.rule`, then `field`, then `rule`, then the built-in message.

Custom rules return `String?`: return null or an empty string for success and an
error message for failure. Unknown keys are retained by default; pass
`allowUnknownKeys: false` to keep only declared, valid fields in `schema`.
The response maps are unmodifiable shallow copies. URLs require HTTP(S) and a
host. Dates require an ISO date prefix with a valid calendar day. IP checks are
syntactic checks; they do not establish address reachability.

```dart
final usernames = SchemaValidator({
  'username': {
    'type': String,
    'custom': (dynamic value, Map<String, dynamic> data) =>
        value == 'admin' ? 'Reserved username' : null,
  },
  'code': {'pattern': r'^ABC\d+$'},
}, allowUnknownKeys: false);
final checked = usernames.validate({'username': 'ada', 'code': 'ABC123', 'extra': 1});
// checked.schema contains username and code; extra is omitted.
```

## Environment configuration

`ENVSetup` loads strings and provides typed getters. For local configuration:

```dart
final env = ENVSetup();
env.merge({
  'API_URL': 'https://example.com',
  'RETRIES': '3',
  'ENABLED': 'true',
  'TIMEOUT': '30s',
});
final apiUrl = env.getUri('API_URL');
final retries = env.getInt('RETRIES');
final enabled = env.getBool('ENABLED');
final timeout = env.getDuration('TIMEOUT');
printInfo('$apiUrl; retries=$retries; enabled=$enabled; timeout=$timeout');
```

`await env.loadFile('/absolute/path/.env')` loads a native file.
`await env.loadAsset('assets/.env')` loads a declared Flutter asset after binding
initialization. Getters also support defaults, for example
`env.getInt('RETRIES', defaultValue: 3)`.

Values bundled with an app are readable by its users; keep production secrets
on a server. Native file access and process environment are isolated with conditional imports.
Web apps can use `loadAsset`, `loadString`, and `merge`; `loadFile` logs a warning
and does nothing on web. A URI getter accepts relative URIs; enforce a scheme and
host in application code when you need an absolute endpoint.

You can also parse text directly, which is convenient for existing configuration
services and tests. Parsing completes before merging, so malformed quoted input
leaves existing values intact:

```dart
final textEnv = ENVSetup();
textEnv.loadString('''
HOST="example.com" # inline comments may follow quotes
API_URL=https://\${HOST}/api
TIMEOUT=30s
''');
final endpoint = textEnv.getUri('API_URL');
final requestTimeout = textEnv.getDuration('TIMEOUT');
```

Expansion supports `${NAME}` and `${NAME:-default}`; unresolved references become
empty strings unless a default is supplied. Native process environment is a
secondary lookup source, while browsers only use supplied values. Cycles stop
expanding rather than recursing indefinitely. Single quotes preserve escape
characters; double quotes interpret common escapes. `expand: false` leaves
references intact. Default getters apply to missing keys; invalid present values
still throw `FormatException`.

## Other utilities

- **Strings:** exported extensions include `capitalize()`, `title()`,
  `toCamelCase()`, `containsAll(...)`, and `containsAny(...)`.
- **Logging:** `printInfo`, `printWarning`, `printError`, and `printSuccess` use
  the configurable `Logger.instance`. Release logging defaults to off. Set
  `Logger.instance.printInRelease = true` to opt in.
- **Localization:** `ActiveLocalization.delegate` loads
  `assets/language/<languageCode>.json`. Register the delegate and supported locales
  in your app and declare those asset files. `getTranslated(context, key)` can
  return null for missing keys. The default supported language codes are `en`
  and `sw`; Flutter's Material localization delegates are configured separately.
- **Navigation:** `Nav.to`, `pushNamed`, and `off` wrap Flutter navigation.
  `offAll` clears the whole stack; `replace` replaces the top route.
  `pushUntil` accepts a real Flutter `RoutePredicate`. Results are typed.
- **Event bus:** `Deamon` is exported by `activity.dart`; its direct import also
  remains supported.

```dart
import 'package:activity/core/events/deamon.dart';

Future<void> eventExample() async {
  final bus = Deamon();
  final nextMessage = bus.next<String>(); // Subscribe before emitting.
  bus.emit('Ready');
  final message = await nextMessage;
  printInfo(message);
  await bus.close();
}
```

`on<T>()` filters events by type; `emitSticky<T>()` caches a value for
`onSticky<T>()`. Every subscriber gets the latest cached value at subscription time, then live
events in order. Sticky cache lookup uses the exact generic type passed to
`emitSticky<T>`; live filtering includes subtypes. Use `emitSticky<Base>(child)`
if base-type subscribers should receive cached children. Each bus is local to
its Dart isolate; communicate between isolates explicitly. Injected controllers
must be broadcast and are owned/closed by the bus. Cancel subscriptions when
their consumers finish; `close` clears the cache and closes the source.

## Typed updates and helper reference

Import `package:activity/activity.dart` for every API below. Fields that notify
must belong to a live controller. To experiment with standalone values, call
`set(..., notifyChange: false)` or explicitly register them with `controller.register`.
Registration attaches a late-created field; include it in `activities` too if it
should participate in `resetAllActiveTypes`.

```dart
final profile = ProfileController();
profile.activate([
  profile.name.changeTo('Grace'), // Requires String at compile time.
  profile.age.changeTo(30),      // Requires int at compile time.
]);
profile.age.updateValue((age) => age + 2);
profile.name.setIfChanged('Grace'); // Returns false and emits nothing.
final label = profile.age.select((age) => 'Age: $age');
profile.tags.replaceAll(['flutter', 'dart']);
profile.tags.addIfAbsent('dart'); // false, no duplicate.
profile.tags.sort();
final grouped = profile.tags.groupBy((tag) => tag.length);
final first = profile.tags.firstOrNull;
final page = profile.tags.paginate(pageNumber: 20, pageSize: 10); // []
profile.scores.putIfAbsent('completed', () => 0);
profile.scores.setEntry('completed', 2);
final frozenScores = profile.scores.snapshotValue;
```

`updateValue` gives collection transforms a shallow copy, then emits one event
when committing the returned collection. Throwing inside the transform leaves
the original collection unchanged unless the callback mutates shared nested
objects. `setAsOriginal`, `setToOriginal`, and `setOriginalValueToCurrent()` copy
list/map originals. Every reset copies again. Override `snapshot` for a custom
copy policy; immutable models usually need no override.

| Type | Read helpers | Mutating helpers |
| --- | --- | --- |
| Any `ActiveType<T>` | `value`, `originalValue`, `equals`, `select`, `isNull` | `set`, call syntax, `updateValue`, `setIfChanged`, `reset`, `changeTo` |
| `ActiveBool` | `isTrue`, `isFalse` | `setTrue`, `setFalse`, `toggle` |
| Numeric types | `isPositive`, `isNegative`, `isZero`, `isBetween`, `asInt`, `asDouble` | `clampTo`, integer/decimal increment and decrement |
| `ActiveInt` / `ActiveDouble` | `add`, `subtract`, `multiply`, `divide`, `mod` calculate without mutation | `set`, `updateValue` |
| `ActiveType<String>` | `isBlank`, `tryInt`, `tryDouble` | `trimValue`, `append`, `prepend`, `replaceText` |
| Nullable values | `valueOr` | `setIfNull` lazily initializes only missing values |
| Lists | `firstOrNull`, `lastOrNull`, `where`, `firstWhereOrNull`, `any`, `every`, `fold`, `groupBy`, `paginate`, `snapshotValue` | `add`, `addAll`, `insert`, `insertAll`, `insertAllAtEnd`, `remove`, `removeAt`, `clear`, `replaceAt`, `replaceAll`, `sort`, `retainWhere`, `removeWhere`, `addIfAbsent` |
| Maps | `containsKey`, `containsValue`, `entries`, `keys`, `values`, `valueOr`, `mapEntries`, `snapshotValue` | `addAll`, `addEntry`, `addEntries`, `update`, `updateAll`, `remove`, `removeWhere`, `clear`, `putIfAbsent`, `setEntry` |
| Date/time | `startOfDay`, `isSameDay` | `addDuration`, `subtractDuration` |

Existing `ActiveInt.increment` and `decrement` increment by one and accept the
`notifyChange` flag. To add an arbitrary amount use `updateValue((n) => n + 5)`.
`startOfDay` preserves local/UTC construction; `isSameDay` compares calendar
components as represented, without converting time zones. Duration arithmetic
uses elapsed time and can cross local daylight saving boundaries.

A collection's `.value` remains mutable for compatibility. Direct mutation bypasses
notifications and disposal guards. Use `snapshotValue` for a read-only shallow
snapshot. Events for insertion/removal contain the affected elements; replacement
and reset events contain old/new collection snapshots. All snapshots remain
shallow: nested models need immutable fields or application-specific copies.

## Selective rebuilding

Use a selector for a small subtree. The selector runs on controller notifications;
its builder runs when the selection changes under `==`. Selecting a Dart record
is useful when a widget depends on several scalar fields:

```dart
ActivitySelector<ProfileController, (String, int)>(
  controller: profile,
  select: (controller) => (controller.name.value, controller.age.value),
  child: const Icon(Icons.person),
  builder: (context, selected, child) => Row(children: [
    child!,
    Text('${selected.$1}, ${selected.$2}'),
  ]),
);
```

Keep selectors free of side effects. Select immutable values or records of
scalars. A mutable collection selected by reference will compare equal to itself
after in-place changes. `ActivitySelector` rebinds on controller replacement and
cancels its listener on disposal. Its optional child can remain independent of
selected state.

## Localization integration

Create one application-owned delegate. No global language list needs editing.
Add it alongside your existing delegates and pass its locale list to your app:

```dart
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final translations = ActiveLocalizationDelegate(
  supportedLocales: const [Locale('en'), Locale('sw')],
  fallbackLocale: const Locale('en'),
  assetPath: 'assets/i18n',
);

MaterialApp(
  supportedLocales: translations.supportedLocales,
  localizationsDelegates: [
    translations,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: const Scaffold(body: Text('Home')),
);
```

For a runnable
example with Flutter SDK localization delegates, see
`example/lib/gallery/app.dart` and `example/assets/i18n/`.
For Flutter's built-in controls in languages other than English, add Flutter's
`flutter_localizations` SDK dependency and its global delegates. Activity does
not replace Material/Widgets/Cupertino translations.

Declare the Flutter SDK localization dependency and translation directory in the
consuming app's `pubspec.yaml`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter

flutter:
  assets:
    - assets/i18n/
```

`assets/i18n/en.json`:

```json
{"welcome": "Hello {name}", "save": "Save"}
```

`assets/i18n/sw.json`:

```json
{"welcome": "Habari {name}"}
```

```dart
Text(context.tr('welcome', parameters: {'name': 'Kenzy'}));
Text(context.tr('save')); // Uses English fallback if the active locale is sw.
Text(context.tr('unknown', fallback: 'Default text'));
```

Files use BCP 47 locale tags: `en.json`, `en-GB.json`, `zh-Hant.json`, etc.
The delegate uses exact supported locale matching; Flutter resolves the requested
locale against the list. Configure `fallbackLocale` explicitly for missing keys
and missing primary assets. Malformed JSON, non-string translation values, and
missing fallback assets remain visible errors. The fallback is loaded before the
primary locale. Unresolved keys return the key (or the supplied fallback).
Interpolation replaces `{name}` once; inserted text is never recursively expanded.
ICU cardinal plural and select syntax is described below.

To integrate an existing translation repository or generated map, supply a loader:

```dart
final embeddedTranslations = ActiveLocalizationDelegate(
  supportedLocales: const [Locale('en')],
  loader: (locale) async => {'welcome': 'Hello {name}'},
);
```

The loader receives the full `Locale`; its errors propagate. It should implement
its own missing-resource policy. An injected `AssetBundle` supports existing asset
systems and isolated tests. `ActiveLocalization.delegate` and `getTranslated`
remain available for legacy language-code assets; new code should use the
configurable delegate and `context.tr`.

## ICU pluralization and select messages

Translation values can be ICU MessageFormat 1 patterns. Pass numbers as numbers;
Activity selects locale cardinal categories through `intl`, then formats `#` in
that locale. Exact `=number` branches take precedence over language categories.

`assets/i18n/en.json`:

```json
{
  "tasks": "{count, plural, =0{No tasks} one{# task} other{# tasks}}",
  "guests": "{count, plural, offset:1 =0{Nobody} =1{Just you} one{You and # guest} other{You and # guests}}",
  "owner": "{gender, select, female{Her tasks} male{His tasks} other{Their tasks}}",
  "summary": "{gender, select, female{{count, plural, one{She has # task} other{She has # tasks}}} other{{count, plural, one{They have # task} other{They have # tasks}}}}"
}
```

```dart
Text(context.tr('tasks', parameters: {'count': 3})); // 3 tasks
Text(context.tr('guests', parameters: {'count': 3})); // You and 2 guests
Text(context.tr('owner', parameters: {'gender': 'female'})); // Her tasks
Text(context.tr('summary', parameters: {'gender': 'female', 'count': 2}));
```

| Pattern | Contract |
| --- | --- |
| `{name}` | String interpolation; a missing simple argument remains `{name}` |
| `{count, plural, ...}` | Requires a finite num and an `other` branch |
| `zero`, `one`, `two`, `few`, `many`, `other` | Locale categories, not fixed numeric comparisons |
| `=0`, `=1`, `=1.5` | Exact numeric matches before applying an offset |
| `offset:1` | Subtracts one for category selection and `#`, not for exact matches |
| `{gender, select, ...}` | Matches a string value; unknown values use the required `other` branch |
| Nested plural/select | Inner plurals own their `#`; surrounding `#` retains the outer value |
| Apostrophe quoting | `'{'` prints a brace; `'#'` prints a literal pound inside a plural; `''` prints an apostrophe |

For example, French 0 uses the `one` category, Russian 2 uses `few`, and Arabic
0/2 use `zero`/`two`. An English message's `zero{...}` is not an exact zero test;
use `=0{...}` for that behavior. Numeric inputs do not preserve source precision
such as the difference between textual `1` and `1.00`.

Parameters are inserted as literal text and are never parsed as another message.
Ordinary apostrophes in words such as `Don't` remain literal. A malformed pattern,
duplicate branch, missing `other` or unsupported format raises FormatException.
Missing/non-numeric complex arguments raise ArgumentError. Patterns are parsed
once per localization instance/template and then reused. Nesting is bounded to
64 levels. A fallback translation uses the fallback language's plural rules.

For formatter use outside a widget:

```dart
final message = IcuMessage('{count, plural, one{# file} other{# files}}');
final text = message.format(locale: 'en', parameters: {'count': 2}); // 2 files
```

The supported scope is MessageFormat 1 placeholders, **cardinal** plurals and
select. `selectordinal`, date/time/number skeleton arguments, rich text and
MessageFormat 2 are explicitly unsupported; format those values with an
application formatter before interpolating them. There is no generated ARB code
or build_runner step.

## Nested routes and named navigation

`ActivityRouter` owns a Flutter `RouterDelegate` and `RouteInformationParser`.
Use Activity route types throughout the tree. Its native Flutter APIs are exposed
as `routerDelegate`, `routeInformationParser`, `routeInformationProvider` and
`config`; `context.activityRouter` and `context.activityRoute` provide scoped access.

```dart
final router = ActivityRouter(
  initialLocation: '/teams/7',
  routes: [
    ActivityRoute(
      path: '/teams/:team', name: 'team',
      builder: (_, state) => Scaffold(body: Text('Team ${state.pathParameters['team']}')),
      routes: [
        ActivityRoute(
          path: 'members/:member', name: 'member',
          builder: (_, state) => Scaffold(
            appBar: AppBar(title: const Text('Member')),
            body: Text('Team ${state.pathParameters['team']}, '
                'member ${state.pathParameters['member']}'),
          ),
        ),
      ],
    ),
  ],
);

MaterialApp.router(routerConfig: router.config);
router.goNamed('member', pathParameters: {'team': '7', 'member': '9'},
    queryParameters: {'tab': 'posts'});
```

Top-level paths start with `/`; child paths are relative. A direct link to
`/teams/7/members/9` builds both pages, so Back reveals team 7. Child builders
receive inherited path parameters. Register static paths before overlapping
parameter paths. Route names must be globally unique.

| Action | Behavior |
| --- | --- |
| `go(location)` / `goNamed(name, ...)` | Replaces the matched hierarchy for the destination |
| `push<T>(location)` / `pushNamed<T>(name, ...)` | Adds a page and returns a `Future<T?>` completed when it is popped |
| `replace<T>(location)` | Replaces the top page and completes its previous result with null |
| `pop<T>(result)` | Returns false at the root, otherwise requests a pop and supplies the result |
| `canPop` | Checks the active declarative page stack (dialogs remain Flutter routes) |
| `namedLocation(...)` | Encodes full nested paths, repeated query values and optional fragments |
| `ActivityRouter.of(context)` | Retrieves the Activity owner from a route widget |
| `ActivityRouteState.of(context)` | Reads the current route's parameters, query, extra and page key |
| `router.routerDelegate` / `routeInformationParser` | Exposes Flutter Router integration without an external routing package |

```dart
final selected = await router.pushNamed<int>('member',
    pathParameters: {'team': '7', 'member': '9'});
// Inside that page: ActivityRouter.of(context).pop<int>(42);
```

`ActivityRouteState` exposes `uri`, `pathParameters`, `queryParameters`,
`queryParametersAll`, `name`, `fullPath`, `extra`, `pageKey`, and `error`.
Use `pageBuilder` for custom transitions or Cupertino pages. When supplying a
custom page, provide a stable `restorationId` if that page needs restoration.
Unknown routes and guard errors reach `errorBuilder`; guard errors are reported
asynchronously through the mounted Router.

## Shell layouts and independent tabs

A shell keeps shared UI outside its nested Navigator:

```dart
final rootKey = GlobalKey<NavigatorState>();
final shellRouter = ActivityRouter(navigatorKey: rootKey, initialLocation: '/items', routes: [
  ActivityShellRoute(
    restorationScopeId: 'items_shell',
    builder: (_, state, child) => Scaffold(
      appBar: AppBar(title: const Text('Workspace')),
      body: child,
    ),
    routes: [
      ActivityRoute(path: '/items', builder: (_, state) => const Text('Items'), routes: [
        ActivityRoute(
          path: 'preview', parentNavigatorKey: rootKey,
          builder: (_, state) => const Scaffold(body: Text('Full-screen preview')),
        ),
      ]),
    ],
  ),
]);
```

The preview targets the root Navigator, above the shared shell. Without
`parentNavigatorKey`, it stays inside the shell. Nested shells can each own their
own Navigator key and layout.

Use an indexed stateful shell when tabs need independent navigation histories:

```dart
final tabs = ActivityRouter(initialLocation: '/feed', restorationScopeId: 'router', routes: [
  ActivityStatefulShellRoute.indexedStack(
    restorationScopeId: 'main_tabs',
    branches: [
      ActivityShellBranch(restorationScopeId: 'feed_branch', routes: [
        ActivityRoute(path: '/feed', builder: (_, state) => const Text('Feed'), routes: [
          ActivityRoute(path: 'detail/:id', builder: (_, state) => Text('Post ${state.pathParameters['id']}')),
        ]),
      ]),
      ActivityShellBranch(restorationScopeId: 'settings_branch', routes: [
        ActivityRoute(path: '/settings', builder: (_, state) => const Text('Settings')),
      ]),
    ],
    builder: (_, state, shell) => Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) => shell.goBranch(index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Feed'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    ),
  ),
]);
```

The builder receives an `ActivityNavigationShell`: put it in the widget tree and
use `currentIndex`/`goBranch`. Returning to a tab restores its last route; pass
`initialLocation: true` to reset that tab to its initial location. Widget state
in other tabs stays mounted in the IndexedStack. Each visited branch retains its
page stack and pending result futures. Restored routes run guards again; a future
awaited before process death cannot survive into the restarted process.

## State restoration and browser URLs

Enable restoration at the application, router, shell and branch levels:

```dart
MaterialApp.router(
  restorationScopeId: 'my_app',
  routerConfig: tabs.config, // The tabs configuration above already has scope IDs.
);
```

| State | How it survives |
| --- | --- |
| Nested destination and selected tab | Router serializes the complete match configuration |
| Visited tab histories | Activity registers a restorable history for each branch |
| Form fields, scroll offsets and other widget state | Use Flutter `RestorationMixin` and `RestorableProperty` APIs with stable IDs |
| JSON-compatible `extra` | Encoded by the navigation engine |
| Custom objects in `extra` | Supply a matching `extraCodec: Codec<Object?, Object?>` to `ActivityRouter` |
| Controller values and network data | Application persistence/reloading; routing does not persist controllers |

Keep scope IDs unique and stable between launches, and own each router outside
`build`. Activity shell wrappers supply stable restorable MaterialPages. Custom page builders need stable page keys and restoration IDs. Use
`MaterialPage`, `ActivityTransitionPage` or `ActivityNoTransitionPage`; these
page types participate in route-state scoping and asynchronous exit guards.

URL path/query values remain the portable source for reloadable destinations.
A platform deep link takes precedence over `initialLocation`; set
`overridePlatformDefaultLocation: true` when explicitly overriding it is intended.
Browser Back/Forward goes through the normal parser and guards. When using path
URL strategy, configure the host to serve the app for deep-link paths. Browser
reload and OS state restoration have different lifecycles; ordinary controller
fields do not automatically survive either.

Regression tests restart with a **new router instance**, restore the active tab,
return to an inactive tab's nested route, and verify RestorableInt values. This
is stronger than retaining the same router instance across a widget rebuild.

## Async guards and Activity integration

Top-level, page and shell redirects accept `FutureOr<String?>`. Return null to
allow a destination or a location to redirect. Async work completes before the
protected page builder runs; the current page remains visible while a navigation
guard is pending.

```dart
class SessionController extends ActiveController {
  final signedIn = ActiveBool(false);
  @override
  Iterable<ActiveType> get activities => [signedIn];
  Future<bool> hasSession() async => signedIn.value; // Replace with your session service.
}

final session = SessionController();
final guarded = ActivityRouter(
  refreshController: session,
  routes: [
    ActivityRoute(path: '/', builder: (_, state) => const Scaffold(body: Text('Home'))),
    ActivityRoute(path: '/login', builder: (_, state) => const Scaffold(body: Text('Sign in'))),
    ActivityRoute(
      path: '/account',
      redirect: (state) async => await session.hasSession() ? null : '/login',
      builder: (_, state) => const Scaffold(body: Text('Account')),
    ),
  ],
  errorBuilder: (_, state) => Scaffold(body: Text('Navigation failed: ${state.error}')),
);

Activity(session, child: MaterialApp.router(routerConfig: guarded.config));
```

Controller notifications trigger re-evaluation, including after sign-out. A newer
navigation supersedes a pending parse, so an old guard cannot later send the user
to its destination. Redirect cycles and excessive redirects reach the error
builder. The guard adapter forwards async exceptions to that error page rather
than leaving an unresolved parse across the engine's error-zone boundary.

Use `ActivityRoute.onExit` for asynchronous leave confirmation:

```dart
ActivityRoute(
  path: '/edit',
  builder: (_, state) => const Scaffold(body: Text('Editor')),
  onExit: (context, state) async {
    final leave = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Discard changes?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Stay')),
        TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Leave')),
      ],
    ));
    return leave ?? false;
  },
);
```

A veto can prevent completion of a requested pop, so `pop` returning true means a
pop was requested, not that an exit guard has already approved it. Keep guard
side effects idempotent: redirects may run again on refresh or restoration.
Dispose the router from its owner; it only cancels its own controller listener.

## Imperative navigation

`Nav` stays available for ordinary Navigator apps, dialogs and typed page results:

```dart
final answer = await Nav.to<int>(context,
    () => const Scaffold(body: Text('Choose an answer')));
if (!context.mounted) return;
// From that page: Nav.off<int>(context, 42);
Nav.pushUntil<void>(context, () => const Scaffold(body: Text('Dashboard')),
    ModalRoute.withName('/home'));
Nav.offAll<void>(context, () => const Scaffold(body: Text('Login')));
```

`offAll` clears the whole stack; `replace` replaces the top. `getArguments` is
nullable outside a modal route; `argumentsOf<T>` casts the supplied arguments.
Named imperative routes still need Flutter's routes/onGenerateRoute configuration.
Use router APIs for URL-driven screens rather than mixing independently managed
stacks without an explicit navigation policy.

## Migrating from 1.x

Version 2.0 intentionally changes the following contracts:

- Legacy `ActiveMemory`, `Memory`, HTTP request and WebSocket exports from 1.x
  are no longer included. Migrate persistent data and keys before upgrading; use
  dedicated storage/network packages. The gallery's QuickeyDB integration is an
  optional application recipe, not a drop-in replacement for the old storage API.

- `field == other` uses wrapper identity. Use `.equals(...)` for value comparison.
  Hashes remain stable after updates, allowing wrappers as batch/map keys.
- `Nav.pushUntil` takes a `RoutePredicate`, such as `ModalRoute.withName('/home')`.
  The old widget predicate never correctly matched routes.
- `Nav.offAll` clears the entire stack. Use `Nav.replace` for the old top-only behavior.
- `ActiveState.resetActivities()` restores values. Dispose the controller explicitly
  from its owner; Flutter owns disposal of mounted State objects.
- `ActiveModel` now extends `ActiveType`; register it with other fields.
- Injected Deamon controllers must be broadcast. Sticky replay is per subscriber
  with an exact generic cache key. The bus owns injected controllers.
- Logger release output defaults to disabled; opt in explicitly when required.
- Strict URL/date validation can reject previously accepted relative URLs and
  overflowing calendar dates. Custom rule callbacks may return null for success.

Additional changes from the first 2.0 development checkout:

- ActivityRouter now owns its Flutter delegate/parser instead of itself being a RouterDelegate<Uri>.
  Use `MaterialApp.router(routerConfig: router.config)` and
  `ActivityRouter.of(context)`; do not cast Router.of(context).routerDelegate.
- Redirects settle asynchronously. Observe navigation/errorBuilder after the
  Router processes a location, rather than expecting go() to throw guard errors.
- push and replace return typed result futures. Constructors for ActivityRoute
  are not const because route trees are validated and copied.
- Stateful shell builders receive ActivityNavigationShell. Its goBranch retains
  and restores Activity's per-branch history. Use ActivityShellBranch for branches.
- ICU braces are syntax. Quote literal syntax characters in translation patterns;
  simple interpolation and missing-key fallbacks remain supported.
- intl is the runtime dependency; the former external routing dependency and its native exports have been removed. Replace raw GoRoute/ShellRoute types with ActivityRoute/ActivityShellRoute, and context.go/push with context.activityRouter.go/push.

The SDK language baseline remains Dart 3.7.2. Dart records, typed callbacks,
immutable snapshots, and explicit resource ownership address the observed issues
without forcing consumers onto newer language syntax. See the official
[Dart language evolution](https://dart.dev/resources/language/evolution) and
[Flutter Router API](https://api.flutter.dev/flutter/widgets/Router-class.html)
for version and navigation contracts.

## Lifecycle and troubleshooting

| Symptom | Check |
| --- | --- |
| Field update throws an assignment exception | Return that exact field instance from `activities`. |
| View does not rebuild | Update through the wrapper; check registration and notification flags. |
| Scoped consumer stays stale | Use the matching generic controller type; omit the optional revision callback. |
| Two views show different data | Pass the same controller instance; do not create controllers inside `build`. |
| Reset does not restore nested data | Use immutable values; originals are references or shallow collection copies. |
| Controller throws after cleanup | `resetActivities()` closes it permanently; create a new controller. |

Have one owner dispose a controller. Views and scopes subscribe synchronously,
cancel their own subscriptions, and never dispose a shared controller.
`ActiveState.resetActivities()` now restores values and leaves the mounted state
usable. `ActiveController.resetActivities()` is the legacy terminal cleanup alias.
`dispose()` is idempotent and marks the controller disposed before awaiting any
cleanup. Mutating attached values after disposal throws before mutation.

The example compiles for web; regression tests run on the Flutter host VM and Chrome.
See Observations for exact validation results; desktop/mobile device coverage is
separate from compilation and unit tests.

## Example, testing, and contribution

Run from the package directory:

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter test --platform chrome test/events test/helpers test/navigation test/localization test/state/regressions_test.dart
```

See [Observations.md](https://github.com/itskenzylimon/Activity/blob/main/Observations.md) for the review baseline, test results,
priorities, and Dart modernization plan. New Dart syntax must respect the minimum
SDK declared in `pubspec.yaml`; upgrading your installed SDK alone does not raise
the package language version.

Report bugs or propose features in the
[Activity issue tracker](https://github.com/itskenzylimon/Activity/issues).
Contributions should include relevant regression tests and updated API docs.
See the [Code of Conduct](https://github.com/itskenzylimon/Activity/blob/main/CODE_OF_CONDUCT.md) and [Apache 2.0 license](https://github.com/itskenzylimon/Activity/blob/main/LICENSE).

## Support, gifts and community

Help fund and sustain open-source work.
[GitHub community](https://github.com/itskenzylimon) ·
[Report an issue](https://github.com/itskenzylimon/Activity/issues) ·
[Blog & Articles](https://medium.com/@itskenzylimon) ·
[Activity on pub.dev](https://pub.dev/packages/activity).
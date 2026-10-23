# Native routing update — 23 October 2026

ActivityRouter now implements routing with Flutter Router, Navigator and PopScope.
The earlier external-engine implementation and export/dependency notes below are
historical and superseded. ActivityShellBranch and transition pages are package-
owned APIs; delegate, parser and route-information provider are publicly exposed.
See [routing](doc/ROUTING.md) and [feature recipes](doc/FEATURE_RECIPES.md).

Verification: 286 package tests, 27 routing contracts in Chrome, 58 exact-source
examples on VM/Chrome, and 15 gallery tests on both host and Chrome passed.
Package/gallery analysis and the production web build pass. Dartdoc 9.0.11 emits
zero warnings/errors across 27 libraries. Browser Back/Forward, nested reload,
custom transitions and a 390px mobile layout were inspected; no browser warnings
or errors were captured. Overview/API/mobile screenshots are refreshed. Native
builds, minimum-SDK execution and hosted CI remain separate release checks.

The router retains page/widget identity across parameter/query/extra updates,
rechecks the newest pending destination on controller refresh, preserves typed
results across tab switches, and handles pageless dialog/local drawer back before
page removal. New tests also cover custom-page restoration keys and disposal
while an async push guard is still pending. Snapshot URIs/extras are serialized;
ordinary controller models and pending process-local futures are not persisted.

Recursive Git/pub exclusions cover nested caches/builds/coverage, local database
files/sidecars, private environment/key configuration and temporary fixtures.
Already tracked platform output remains tracked for maintainer review; intentional
logos/screenshots/worker-WASM assets and source examples remain included.


---

# API documentation and branding — 23 October 2026

- Added 57 complete, marked Dartdoc programs across 28 feature areas: two
  examples per area and three for ICU. Imports, controller registration and
  owner cleanup are explicit. All 28 gallery-comment links land at README
  walkthrough anchors. Older nullable-constructor examples use named values.
- Added `tool/check_doc_examples.dart` to extract and run the exact comment
  blocks, rather than maintaining separate copies. It validates widget startup
  and cleanup as well as non-UI assertions; feature interaction tests remain
  separate. Temporary sources under test/.api_snippets are removed afterward.
- Applied the supplied vector logo to the package README, gallery sidebar/hero,
  web favicon and manifest. The example uses flutter_svg; the Activity library
  has no new runtime dependency. The SVG's sky/blue/deep-blue colors drive the
  default appearance and terminal accents, with five related accent choices.
- README and example guidance now connect feature comments, browser routes,
  full source and screenshots. See [snippet guide](doc/API_SNIPPETS.md).

Verification: package analysis has no issues; 273 package tests, 15 host gallery
and 15 Chrome gallery tests passed. All 57 marked documentation examples passed
on the host and in Chrome. The release JavaScript web build passed. Desktop and
phone screenshots were refreshed after visual inspection. Native builds, hosted
CI and standalone third-party browser runners were not verified in this update.
Version and library SDK requirements remain unchanged.

---

# Gallery follow-up — 20 October 2026

This section supersedes the gallery validation limitations in the 19 October
status below. Existing package changes, the 2.0.0 release version and legacy
example references were preserved. QuickeyDB was inspected as the reference and
local companion dependency; this implementation changes Activity.

## Implemented and verified

- 19 searchable sections retain the grouped Material gallery/sidebar/drawer,
  Activity routing/state, stable hash URLs, appearance preferences and feature
  badges. User-facing Material-version labels were removed.
- Added contextual form/validation/derived search/sort/pagination, retry and
  stale-result/cancellation examples, plus all nullable wrapper families.
- Added app-owned real QuickeyDB SQLite CRUD, explicit abort conflicts,
  transaction rollback, draft retention, queued work draining and typed record
  detail results. Storage is intentionally plaintext and session-only.
- Every demo has API, full view, model/controller and app setup tabs. The latter
  load the actual compiled files including main.dart. Live previews/results remain
  below source rather than being discarded when tabs change. Dedicated recipe
  terminals include structured output, status, timing and copy controls.
- The bottom console has category tabs, timestamps, bounded history (80), copy,
  clear and a fixed mobile close control. Diagnostics are opt-in and hard-disabled
  in release; state payloads, URI parameters/queries and exception bodies are not
  captured. Runtime operation timing remains explicit in local terminals.
- Root ownership, isolated event cleanup and nested settings navigation remain
  visible in the actual source. Unknown routes now offer overview recovery.
- Live browser testing found typed pushes did not update the address bar under
  the engine default. Gallery main.dart now explicitly enables the exported
  GoRouter URL-reflection option; the library default is unchanged. Real browser
  Back/Forward, typed pop results and direct section links were verified.
- Fixed the previously unresolved Chrome gallery tests: Flutter's test server
  serves test/, not the application asset bundle, and does not resolve this engine
  asset channel. The test-only adapter fetches exact staged JSON/source assets;
  it does not replace translations or application behavior. Condition-based waits
  cover source/ENV/locale assets. SQLite uses the matching staged worker/WASM pair.
- Added fundraiser/community links and disabled configurable gift/coffee/social
  slots; no payment accounts were invented. README, example guide, changelog,
  API coverage checklist and integration/migration notes reflect the final code.

## Validation performed

On the installed macOS arm64 Flutter SDK / Dart 3.13.5:

| Check | Result |
| --- | --- |
| Package analysis including resolved example | No issues |
| Package host regression suite | 273 passed |
| Expanded example host suite | 15 passed |
| Expanded example Chrome suite | 15 passed |
| Release JavaScript web build, renderer resources bundled | Passed |
| git diff whitespace validation | Passed |
| Live release app at 1440×1000 and 390×844 | Inspected; responsive layout and mobile console close verified |
| Actual browser interactions | Direct section URLs, typed detail URLs/results, Back/Forward, SQLite save/update/rollback, output copy, complete bootstrap copy, French/Arabic/RTL and fallback verified |
| Captured browser warnings/errors | None during the release inspection |

Updated screenshots: [desktop](example/gallery-overview.jpg),
[phone](example/gallery-mobile.jpg). The older preview is retained as preexisting
work. The web build includes the adaptive Cupertino icon font and emits normal
font tree-shaking information, without the earlier missing-font warning.

## Compatibility and remaining limits

Pub.dev metadata verified on 20 October lists Activity **1.5.3+5** and QuickeyDB
**1.2.0+8**. Activity 2.0.0 and QuickeyDB 3.0.0 here remain unpublished workspace
versions. Only the example uses the adjacent QuickeyDB dependency and its Dart
3.9 / Flutter 3.35 minimum. Activity library requirements remain unchanged.

Native Android/iOS/macOS/Windows/Linux builds, process restoration, a minimum-SDK
rerun, hosted CI and executed Wasm output were not verified in this update.
No iOS runtime was downloaded. Package-only CI remains independent of the local
integration; the manual gallery workflow requires a reviewed remote QuickeyDB
3.0 ref once available. No release, publication or version change was performed.
See [coverage and unsupported behavior](doc/GALLERY_COVERAGE.md) and
[integration conflicts/migration](doc/GALLERY_MIGRATION.md).

---

# Implementation status — 19 October 2026

The original review is retained below as historical context. Its descriptions of
broken current behavior and failing tests are superseded by this status section.
The package is now prepared as **2.0.0**, retaining Dart **^3.7.2** and declaring
Flutter **>=3.29.0**. Breaking equality/navigation contracts are documented in the
README migration section. No release has been published.

## Material feature gallery

The example is now a Material 3 gallery inspired by the Fluent UI Flutter
showcase's grouped navigation and preview/source organization. It includes 17
searchable sections, responsive desktop/sidebar and phone/drawer navigation,
copyable source, a bounded live console, theme/accent settings and English,
Kiswahili, French and Arabic asset catalogs. Demos cover reactive values,
collections, immutable models, typed batches, selector rebuild counts, concurrent
work, event replay, nested routing, async/exit guards, restoration, ICU editing,
validation, ENV assets, strings/dates/UUIDs and controller lifecycle. A dedicated
to-do checklist and practical do/don't guidance complement each feature.

Gallery integration testing exposed lost pending typed push results when live
branches were deserialized during switches. The router now retains live scoped
match lists and their completers, while serializing restored branches as before;
root overlays remain excluded and redirect checks still run.

Validation on the local SDK:

- Package and example analysis: **no issues**.
- Package host regressions: **273 passed**, including **15 routing tests**.
- Package Chrome regression selection: **105 passed** after the live-history fix.
- Example host widget tests: **8 passed**; all 17 destinations render at desktop
  and phone widths. Tests also cover CRUD, event replay, validation, ENV assets,
  typed results across branch switches, guard/exit flows, ICU locale switching,
  preferences/widget restoration, overlapping work, disposal and mobile search.
- Release web compilation with bundled web resources: **passed**. The built app
  was inspected in the browser, including live counter updates, dark appearance
  and source panels. Preview and source structure are documented in example/README.md.
- The gallery's Chrome widget suite is **not passing**: initial asset-backed
  localization did not finish in that harness. This is recorded separately from
  host results and release-browser checks; it remains follow-up validation work.

## Routing and ICU follow-up completed

The requested nested/shell routing, restoration, async guards and ICU cardinal
pluralization are now implemented. ActivityRouter owns the official go_router
engine, accepts native route entries, and exports native route/page/context APIs.
Activity wrappers add automatic controller refresh, a guard error-zone bridge and
per-branch restorable route information, including the initially active tab.

- Nested direct links build parent/child pages and inherit path parameters.
- Shared shells, root overlays, nested stateful shells and independent indexed
  tab stacks are covered. Root overlays are excluded from tab history snapshots.
- A new router instance restores the selected tab, inactive nested destinations,
  JSON extra and RestorableInt widget values. App/shell/branch IDs remain required.
- Top-level/page/shell guards accept FutureOr<String?>. Async errors reach the
  errorBuilder; obsolete parses cannot override newer navigation. Pending errors
  after router disposal and async route-exit vetoes have regressions.
- Typed push/pushNamed results, pageBuilder, extraCodec and ActivityRouter.of are
  available. Router is no longer itself a RouterDelegate<Uri>.
- ICU MessageFormat 1 supports cached placeholders, cardinal categories, exact
  numeric selectors, offsets, nested select/plural, quoting and locale numbers.
  Fallback messages use fallback-locale plural rules. Complex numeric arguments,
  missing other branches, duplicate selectors and excessive nesting are validated.
- The README now follows QuickeyDB's overview/learning/examples/reference layout;
  the example demonstrates tabs, nested details, async account guards and ICU labels.

Runtime dependencies are now go_router **>=16.2.5 <16.3.0** (tested recursive
redirect semantics) and intl **>=0.19.0 <0.21.0**. The latter accommodates Flutter
3.29's SDK localization pin. No zero-dependency claim remains in package metadata.
Widening the router range requires rerunning the async/loop/restoration regressions.

## Repairs applied

| Review item | Implementation and verification |
| --- | --- |
| 1: early view disposal | Subscribe synchronously; cancel through the controller. Widget lifecycle regressions pass. |
| 2: disposal/replacement | Views reset values without manually disposing State; views/scopes rebind under the same key and cancel listeners. Shared controllers remain owned by the app. |
| 3: overlapping tasks | Per-key reference counts; immutable task snapshots; aggregate busy values in events. Same-key out-of-order completion is covered. |
| 4: cleanup races | Cached idempotent disposal future; reject mutations/new work immediately; retain pending task successes/errors without final-status exceptions. |
| 5: pagination | Validate positive arguments; return an empty page beyond the end; clamp final pages. |
| 6: navigation | Typed Navigator results, actual RoutePredicate, whole-stack offAll, separate replace; tested real widget navigation. Added Router API, named paths, parameters, queries, redirects, controller refresh and system back. |
| 7: collection aliases | Shallow original copies on each reset; materialize self-derived iterable inputs; capture previous clear contents, inserted element and original insertion index. |
| 8: equality/batches | Stable identity equality/hash; explicit equals for value comparison; legacy whole-batch type validation before mutation; typed ActiveUpdate/changeTo API with dynamic preflight checks. |
| 9: model/type divergence | ActiveModel extends ActiveType and registers in activities. Safe mock default including explicit nullable mocks; optional legacy snapshot-name parameter; late-value register API. |
| 10: web ENV | Conditional native/stub adapters. Public barrel compiles for web; parsing/assets/typed access work in Chrome. |
| 11: validation | Nullable custom callbacks, HTTP(S) URLs with hosts, explicit unknown-key policy, immutable result maps, valid calendar/clock values, type predicates and explicit unsupported types; improved IPv6 compression/embedded IPv4 checks. |
| 12: sticky replay | Live subscription attaches before per-subscriber cached replay. Exact emission generic cache contract; closure check before cache mutation; broadcast injection validation and ownership documented. |
| 13: identifiers | Fresh secure random RFC 4122 v4 UUIDs; public export; repeated-call/format tests pass on VM and Chrome. |
| 14: helpers/localization | Quoted ENV comments and malformed quote handling; real string/ENV tests; remove map debug prints; release logging opt-in. Configurable localization delegate, loader/bundle, locale tags, fallback keys/assets and context.tr interpolation. |

Additional improvements: ActivitySelector with immutable selections/records,
updateValue/select/setIfChanged helpers, numeric/text/nullable/list/map/date
extensions, fixed oldActiveTypeValue, and safe typed error-data lookup. The example
now demonstrates shared ownership, selectors, localization, and URL navigation.

## Validation of this implementation

On macOS arm64 with **Flutter 3.47.7 / Dart 3.13.5**:

- `flutter pub get`: refreshed stale package metadata, which had still selected an
  older language version, and removed obsolete resolved native/storage dependencies.
- `flutter analyze --no-pub`: **no issues**.
- `flutter test --no-pub`: **273 passed**.
- `flutter test --no-pub --platform chrome test/events test/helpers test/navigation
  test/localization test/state/regressions_test.dart`: **105 passed**.
- Example web release compilation: **passed**, including Flutter's Wasm dry run.
- The earlier single example smoke test has been replaced by the eight gallery
  tests documented above.

- Localization regressions also pass with **intl 0.19.0**: **20 passed**. Normal
  dependency resolution is restored to intl 0.20.3 for the current SDK.
- The complete README counter example and the new routing/ICU Dart snippets were
  assembled with shared imports/context and analyzed against the actual API.

The checked-in GitHub workflow adds Linux/macOS/Windows host tests, a Flutter
3.29.3 minimum-SDK job, Chrome regressions, example tests and web compilation.
Those hosted jobs have not been run in this local session. A Wasm dry run is not
an executed Wasm browser test; device/emulator/native release builds and actual
browser back/forward history interactions still need separate platform coverage.

## Deliberate limits and follow-up work

- Collection snapshots are shallow. Nested mutable application objects need
  immutable models or an overridden snapshot policy. Direct mutation through
  `.value` bypasses notifications and guards for compatibility.
- Standard batch values are prevalidated; arbitrary overridden setters with
  user-defined side effects are not rolled back. Dynamic maps remain a legacy API.
- Constructor registration remains eager. Late-created fields require register
  and inclusion in activities if they must reset with the controller.
- Pending async work is not canceled by disposal. Check isDisposed after awaits
  before updating values. Task cancellation belongs to the application/service.
- Routing uses the tested go_router range, not a promise of every API in later
  engine majors. Native route types remain available. Controller/model persistence
  is separate from restoration of navigation and RestorableProperty values.
- ICU scope is MessageFormat 1 cardinal plural/select. Selectordinal, date/number
  skeletons, MessageFormat 2 and rich text remain outside the formatter. Missing
  loader resources must be handled by the loader; malformed assets/messages remain
  visible errors. Numeric inputs cannot preserve textual fractional precision.
- IP validation is syntactic, not network verification. IPv6 zone IDs are rejected;
  IPv4 retains its existing allowance for decimal groups with leading zeroes.
- Event buses are isolate-local; they do not bridge isolates or platform processes.
- Newer Dart syntax is optional. The declared minimum remains 3.7.2; upgrades to
  Dart 3.8+ syntax require a deliberate consumer compatibility decision.

---

# Activity code review observations

Reviewed on 16 October 2026 against commit
`cecc2dfce851b6fd2e44df4416be5a3e99b4a453` and the source present at validation.
The review below records the historical baseline before implementation. See the
19 October status above for repairs now applied to source and metadata.

The checkout changed during the review. Earlier files for persistence, networking,
and SurveyJS disappeared and the SDK constraint changed; those obsolete modules
are excluded from the final findings. Current `activity.dart` exports state,
helpers, localization, and navigation. `Deamon` requires its own import.

## Validation baseline

- Declared minimum: Dart `^3.7.2`; installed Dart: **3.13.5 stable**, macOS arm64.
- `flutter analyze --no-pub`: **17 issues**, comprising **3 warnings and 14 infos**;
  no analyzer errors. Warnings concern the redundant bool null check and two
  `operator ==` parameter declarations. Infos cover imports, view factory style,
  overrides, debug prints, and const constructors in tests.
- `flutter test --no-pub`: **201 passed, 4 failures**. Two files fail to load
  because they have no `main`: `test/helpers/env_test.dart` and
  `test/helpers/strings_test.dart`. Validator tests `validates pattern rule` and
  `validates custom rule` also fail. This is an existing baseline, not a passing
  suite.
- README Dart examples were assembled with their shared imports/declarations and
  checked with the analyzer; no compilation errors. This does not establish runtime
  behavior or platform support.
- No OS matrix, browser build, benchmark, or published package version was
  verified. Source findings below are static inspection unless explicitly
  identified as test results.

## Correctness and lifecycle

### 1. High: delayed view subscription can fail during early disposal

**Source:** `lib/core/src/view.dart`, `ActiveState.initState` and `dispose`.

`_stateSubscription` is `late final` and assigned inside a post-frame callback.
If the state is removed before that assignment, `dispose()` reads an uninitialized
field and can throw `LateInitializationError`. The callback also has no mounted
check before registering, and events before registration can be missed.

**Improve:** subscribe synchronously in `initState`; the listener can retain its
mounted check. Alternatively use a nullable subscription, check mounted in the
callback, and cancel safely. Release through `controller.cancelSubscription` so
the controller also removes the canceled subscription from its retained list.

**Verify:** mount/remove within one frame, update before the first frame, and
repeat mount/dispose cycles while keeping the controller alive.

### 2. High: manual disposal and incomplete controller replacement handling

**Source:** `lib/core/src/view.dart`, `resetActivities`; `lib/core/active.dart`,
`_ActivityState.initState` and `build`.

`ActiveState.resetActivities()` starts asynchronous controller cleanup without
awaiting it, then calls `dispose()` directly. Flutter still owns the mounted
state and can dispose it again. `Activity` never stores/cancels its listener.
Both view paths lack a controller-change subscription strategy; `ActiveState`
keeps its constructor-injected controller, and `Activity` stays subscribed to the
old controller if its widget receives a new one.

**Improve:** separate value reset from owner-managed terminal controller cleanup;
never manually dispose a mounted State. Store each scope subscription and cancel
it in `dispose`. Implement `didUpdateWidget` rebinding or explicitly require
stable controller identity and a new widget key when replacing it.

**Verify:** replace controllers under the same key; dispose one consumer of a
shared controller and confirm the remaining consumer continues working.

### 3. High: same-key concurrent tasks become idle too early

**Source:** `lib/core/src/controller.dart`, `activeAsync`, `_addIsRunningKey`,
`_removeIsRunningKey`, and `activeTasks`.

Running keys are deduplicated. Two concurrent calls using `load` register one
entry; completion of the first removes it while the second is still running.
`activeTasks` exposes the mutable backing list, allowing callers to bypass status
bookkeeping. Task events report `isRunning`/`!isRunning` rather than the actual
aggregate transition, so finishing one of several tasks can report a misleading
status pair.

**Improve:** use per-key reference counts (or reject duplicate execution), return
an unmodifiable tasks snapshot, and capture actual before/after busy status.
Keep unique operation identifiers if callers need individual task visibility.

**Verify:** complete two same-key tasks in both orders, test distinct keys,
exceptions, duplicate starts, and idle calls for nonexistent keys.

### 4. High: cleanup races with in-flight work

**Source:** `lib/core/src/controller.dart`, `resetActivities`, `_checkDisposed`,
and `activeAsync`.

`_disposed` becomes true only after awaited cancellation and stream closure.
Concurrent cleanup calls can enter together; new operations can start while
cleanup is suspended. A task completing after cleanup calls
`setRunningStatus` in `finally`, which throws and may replace the task's original
exception or successful result.

**Improve:** mark disposal at entry, cache one cleanup future, prevent new work,
and choose an explicit pending-task policy (drain, cancel, or ignore final status
notifications after disposal). Clear running state consistently. An idempotent
`Future<void> dispose()` name would communicate intent better than reset.

**Verify:** dispose twice concurrently, close during a successful/failing task,
and try subscribing or mutating after disposal begins.

### 5. High: out-of-range pagination has an unsafe fallback

**Source:** `lib/core/types/active_list.dart`, `paginate`.

For a page beyond the end, `sublist(startIndex, endIndex)` can throw. The catch
then returns `_value.sublist(0, 10)`, which throws again on fewer than ten items
and returns an unrelated first page on longer lists.

**Improve:** keep positive-argument validation, return an empty list when start
is beyond length, clamp the end, and remove exception-based normal control flow.
Proposed implementation:

```dart
List<T> paginate({int pageNumber = 1, int pageSize = 2}) {
  if (pageNumber < 1 || pageSize < 1) {
    throw ArgumentError('pageNumber and pageSize must be positive');
  }
  final start = (pageNumber - 1) * pageSize;
  if (start >= value.length) return <T>[];
  final end = (start + pageSize).clamp(0, value.length);
  return value.sublist(start, end);
}
```

**Verify:** empty list, short final page, exact boundary, page beyond the end,
and invalid arguments.

### 6. High: route predicate implementation is invalid

**Source:** `lib/core/navigation/active_navigation.dart`, `pushUntil` and
`predicateRoute`.

`pushUntil` passes `predicate()` (a Widget) into a helper that later invokes it
as a function. It also compares an existing Route against a newly created Route,
which normally cannot match. This can throw or remove more routes than intended.
`offAll` uses `pushReplacement`, which only replaces the top route.

**Improve:** accept a `RoutePredicate` directly and pass it to
`Navigator.pushAndRemoveUntil`. Rename `offAll` or implement actual stack clearing
in a versioned API change. Give navigation methods typed `Future<T?>` results.

**Verify:** retain a named route, remove all routes, return route results, and
check the actual stack after replacement.

### 7. Medium: collection events and reset originals are mutable aliases

**Source:** `lib/core/types/active_list.dart`, `clear`, `insert`, `insertAllAtEnd`;
`lib/core/types/active_map.dart`, `clear`; `lib/core/types/active_type.dart`, `reset`.

Clear events retain the collection that is then emptied, so `oldValue` no longer
contains the previous contents. `insert` emits the whole `value` list instead of
the inserted `element`. `insertAllAtEnd` records length after insertion rather
than the original insertion index. List/map constructors copy initial originals,
but base `reset()` subsequently assigns that original collection as the live
value: a later mutation changes what subsequent resets restore.

**Improve:** capture immutable event snapshots and the original insertion index;
use the inserted element in insert events. Give collections a reset strategy
that copies the saved original each time. Materialize lazy iterable arguments
before mutation and notification. Define shallow versus deep reset semantics.

**Verify:** inspect events after mutation, reset/mutate/reset twice, and test
nested mutable objects and iterable arguments derived from the same collection.

### 8. Medium: wrapper equality and batching undermine type safety

**Source:** `lib/core/types/active_type.dart`, `lib/core/types/active_models.dart`,
`equals`, `operator ==`, `hashCode`; `lib/core/src/controller.dart`, `activateTypes`.

A wrapper can equal a raw value (`ActiveInt(1) == 1`) while the reverse comparison
is false. Its hash changes after mutation. Batches use wrappers as map keys and
dynamic replacement values, validate one entry at a time, and can leave earlier
updates applied without notification if a later entry fails. Equal-valued wrappers
can also behave as equal keys in caller-created maps.

**Improve:** use identity for mutable wrappers and keep value comparison as an
explicit method. Migrate `==` to a deliberate `Object other` contract. Replace
single-entry maps with typed update operations; validate the complete batch before
committing and specify notification behavior for unchanged values and empty batches.

**Verify:** equality symmetry, mutable map/set membership, wrong generic values,
and an invalid second batch entry leaving the first unchanged.

### 9. Medium: type/model registration APIs diverge

**Source:** `lib/core/types/active_type.dart`, `lib/core/types/active_models.dart`,
and the controller's `activities` getter.

`ActiveModel` duplicates much of `ActiveType` but cannot appear in the controller's
`Iterable<ActiveType>`. It requires manual attachment. `ActiveType.mockValue`
reads a private `late` field that is never initialized. Its
`setOriginalValueToCurrent(String? typeName)` requires an unused argument while
its doc example calls it with none.

**Improve:** share a typed reactive interface/implementation, document attachment,
remove or initialize mock state, and make the unused parameter optional or remove
it in a migration. Prefer immutable application models and explicit copy methods.

**Verify:** model registration, first access to mock state, snapshot changes,
nullable resets, and compilation of API doc snippets.

## Helpers and platform behavior

### 10. High for web consumers: native ENV import reaches the public barrel

**Source:** `lib/activity.dart` and `lib/core/helpers/env.dart`.

The public barrel exports an ENV helper that unconditionally imports `dart:io`.
A runtime `kIsWeb` check does not make native dependencies browser-compatible.

**Improve:** isolate native file access behind conditional imports and a browser
stub; keep parsing, typed access, and asset loading platform-neutral. Compile a
small barrel-importing web app in CI before advertising browser support. The
removed networking/storage code is not part of this finding.

### 11. Medium: validator contracts and checks need tightening

**Source:** `lib/core/helpers/schema_validator.dart`; failing cases in
`test/helpers/scheme_validator_test.dart`.

- The documented custom rule returns null on success, but the implementation
  checks for `String Function(dynamic, Map<String, dynamic>)`. Nullable-returning
  functions are skipped, so invalid values can pass silently. Accept a documented
  `String?` callback or enforce the existing empty-string success contract.
- The pattern fixture uses `r'^ABC\\d+\$'`, which matches neither the intended
  digit class nor end anchor. Use `r'^ABC\d+$'` for `ABC123`; correct the fixture
  before changing the matching algorithm.
- URL validation uses `Uri.hasAbsolutePath`: `/local/path` can pass while a useful
  absolute URL with an empty path can fail. Validate allowed scheme and host.
- Custom type matching by runtime-type name does not establish subtype validity;
  unsupported type declarations default to success. Use typed predicates or reject
  unsupported schema definitions explicitly.
- `schema` begins as the whole input and retains undeclared keys. Add an explicit
  unknown-key policy; do not imply allowlist sanitization.
- Dates use permissive parsing and IP checks use regexes with documented limits.
  Define strictness, especially for invalid calendar dates and IPv6 edge cases.
- Response fields are final but their maps remain mutable shallow copies. Consider
  unmodifiable results and document nested ownership.

**Verify:** nullable custom callbacks, malformed schemas, unknown fields,
relative/absolute URLs, strict dates, and representative IP addresses.

### 12. Medium: sticky events can lose updates during replay

**Source:** `lib/core/events/deamon.dart`, `onSticky`, `emitSticky`, `withController`.

`onSticky` captures a cached value when the stream is requested, yields it, then
subscribes to the broadcast source through `yield*`. Events before that live
subscription can be lost. Reusing the returned broadcast stream does not
necessarily replay a cached value to each later subscriber. Sticky cache keys use
the emission generic type, whereas live filtering uses subtype checks.

**Improve:** define per-subscriber replay semantics, attach to live events before
replaying with an ordering strategy, and document exact-type versus subtype cache
lookup. Check openness before updating the sticky cache. Clarify ownership of an
injected controller, broadcast requirements, and error forwarding.

**Verify:** emit during cached replay, subscribe twice at different times, emit a
subtype with a base-type listener, emit after close, and close an injected bus.

### 13. Medium: UUID helper repeats one value for the whole process

**Source:** `lib/core/helpers/uuid.dart`, `UniqueID.generateUuid`.

The random string is generated once in a static final field and returned on every
call; it is neither unique per call nor a UUID. It is currently not barrel-exported.
Generate fresh identifiers with a documented collision model and format, or remove
this unused helper. Test repeated calls and any required UUID-format contract.

### 14. Low/medium: parsing, logging, and localization contracts

**Sources:** `lib/core/helpers/env.dart`, `logger.dart`, `strings.dart`,
`lib/core/types/active_map.dart`, and `lib/core/localization/active_localizations.dart`.

ENV's quoted-value parser strips quotes by checking the end of the entire value,
so quoted values followed by inline comments need explicit tests. Whitespace before
comment-only lines and malformed quotes should have defined handling. `getUri`
parses relative URIs too; callers requiring an API endpoint need additional checks.
Add real ENV/string tests in place of the empty test files.

Remove the two unconditional debug prints in `ActiveMap.update`. Decide whether
release logging should be opt-in; `Logger.printInRelease` defaults to true.
Localization uses a mutable global language list and forced-null lookups; prefer
an injected typed locale configuration and explicit missing-key/delegate fallback.
Test missing assets, unknown locales, and missing translations.

## Dart style and feature modernization

The installed SDK is newer than the package's **3.7 language version**. Keep that
baseline for compatible cleanup, or deliberately raise it with a matching minimum
Flutter version and CI coverage. Feature versions below were checked against
[Dart language evolution](https://dart.dev/resources/language/evolution).

| Feature / style | Minimum | Activity use |
| --- | --- | --- |
| Patterns, switch expressions, records, class modifiers | 3.0 | Typed rule handling, exhaustive log-level mapping, structured internal results; preserve public subclassing intentionally. |
| Extension types | 3.3 | Optional validated identifiers; they do not replace notification-owning reactive objects. |
| Wildcard variables and language-versioned formatter | 3.7 | Unused callback arguments and consistent formatting; already compatible. |
| Null-aware collection elements | 3.8 | Optional entries when constructing payloads; requires a baseline increase. |
| Dot shorthand | 3.10 | Context-typed enum and constructor expressions; optional readability cleanup. |
| Private named initializing parameters | 3.12 | Reduce constructor forwarding boilerplate around private fields. |
| Primary constructors and concise constructors | 3.13 | Optional concise declarations for small data classes after an SDK migration. |

These are selective opportunities, not requirements to adopt every feature. See
[Dart language versioning](https://dart.dev/language/versions) before changing
constraints. If future browser adapters are introduced, use the supported
[web interop approach](https://dart.dev/interop/js-interop/package-web).

Compatible cleanup to prioritize now:

- Type all callback results explicitly (`void Function(...)`), parameterize stream
  subscriptions, and reduce raw types/dynamic casts at internal boundaries.
- Preserve generics through `State<Activity<T>>` and return the controller with
  `() => widget.activeController`; eliminate the unusual generic closure/cast in
  `Activity.build` and unnecessary Builder where appropriate.
- Use `super.key`, final locals, const immutable event constructors, and explicit
  override annotations. Remove the non-nullable bool assertion.
- Run `dart format` in a separate code change, then inspect `dart fix --dry-run`;
  do not apply automated public API changes without review.
- Update the old `flutter_lints: ^2.0.0` policy after checking SDK compatibility;
  consider strict casts/inference/raw-types and discarded-future diagnostics.
- Document whether registration is constructor-only; values added later to
  `activities` are not automatically attached.
- Align documentation, examples, and metadata with the current state-only scope;
  audit the example app separately and test README snippets in CI.

## Suggested implementation order

1. Repair lifecycle and disposal, task overlap, pagination, and route predicates.
2. Repair event snapshots, resets, equality/batches, and validator contracts.
3. Add missing helper tests and platform isolation; establish a green test/analyzer
   baseline and native/web smoke builds.
4. Consolidate reactive interfaces and make any breaking API changes explicit.
5. Adopt compatible style cleanup, then select a newer SDK baseline only when
   newer language features offer enough value to justify consumer migration.

For each repair, use the targeted regression scenarios listed above. Existing
happy-path tests passing does not establish coverage of these edge cases.

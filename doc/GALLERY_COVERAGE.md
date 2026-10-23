# Public API → runnable gallery → regression coverage

Inventory checked against `lib/activity.dart` on 20 October 2026. A checked item
means the API family has a live demonstration, not that every inherited Dart
method has a separate button. The gallery calls public APIs; it does not promise
feature parity with external routing libraries.

| Covered | Public surface | Gallery / source | Verification |
| --- | --- | --- | --- |
| [x] | ActiveType / ActiveTypeValue, set/call/reset/updateValue/select/equals/setIfChanged, typed factories | Reactive values; [typed optional profile](../example/lib/gallery/recipes/typed_values.dart) | state/types and state/regressions tests |
| [x] | ActiveInt, ActiveDouble, ActiveBool, ActiveString, ActiveDateTime | Reactive values; Helpers | state/types and gallery tests |
| [x] | ActiveNullableInt/Bool/String, ActivityNullableDoubleProperty, ActivityNullableDateTimeProperty, nullable factories | Reactive values → Optional profile | compiled recipe and nullable regressions |
| [x] | ActiveModel / ActiveModelValue and model factories | Models & batches; optional profile | model/reset/batch regressions |
| [x] | ActiveList / ActiveMap and extension helpers | Lists & maps; [derived filter/sort](../example/lib/gallery/recipes/workbench_controller.dart) | collections, snapshots, pagination and recipe tests |
| [x] | ActiveUpdate, changeTo, activate, legacy activateTypes | Models & batches; optional profile | atomic preflight/type validation tests |
| [x] | ActiveController, registration, task counts, errors, dispose | Async; Lifecycle; application recipes | overlap/disposal/cancellation/stale-result regressions |
| [x] | Activity / Activator, ActiveView / ActiveState / legacy view base, ActivitySelector | Start here; Views & selectors | rebinding, consumer ownership and selective rebuild tests; legacy base is compatibility-only |
| [x] | ActiveStateChanged and event-list helpers | console state metadata; collections event inspection | state/state and controller tests |
| [x] | Deamon typed events, listen/on/next, sticky replay, close | Events & replay | events/deamon and replay tests; local example cancels subscriptions |
| [x] | ActivityRouter / ActivityRouteState / ActivityRoute | Navigation; database detail | named parameters, queries, typed push/pop, unknown locations and redirects |
| [x] | ActivityShellRoute, ActivityStatefulShellRoute / ActivityNavigationShell, native route exports | every gallery section; nested privacy settings; routing source | nested/shell/branch/restoration regressions |
| [x] | asynchronous guards, onExit, refreshController, restoration | Navigation & guards; State restoration | asynchronous failure/obsolete parse/exit veto and branch result tests |
| [x] | Nav imperative typed navigation | Navigation API reference; package imperative navigation tests | stack clearing/predicates/replacement/results; gallery itself uses URL routes |
| [x] | ActiveLocalization / ActiveLocalizationDelegate / context.tr / getTranslated | Localization & ICU; four JSON catalogs + Flutter SDK delegates | locale switching, fallback, interpolation, asset/loader tests |
| [x] | IcuMessage / IcuMessageException | editable ICU playground | exact/cardinal/offset/select/quoting, nesting and malformed input tests |
| [x] | SchemaValidator / SchemaResponse / Rules | Schema validation; reactive draft recipe | custom nullable rules, sanitization, strict dates/IP/URL regressions |
| [x] | ENVSetup / EnvLogger / ConsoleEnvLogger | Environment config | asset loading, string parsing, native-only file adapter tests |
| [x] | SuperString, typed numeric/text/date/list/map extensions, UniqueID, Logger / LogLevel | Helpers; collections; optional profiles; recipes | helper/type tests on host and browser |
| [x] | theme and locale preferences | Appearance + nested privacy settings | application-owned Activity state, Flutter theme/locales, restoration tests |

ThemeData and restoration properties belong to Flutter; Activity provides the
state and routing integration, not a separate theme engine or durable storage.
ErrorEvent and exception classes also have dedicated source imports; examples
that use them include those imports. Unexported carousel widgets and legacy task
files are not advertised as public gallery capabilities.

## Supported behavior and boundaries

- Collections copy shallowly. Use immutable models; mutation through `.value`
  bypasses notifications. Selector equality is Dart `==`; select scalars,
  immutable records, or fresh snapshots. Fresh lists/maps can rebuild more often.
- `activeAsync` tracks tasks, not transport cancellation. The workbench generation
  token rejects stale results; use a service cancellation token to stop real I/O.
- Events are isolate-local on every platform. They do not bridge OS processes,
  browser tabs, workers or isolates. Exact generic sticky caches are intentional.
- Routing uses Flutter Router/Navigator directly. Guard checks are client
  navigation UX, never server authorization. Nested routes, custom transitions,
  branch history, restoration and pending typed results have regression tests.
- Default hash URLs support static hosting. Browser back/forward follows route
  navigation; switching retained branches is not durable model persistence.
- Restoration requires stable IDs and OS/Flutter restoration data. It does not
  save controller fields across a full web reload. Details opened from direct
  database links may have no record because the sample database is session-only.
- ICU supports MessageFormat 1 cardinal plural/select, offsets and locale number
  rendering. No selectordinal, date/number skeletons, MF2 or rich-text formatter.
- ENV assets are public. A native file reader is unavailable on web. An injected
  localization loader must define its own resource/retry policy.
- QuickeyDB 3.0.0 is an unpublished workspace dependency in this example. Its
  process-global open handle means other QuickeyDB integrations must coordinate.
  This sample intentionally uses no encryption or durable data. See the QuickeyDB
  security/migration guides for persistent data and key recovery.

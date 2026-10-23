# Activity test map

[Package guide](../README.md) · [Runnable example](../example/README.md) · [Validation record](../Observations.md)

| Area | Files / coverage |
| --- | --- |
| Controller and values | state/: registration, notifications, resets, typed values and helpers |
| Lifecycle regressions | state/regressions_test.dart: concurrency, disposal, immutable snapshots, batches, scope/controller replacement and selectors |
| Navigator conveniences | navigation/navigation_test.dart: route parameters, controller refresh, back/results, stack clearing and redirect cycles |
| Native router contracts | navigation/native_router_test.dart: custom transition pages, encoded URLs, retained push results, dialog back, codec round trips and disposal |
| Nested routing | navigation/advanced_navigation_test.dart: parent pages, shell overlays, retained branches and nested shell history scoping |
| Restoration | New router instance, selected/inactive tabs, nested history, JSON extra and RestorableInt values |
| Async guards | Protected builder withholding, stale completions, controller refresh, errors, disposal and asynchronous exit veto |
| ICU | localization/icu_message_test.dart: locale categories, exact selectors, offsets, nested select/plural, quoting, localized numbers and invalid input |
| Localization integration | localization/localization_test.dart: loaders, asset tags, missing assets/keys, fallback and context extension |
| Events and helpers | events/ and helpers/: sticky replay, platform-neutral ENV, validators, logging, strings and UUIDs |

Run from the package root:

```sh
flutter pub get
flutter analyze
flutter test
flutter test --platform chrome test/events test/helpers test/navigation test/localization test/state/regressions_test.dart
```

Run the gallery widget suite/build from example/:

```sh
flutter pub get
flutter test
flutter build web
```

CI includes Linux/macOS/Windows host jobs and the minimum Flutter SDK job. Local
host/Chrome results are recorded separately in Observations.md; a configured CI
job does not establish that it has run. Widget restoration and simulated route
information cover parser behavior; device process restoration and browser UI
Back/Forward still benefit from platform end-to-end checks.

The gallery suite visits all 19 sections at desktop and phone widths and tests
CRUD, events, validation, ENV assets, branch results, async/exit guards, ICU,
restoration, concurrent work, lifecycle cleanup and drawer search. Its host suite
passes; initial localization remains unresolved in the Chrome widget harness.
See Observations.md for the separate package Chrome and release-browser results.

The example has its own feature tests under `example/test/gallery`: safe opt-in
console diagnostics, latest-response/cancellation/retry policies, real SQLite
rollback/CRUD/disposal, complete source assets, draft retention and mobile dock
controls. `example/test/widget_test.dart` covers the gallery route catalog,
state/helpers/events/guards/ICU/restoration/preferences. Run example tests from
`example/`, with its adjacent QuickeyDB checkout resolved. `dart run tool/test_web.dart`
stages matching worker/WASM assets for Chrome. See `doc/GALLERY_MIGRATION.md` for
local dependencies and the manual CI workflow's reviewed QuickeyDB ref requirement.

## Exact documentation snippets

Run `dart run tool/check_doc_examples.dart` from the package root to compile and
execute the marked API comments themselves (57 examples). `--chrome` validates
those same examples in a browser; `--format` updates their code formatting.
Temporary fixtures are removed automatically. This supplements the feature
regressions and gallery interactions rather than replacing them.

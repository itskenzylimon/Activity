# Gallery integration and upgrade notes

Verified 20 October 2026 through [Activity metadata](https://pub.dev/api/packages/activity)
and [QuickeyDB metadata](https://pub.dev/api/packages/quickeydb): the latest published
Activity is **1.5.3+5** (published 5 February 2023); this workspace remains
**2.0.0, unreleased**. Its existing release version has not been changed by this
example update. Follow the [1.x migration](../README.md#migrating-from-1x) for
identity equality, controller disposal, corrected navigation stack semantics,
validation changes and the intl dependency. Source in this checkout must
not be presented as code supported by the older published package.

QuickeyDB's published version is **1.2.0+8** (28 June 2023). The example uses its
adjacent **3.0.0 workspace**, not a nonexistent pub.dev 3.0 dependency:

```yaml
# Activity/example/pubspec.yaml only; Activity/lib does not depend on QuickeyDB.
activity:
  path: ../
quickeydb:
  path: ../../quickeydb
```

Keep both sibling checkouts when running the gallery. This integration raises
only the **example** requirement to Dart 3.9 / Flutter 3.35 or later, matching
QuickeyDB. Activity library requirements remain Dart 3.7.2 / Flutter 3.29.
Package tests and consumers of Activity alone do not need QuickeyDB.

## Likely integration conflicts

- ActivityRouter uses Flutter Router/Navigator directly. Pushes update browser
  URLs; a pending result Future does not survive a full reload/process restart.
- Replace native external-router route types with ActivityRoute/ActivityShellRoute
  and ActivityShellBranch; use context.activityRouter for navigation. Own one
  MaterialApp/router for each independent application tree.
- Match the Flutter SDK's intl pin. Activity accepts intl 0.19–0.20.
- Give each database one application owner. QuickeyDB allows a single active
  global database in an isolate; opening this recipe alongside another open
  QuickeyDB handle will fail visibly rather than silently replacing that handle.
- Native desktop SQLite uses FFI/build hooks and a supported C toolchain. Mobile
  uses sqflite. Web needs the matching `sqflite_sw.js` and `sqlite3.wasm` pair,
  same-origin worker access and a browser supporting the package's worker backend.
  This example copies the verified pair from the adjacent QuickeyDB example.
- Plugins added by the example may require platform regeneration or `pod install`
  in an existing native app. Do not remove signing, sandbox or keychain settings
  to bypass unrelated native environment errors. Native builds are separate checks.
- The sample is in-memory plaintext SQLite. Do not use the sample as a private
  records storage design without adding secure key ownership, persistence,
  backups/migrations and tests. Keep QuickeyDB data/key migration policy separate
  from Activity navigation restoration.

## Diagnostics configuration

Run `flutter run -d chrome --dart-define=ACTIVITY_DIAGNOSTICS=true` for development
metadata. It is opt-in, bounded to 80 entries and hard-disabled in release builds.
The dock can also opt in while debugging. Controller watches omit old/new values;
navigation records route templates without parameters or queries; errors record
operation descriptions without exception payloads. Explicit terminals show sample
records and input only within their own examples. Never forward production
credentials or record bodies to diagnostic messages.

The app root owns settings, playground, router, diagnostic subscriptions and the
records controller. RecordsController drains its queued database operations before
closing its own database. WorkbenchController is feature-owned and invalidates
pending response tokens on disposal. Children cancel their own subscriptions and
text controllers; they never dispose borrowed application controllers.

## Project support

Support development through [aflare.space](https://aflare.space),
[GitHub](https://github.com/itskenzylimon/Activity) and
[Activity on pub.dev](https://pub.dev/packages/activity). `GIFT_URL`, `COFFEE_URL`
and `SOCIAL_URL` are optional HTTPS dart-defines; empty slots are disabled and
labeled as examples. Supply real destinations yourself; no payment accounts
are included or configured by this work.

Maintainers should review code, licenses, compatibility and release checks.

## CI with an unpublished companion package

Package CI analyzes/tests `lib` and `test` independently, including the library's
minimum Flutter version. The manual **Activity gallery workspace** workflow asks
for a reviewed QuickeyDB commit/ref containing its 3.0.0 API and checks out sibling
folders. It runs analysis, host/Chrome gallery tests and a web build. Until that
companion work is available on a remote ref, reproduce the checks locally; do not
substitute the incompatible pub.dev release. Hosted workflows were not executed
by this update.

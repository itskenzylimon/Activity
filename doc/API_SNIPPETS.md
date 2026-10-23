# Browsable feature examples

Feature-level Dartdoc comments now contain **57 complete examples**, with two
examples per feature and three for ICU interpolation/plural/select. They cover
reactive scalar/nullable values, lists/maps/models/batches, controller tasks and
recovery, scopes/views/selectors, typed events, routes/results, localization,
validation, public configuration, strings, identifiers and logging.

Each example includes imports and setup. Reactive mutations have a registered
controller; owners dispose controllers/routers and close event buses. The code
blocks are ordinary Dartdoc Markdown, visible in editor documentation and a
Dartdoc browser. `activity-snippet` markers let the verifier extract the exact
source, not a manually maintained test copy.

## Browser and dependency requirements

Widget programs call `runApp` and require Flutter, including Flutter web. Non-UI
programs can run in a Flutter-enabled console/test host. ENV parser/typed getters
are browser-safe; native ENV file reads are not. Asset localization additionally
requires assets declared by the host app. The self-contained localization
examples instead show injected catalogs and fallback behavior.

These examples describe this **unreleased Activity 2.0.0 checkout**. Plain DartPad
or another browser runner must resolve this implementation and its dependencies;
using the older published Activity package does not make the snippets compatible.
The supported local browser workflow is the [gallery](../example/README.md#run-it).
No hosted gallery URL or embedded DartPad availability is claimed.

## Check the comments themselves

From the Activity package root after `flutter pub get`:

```sh
dart run tool/check_doc_examples.dart
CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  dart run tool/check_doc_examples.dart --chrome
# Optional maintainer step: format the code inside the marked comments.
dart run tool/check_doc_examples.dart --format
```

The tool extracts marked blocks into temporary `test/.api_snippets` files,
compiles every example, executes non-UI assertions and mounts/unmounts each widget
example. It cleans those files on completion. Widget smoke checks do not replace
feature interaction tests; package and gallery suites cover routing, reactive
updates, errors, localization, async overlap and browser assets. Native builds
and hosted CI require their own validation.

Each feature links to an anchored [gallery walkthrough](../example/README.md#feature-walkthroughs)
with its hash route, complete view/controller source, API panel and practical
limitations. The [coverage checklist](GALLERY_COVERAGE.md) maps additional
capabilities to their tests.

For release checks, add `--include-pub-example` to either command. It checks the
57 comment examples plus the standalone published counter, and verifies that
example/example.md displays its current source. Browser tests stage that exact
file under the test server root because browser compilation cannot import a
relative example file from outside test/. No separate program copy is maintained.

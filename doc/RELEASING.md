# Publishing Activity 2.0.0

Prepared 23 October 2026. The package version remains **2.0.0**. Pub.dev metadata
currently lists **1.5.3+5** as latest; 2.0.0 was not already published when checked.
Release changes are committed locally at the maintainer’s request. No package
upload, remote push or release tag is performed by this preparation.

## Before publishing

- [ ] Review the short [changelog](../CHANGELOG.md) and [1.x migration guide](../README.md#migrating-from-1x), especially removed HTTP/WebSocket/storage APIs and changed equality, disposal and navigation contracts.
- [ ] Confirm 2.0.0 is the intended version and is still available on pub.dev.
- [ ] Run the checks below on the final source. Review minimum-SDK/platform CI results; do not describe unrun native builds as verified.
- [ ] Review modified **and untracked** files, stage intended changes and commit/push the release source. Published documentation links target main; merge/push the reviewed release there before publishing.
- [ ] Inspect the dry-run file list: lib/, LICENSE, README, CHANGELOG, guides, logo, screenshots and standalone example must be present. Builds, caches, local .env files, signing files and IDE state must be absent.
- [ ] Rerun the dry run from the clean release checkout and resolve its warnings. Do not use --force or skip validation to hide unfinished work.
- [ ] Use a pub.dev account authorized to publish the existing `activity` package. Check the final name/version before confirming the upload.

## Verification commands

Run from the **Activity package root**, not its example directory:

```sh
cd /Users/kenzy/IdeaProjects/aflare-space/plugins/external/Activity
flutter pub get --no-example
flutter analyze --no-pub lib test tool example/activity_example.dart
flutter test --no-pub
dart run tool/check_doc_examples.dart --include-pub-example
dart run tool/check_doc_examples.dart --chrome --include-pub-example
git diff --check
flutter pub publish --dry-run
```

Set `CHROME_EXECUTABLE` if Flutter cannot find Chrome. On this Mac:

```sh
export CHROME_EXECUTABLE='/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
```

The full workspace gallery additionally uses the sibling QuickeyDB 3.0 checkout:

```sh
cd /Users/kenzy/IdeaProjects/aflare-space/plugins/external/Activity/example
flutter pub get
flutter test --no-pub
dart run tool/test_web.dart
flutter build web --no-pub --no-web-resources-cdn --no-wasm-dry-run
```

The package and [standalone example](../example/activity_example.dart) only need
Activity/Flutter dependencies. QuickeyDB is not a library dependency. For a package-
only repository checkout without the companion gallery, use `flutter pub get
--no-example` and analyze `lib test tool
example/activity_example.dart` rather than resolving the workspace gallery.

Review and commit using your normal Git workflow. These read-only commands help
check what will be staged; new files do not appear in `git diff` until staged:

```sh
git status --short
git diff --stat
git diff --cached --stat
# Stage only reviewed release files using your Git client, then commit/push them.
# Rerun after committing; a clean checkout should have no Git-state warning.
flutter pub publish --dry-run
```

## Publish — only when the checklist is complete

```sh
cd /Users/kenzy/IdeaProjects/aflare-space/plugins/external/Activity
flutter pub publish
```

Review the CLI summary and complete its authentication/confirmation yourself.
After upload, verify the version, README, examples, screenshots and generated API
docs on [pub.dev](https://pub.dev/packages/activity). Tag the reviewed release
commit using your usual Git workflow after the upload succeeds.

## Packaging decisions

`.pubignore` explicitly excludes nested build/cache directories, private local
configuration, signing files and generated test fixtures. It replaces .gitignore
for publishing, so its patterns are independent. The workspace gallery sources
and intentional worker/WASM files remain reference material; the self-contained
`example/example.md` displays the complete counter on pub.dev; its runnable
source is `example/activity_example.dart`. The workspace-only
`example/pubspec.yaml` is excluded: the uploaded package's `flutter pub get` must
not attempt to resolve the unpublished sibling QuickeyDB checkout. To run the full
gallery, clone the repositories rather than relying on the package archive.

The tracked legacy activity.iml remains in the checkout but is excluded from the
upload. A narrow .gitignore exception prevents the checked-in-but-ignored warning.
No user work was reset or removed to make Git appear clean.

## Recorded local checks

The native routing follow-up passes 286 package tests, 27 navigation tests in
Chrome, 58 exact-source examples on VM/Chrome, 15 gallery tests on host and Chrome,
clean package/gallery analysis and a production web build. API docs generated
with Dartdoc 9.0.11 have zero warnings/errors across 27 public libraries.
Browser Back/Forward, nested reload and the new transition page were inspected.

## Remaining release gates

Publish from a clean committed checkout. If later edits or generated platform
updates appear, review and commit the intended changes before rerunning the dry
run; adding a tracked file to .gitignore does not clear its modification.
Hosted CI, minimum-Flutter reruns and native device builds are separate checks;
this local preparation does not certify them or package ownership permissions.

References: [Dart publishing guide](https://dart.dev/tools/pub/publishing),
[package layout](https://dart.dev/tools/pub/package-layout#examples), and
[pubspec metadata](https://dart.dev/tools/pub/pubspec).

## Source and ignore review

Recursive Git/pub exclusions now cover nested build/cache/coverage output, local
SQLite files and sidecars, private environment/key configuration, and temporary
browser/API test fixtures. These patterns do not untrack already committed files.
Review previously tracked generated platform files with the release diff; no
existing source or index entries were removed automatically. Intentional worker/
WASM assets, logos, screenshots and copyable source remain part of the examples.

The routing engine is implemented in Activity using Flutter Router/Navigator;
there is no external router dependency. See ROUTING.md and FEATURE_RECIPES.md.
See Observations.md for the validation record and rerun verification commands
before publishing.

Final independent archive checks after the routing/docs changes: plain dependency
resolution succeeds without the sibling package; publishing validation reports
zero warnings. Repeat the dry run from the committed release checkout before upload.

## Git-state publishing warnings

A modified-file warning means committed source and on-disk files differ. Include
intended platform/configuration changes in the release commit; do not revert
working changes merely to silence validation. Use `git status --short` to check
both staged and unstaged changes, then review with `git diff` and `git diff --cached`.

The QuickeyDB preparation also contained 34 tracked files deleted from disk,
including obsolete screenshots, Gradle files superseded by Kotlin DSL and old
example/test templates. Pub reported these absent tracked paths in its
checked-in-but-ignored warning. Recording their intended deletions removes that
mismatch. Use `git ls-files -d` for missing tracked paths and
`git ls-files -ci --exclude-standard` for genuine tracked/ignored overlaps.
Keep upload exclusions in .pubignore; .gitignore does not untrack existing files.

A version-jump hint does not require --force or a version downgrade. Keep the
reviewed intended release version and complete the normal publishing confirmation.

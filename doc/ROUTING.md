# Routing with Activity

[Package guide](../README.md) · [Live gallery](../example/README.md#navigation) ·
[Contract tests](../test/navigation/native_router_test.dart)

Activity implements its own route matching, guard resolution, stack ownership and
restoration on Flutter Router/Navigator. It has no dependency on an external
routing package. Use Activity route types throughout a tree; imperative `Nav`
helpers remain available for Flutter Navigator applications.

## A complete starting point

This app owns one router, matches an encoded item ID, and returns a typed result.
Create the router outside `build`; dispose it with its owner. Query strings carry
reloadable navigation state. Keep secrets and credentials out of URLs.

```dart
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CatalogApp());

class CatalogApp extends StatefulWidget {
  const CatalogApp({super.key});
  @override
  State<CatalogApp> createState() => _CatalogAppState();
}

class _CatalogAppState extends State<CatalogApp> {
  late final router = ActivityRouter(routes: [
    ActivityRoute(path: '/', name: 'catalog', builder: (context, state) =>
      Scaffold(body: Center(child: FilledButton(
        onPressed: () async {
          final chosen = await context.activityRouter.pushNamed<String>(
            'item', pathParameters: {'id': 'book/42'},
            queryParameters: {'tab': 'reviews', 'tag': ['dart', 'flutter']},
          );
          if (context.mounted && chosen != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(chosen)));
          }
        }, child: const Text('Choose an item'),
      )))),
    ActivityRoute(path: '/items/:id', name: 'item', builder: (context, state) =>
      Scaffold(appBar: AppBar(title: Text(state.pathParameters['id']!)),
        body: FilledButton(onPressed: () => context.activityRouter.pop<String>('Selected'),
          child: Text('Return from ${state.queryParameters['tab']}')))),
  ]);
  @override
  void dispose() { router.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => MaterialApp.router(routerConfig: router.config);
}
```

Expected URL: `/items/book%2F42?tab=reviews&tag=dart&tag=flutter`. The builder sees
`id == 'book/42'` and `queryParametersAll['tag'] == ['dart', 'flutter']`.
`queryParameters` returns one value per key. `uri.fragment` follows Dart Uri's
encoded-fragment contract; use `Uri.decodeComponent` for display.

## Choose the stack operation deliberately

| Operation | Use it when | Result/stack behavior |
| --- | --- | --- |
| `go` / `goNamed` | Selecting a destination or following a deep link | Rebuilds the matched ancestor hierarchy; a nested URL builds its parent pages |
| `push<T>` / `pushNamed<T>` | Asking a detail/picker for a result | Adds one page; the returned future resolves with the pop result |
| `replace<T>` | Replacing a transient screen | Replaces the top page; the old result completes with null |
| `pop<T>(value)` | Returning a selection | Requests removal; returns false at the root; an async exit guard can veto |
| `refresh()` | Rechecking an external session change | Runs global/route guards for the current location |

Results and custom extras are in-memory objects until serialized. A push future
cannot resume across a full browser reload or process restart. Disposal completes
outstanding page results with null. An obsolete guard completion cannot overwrite
a newer navigation.

## Nested pages and persistent layouts

Use absolute paths at the top level, relative children, and globally unique names.
Register static siblings before overlapping parameter routes. A direct link to
`/teams/7/members/9` builds team 7 and member 9; Back reveals the team page.

```dart
ActivityRoute(path: '/teams/:team', builder: (_, state) =>
  Scaffold(body: Text('Team ${state.pathParameters['team']}')), routes: [
  ActivityRoute(path: 'members/:member', name: 'member', builder: (_, state) =>
    Scaffold(body: Text('${state.pathParameters['team']}/${state.pathParameters['member']}'))),
]);
```

`ActivityShellRoute` supplies a shared layout and nested Navigator. Give it a
navigator key; set a child's `parentNavigatorKey` to the router's root key when
a modal-style page must cover the layout. Only ancestor navigator keys are valid.
The [shell regression](../test/navigation/advanced_navigation_test.dart) shows a
complete root-overlay configuration.

## Retained tabs are separate navigation histories

Use `ActivityStatefulShellRoute.indexedStack` with `ActivityShellBranch` entries.
The builder receives an `ActivityNavigationShell`; render it and switch using
`goBranch(index)`. It retains visited branches' mounted widgets and pending typed
push results. Pass `initialLocation: true` to reset the selected branch's stack.
Use an explicit branch `initialLocation` if its first route requires parameters.

```dart
ActivityStatefulShellRoute.indexedStack(
  restorationScopeId: 'workspace',
  branches: [
    ActivityShellBranch(restorationScopeId: 'inbox', routes: [
      ActivityRoute(path: '/inbox', builder: (_, __) => const Scaffold(body: Text('Inbox'))),
    ]),
    ActivityShellBranch(restorationScopeId: 'settings', routes: [
      ActivityRoute(path: '/settings', builder: (_, __) => const Scaffold(body: Text('Settings'))),
    ]),
  ],
  builder: (_, state, shell) => Scaffold(body: shell,
    bottomNavigationBar: NavigationBar(selectedIndex: shell.currentIndex,
      onDestinationSelected: shell.goBranch,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.inbox), label: 'Inbox'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ])),
);
```

## Authentication and unsaved edits

Global redirects run first, followed by matched shell/page guards. Return null to
allow, or an absolute local path to redirect. Guards may return a Future; protected
builders stay withheld while it resolves. Redirect loops/limits/errors reach
`errorBuilder`. The previous page remains visible during a pending navigation.

```dart
ActivityRoute(path: '/account',
  redirect: (state) async => await session.isSignedIn() ? null : '/login',
  builder: (_, __) => const Scaffold(body: Text('Account')),
);
// For reactive sessions: ActivityRouter(refreshController: sessionController, ...)
```

The session above is an application service; Activity does not authenticate with
a backend. Keep redirects side-effect free and enforce authorization at the data
source. Never redirect `/login` back to a protected page without checking session
state. A local return-to parameter should be validated as a local route before use.

`onExit(context, state)` can asynchronously ask to discard edits and return false
to stay. Use `context.mounted` after awaiting application work. Guards run on both
API navigation and system back. Ordinary Flutter dialogs remain pageless routes;
system Back dismisses the dialog before removing its underlying Activity page.

## Custom transitions and local state

```dart
ActivityRoute(path: '/preview', pageBuilder: (_, state) =>
  ActivityTransitionPage<void>(key: state.pageKey, restorationId: 'preview',
    transitionDuration: const Duration(milliseconds: 180),
    child: const Scaffold(body: Text('Preview')),
    transitionsBuilder: (_, animation, __, child) =>
      FadeTransition(opacity: animation, child: child)),
);
```

Supported page builders return `MaterialPage`, `ActivityTransitionPage`, or
`ActivityNoTransitionPage`. They retain Activity route-state scoping and exit-guard
behavior. Give custom pages stable keys (normally `state.pageKey`) and restoration
IDs. Route identity is retained when query/extra values change, so local widget
state does not reset merely because the selected query tab changed.

## Restoration, URLs and codecs

Set stable, unique restoration IDs on MaterialApp, ActivityRouter, shells and
branches. Flutter's restoration system saves navigation plus `RestorableProperty`
widget values. It does not persist ordinary controller fields or network data.
URL state is portable; `extra` needs a restoration-compatible value or an
`extraCodec: Codec<Object?, Object?>`. Do not serialize secrets into browser history.
Invalid/obsolete saved route information falls back to matching the current URL.
Guards run again for restored destinations and when selecting a restored tab.

Default hash URLs work on ordinary static hosting. For path URL strategy, configure
server fallback to the app entry point. Platform deep links override initialLocation
unless `overridePlatformDefaultLocation: true` is explicitly selected.

## Exposed Flutter integration

| API | Purpose |
| --- | --- |
| `router.config` | Pass the complete configuration to MaterialApp.router |
| `router.routerDelegate` | Observe native Flutter configuration changes and system back |
| `router.routeInformationParser` | Parse/restore ActivityRouteConfiguration and encoded extras |
| `router.routeInformationProvider` | Connect platform route information |
| `router.navigatorKey` | Access the root Flutter Navigator for pageless dialogs |
| `context.activityRouter` | Retrieve the owning ActivityRouter |
| `context.activityRoute` | Retrieve page-scoped path/query/extra state |

Earlier development checkouts exported external-engine types and helpers. Replace
GoRoute/ShellRoute with ActivityRoute/ActivityShellRoute, branches with
ActivityShellBranch, transitions with ActivityTransitionPage, and context.go/push
with context.activityRouter.go/push. `goRouter`, `nativeShell` and external-engine
match-list exports have been removed. Deprecated RouteBase/StatefulShellBranch
aliases refer to Activity-owned types for source migration only.

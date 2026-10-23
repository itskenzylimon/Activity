import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget page(String text) =>
    Scaffold(appBar: AppBar(title: Text(text)), body: Text('$text body'));

class RestorableCounter extends StatefulWidget {
  final String label;
  const RestorableCounter(this.label, {super.key});
  @override
  State<RestorableCounter> createState() => _CounterState();
}

class _CounterState extends State<RestorableCounter> with RestorationMixin {
  final count = RestorableInt(0);
  @override
  String get restorationId => 'counter_${widget.label}';
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) =>
      registerForRestoration(count, 'count');
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.label)),
    body: Column(
      children: [
        Text('${widget.label} count ${count.value}'),
        TextButton(
          onPressed: () => setState(() => count.value++),
          child: Text('increment ${widget.label}'),
        ),
      ],
    ),
  );
  @override
  void dispose() {
    count.dispose();
    super.dispose();
  }
}

ActivityRouter tabsRouter() => ActivityRouter(
  initialLocation: '/a',
  restorationScopeId: 'router',
  routes: [
    ActivityStatefulShellRoute.indexedStack(
      restorationScopeId: 'tabs',
      branches: [
        ActivityShellBranch(
          restorationScopeId: 'branch_a',
          routes: [
            ActivityRoute(
              path: '/a',
              builder: (_, state) => const RestorableCounter('A'),
              routes: [
                ActivityRoute(
                  path: 'details',
                  name: 'a-details',
                  builder: (_, state) => page('A details'),
                ),
              ],
            ),
          ],
        ),
        ActivityShellBranch(
          restorationScopeId: 'branch_b',
          routes: [
            ActivityRoute(
              path: '/b',
              builder: (_, state) => const RestorableCounter('B'),
            ),
          ],
        ),
      ],
      builder:
          (_, state, shell) => Scaffold(
            body: shell,
            bottomNavigationBar: Row(
              children: [
                TextButton(
                  onPressed: () => shell.goBranch(0),
                  child: const Text('Tab A'),
                ),
                TextButton(
                  onPressed: () => shell.goBranch(1),
                  child: const Text('Tab B'),
                ),
              ],
            ),
          ),
    ),
  ],
);

class RestorableApp extends StatefulWidget {
  final void Function(ActivityRouter) onRouter;
  const RestorableApp(this.onRouter, {super.key});
  @override
  State<RestorableApp> createState() => _RestorableAppState();
}

class _RestorableAppState extends State<RestorableApp> {
  late final router = tabsRouter();
  @override
  void initState() {
    super.initState();
    widget.onRouter(router);
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    restorationScopeId: 'app',
    routerConfig: router.config,
  );
  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }
}

void main() {
  testWidgets(
    'nested direct link builds ancestors, inherits params and names full paths',
    (tester) async {
      final router = ActivityRouter(
        initialLocation: '/teams/7/members/9?tab=posts',
        routes: [
          ActivityRoute(
            path: '/teams/:team',
            builder: (_, state) => page('Team ${state.pathParameters['team']}'),
            routes: [
              ActivityRoute(
                path: 'members/:member',
                name: 'member',
                builder:
                    (_, state) => page(
                      'Member ${state.pathParameters['team']}/${state.pathParameters['member']}/${state.queryParameters['tab']}',
                    ),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
      await tester.pumpAndSettle();
      expect(find.text('Member 7/9/posts'), findsOneWidget);
      expect(
        router.namedLocation(
          'member',
          pathParameters: {'team': 'a/b', 'member': '5'},
        ),
        '/teams/a%2Fb/members/5',
      );
      expect(router.canPop, isTrue);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Team 7'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );
  testWidgets('shell shares layout and parentNavigatorKey opens above it', (
    tester,
  ) async {
    final root = GlobalKey<NavigatorState>();
    final shellKey = GlobalKey<NavigatorState>();
    final router = ActivityRouter(
      navigatorKey: root,
      initialLocation: '/items',
      routes: [
        ActivityShellRoute(
          navigatorKey: shellKey,
          restorationScopeId: 'shell',
          builder:
              (_, state, child) => Column(
                children: [
                  const Text('Shell', textDirection: TextDirection.ltr),
                  Expanded(child: child),
                ],
              ),
          routes: [
            ActivityRoute(
              path: '/items',
              builder: (_, state) => page('Items'),
              routes: [
                ActivityRoute(
                  path: 'detail',
                  parentNavigatorKey: root,
                  builder: (_, state) => page('Overlay'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        restorationScopeId: 'app',
        routerConfig: router.config,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Shell'), findsOneWidget);
    router.go('/items/detail');
    await tester.pumpAndSettle();
    expect(find.text('Overlay'), findsOneWidget);
    expect(find.text('Shell'), findsNothing);
    expect(root.currentState!.canPop(), isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Shell'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });
  testWidgets(
    'stateful branches retain independent histories and widget state',
    (tester) async {
      final router = tabsRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
      await tester.pumpAndSettle();
      await tester.tap(find.text('increment A'));
      await tester.pumpAndSettle();
      router.goNamed('a-details');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tab B'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('increment B'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tab A'));
      await tester.pumpAndSettle();
      expect(find.text('A details'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('A count 1'), findsOneWidget);
      await tester.tap(find.text('Tab B'));
      await tester.pumpAndSettle();
      expect(find.text('B count 1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );
  testWidgets(
    'nested shells keep root overlays out of restored tab histories',
    (tester) async {
      late ActivityNavigationShell tabs;
      final router = ActivityRouter(
        initialLocation: '/a',
        routes: [
          ActivityShellRoute(
            builder:
                (_, state, child) => Column(
                  children: [
                    const Text('Outer', textDirection: TextDirection.ltr),
                    Expanded(child: child),
                  ],
                ),
            routes: [
              ActivityStatefulShellRoute.indexedStack(
                restorationScopeId: 'nested_tabs',
                branches: [
                  ActivityShellBranch(
                    restorationScopeId: 'nested_a',
                    routes: [
                      ActivityRoute(
                        path: '/a',
                        builder: (_, state) => page('A'),
                        routes: [
                          ActivityRoute(
                            path: 'deep',
                            builder: (_, state) => page('Deep'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ActivityShellBranch(
                    restorationScopeId: 'nested_b',
                    routes: [
                      ActivityRoute(
                        path: '/b',
                        builder: (_, state) => page('B'),
                      ),
                    ],
                  ),
                ],
                builder: (_, state, shell) {
                  tabs = shell;
                  return shell;
                },
              ),
            ],
          ),
          ActivityRoute(
            path: '/overlay',
            builder: (_, state) => page('Outside'),
          ),
        ],
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
      await tester.pumpAndSettle();
      router.go('/a/deep');
      await tester.pumpAndSettle();
      router.push<void>('/overlay');
      await tester.pumpAndSettle();
      expect(find.text('Outside'), findsOneWidget);
      tabs.goBranch(1);
      await tester.pumpAndSettle();
      expect(find.text('B'), findsOneWidget);
      tabs.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('Deep'), findsOneWidget);
      expect(find.text('Outside'), findsNothing);
      expect(find.text('Outer'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );
  testWidgets(
    'restart restores selected branch, history and RestorableProperty values',
    (tester) async {
      late ActivityRouter router;
      await tester.pumpWidget(RestorableApp((value) => router = value));
      await tester.pumpAndSettle();
      await tester.tap(find.text('increment A'));
      await tester.pumpAndSettle();
      router.goNamed('a-details', extra: {'draft': 1});
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tab B'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('increment B'));
      await tester.pumpAndSettle();
      final old = router;
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      expect(identical(old, router), isFalse);
      expect(find.text('B count 1'), findsOneWidget);
      await tester.tap(find.text('Tab A'));
      await tester.pumpAndSettle();
      expect(find.text('A details'), findsOneWidget);
      expect(router.state.extra, {'draft': 1});
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('A count 1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('async guard withholds protected builder then redirects', (
    tester,
  ) async {
    final gate = Completer<String?>();
    var builds = 0;
    final router = ActivityRouter(
      initialLocation: '/',
      routes: [
        ActivityRoute(path: '/', builder: (_, state) => page('Home')),
        ActivityRoute(
          path: '/private',
          redirect: (_) => gate.future,
          builder: (_, state) {
            builds++;
            return page('Secret');
          },
        ),
        ActivityRoute(path: '/login', builder: (_, state) => page('Login')),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
    await tester.pumpAndSettle();
    router.go('/private');
    await tester.pump();
    expect(builds, 0);
    expect(find.text('Home'), findsOneWidget);
    gate.complete('/login');
    await tester.pumpAndSettle();
    expect(find.text('Login'), findsOneWidget);
    expect(builds, 0);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });
  testWidgets('stale async redirect cannot replace a newer navigation', (
    tester,
  ) async {
    final gate = Completer<String?>();
    final router = ActivityRouter(
      routes: [
        ActivityRoute(path: '/', builder: (_, state) => page('Home')),
        ActivityRoute(path: '/slow', builder: (_, state) => page('Slow')),
        ActivityRoute(path: '/latest', builder: (_, state) => page('Latest')),
        ActivityRoute(path: '/login', builder: (_, state) => page('Login')),
      ],
      redirect: (state) => state.uri.path == '/slow' ? gate.future : null,
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
    await tester.pumpAndSettle();
    router.go('/slow');
    await tester.pump();
    router.go('/latest');
    await tester.pumpAndSettle();
    gate.complete('/login');
    await tester.pumpAndSettle();
    expect(find.text('Latest'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });
  testWidgets(
    'guard errors reach errorBuilder and controller refresh rechecks async auth',
    (tester) async {
      final auth = _Auth();
      final router = ActivityRouter(
        refreshController: auth,
        routes: [
          ActivityRoute(path: '/', builder: (_, state) => page('Home')),
          ActivityRoute(
            path: '/private',
            builder: (_, state) => page('Secret'),
          ),
          ActivityRoute(path: '/login', builder: (_, state) => page('Login')),
          ActivityRoute(path: '/broken', builder: (_, state) => page('Broken')),
        ],
        redirect: (state) async {
          if (state.uri.path == '/broken') throw StateError('guard failed');
          return state.uri.path == '/private' && !auth.signedIn.value
              ? '/login'
              : null;
        },
        errorBuilder: (_, state) => page('Error ${state.error}'),
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
      await tester.pumpAndSettle();
      router.go('/private');
      await tester.pumpAndSettle();
      expect(find.text('Secret'), findsOneWidget);
      auth.signedIn.setFalse();
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
      router.go('/broken');
      await tester.pumpAndSettle();
      expect(find.textContaining('guard failed'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      await auth.dispose();
    },
  );
  testWidgets('pending guard errors after disposal are handled', (
    tester,
  ) async {
    final gate = Completer<String?>();
    final router = ActivityRouter(
      routes: [
        ActivityRoute(path: '/', builder: (_, state) => page('Home')),
        ActivityRoute(
          path: '/slow',
          redirect: (_) => gate.future,
          builder: (_, state) => page('Slow'),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
    await tester.pumpAndSettle();
    router.go('/slow');
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    router.dispose();
    gate.completeError(StateError('finished after disposal'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('typed push results and asynchronous onExit can veto back', (
    tester,
  ) async {
    var allowExit = false;
    final router = ActivityRouter(
      routes: [
        ActivityRoute(path: '/', builder: (_, state) => page('Home')),
        ActivityRoute(
          path: '/edit',
          onExit: (_, state) async => allowExit,
          builder: (_, state) => page('Edit'),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
    await tester.pumpAndSettle();
    final result = router.push<int>('/edit');
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    allowExit = true;
    router.pop<int>(42);
    await tester.pumpAndSettle();
    expect(await result, 42);
    expect(find.text('Home'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });
}

class _Auth extends ActiveController {
  final signedIn = ActiveBool(true);
  @override
  Iterable<ActiveType> get activities => [signedIn];
}

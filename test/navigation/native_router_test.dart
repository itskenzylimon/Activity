import 'dart:async';
import 'dart:convert';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget screen(String value) => Scaffold(body: Text(value));
Future<void> mount(WidgetTester tester, ActivityRouter router) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
  await tester.pumpAndSettle();
}

Future<void> close(WidgetTester tester, ActivityRouter router) async {
  await tester.pumpWidget(const SizedBox());
  router.dispose();
}

class CountPage extends StatefulWidget {
  const CountPage({super.key});
  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
  int count = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        Text('count $count / ${context.activityRoute.queryParameters['tab']}'),
        TextButton(
          onPressed: () => setState(() => count++),
          child: const Text('increment'),
        ),
      ],
    ),
  );
}

class Extra {
  const Extra(this.value);
  final int value;
}

class ExtraCodec extends Codec<Object?, Object?> {
  const ExtraCodec();
  @override
  Converter<Object?, Object?> get encoder => _Encoder();
  @override
  Converter<Object?, Object?> get decoder => _Decoder();
}

class _Encoder extends Converter<Object?, Object?> {
  @override
  Object? convert(Object? input) =>
      input == null ? null : {'value': (input as Extra).value};
}

class _Decoder extends Converter<Object?, Object?> {
  @override
  Object? convert(Object? input) =>
      input == null ? null : Extra((input as Map)['value'] as int);
}

void main() {
  test(
    'route definitions reject invalid trees and parent navigator targets',
    () {
      expect(
        () => ActivityRouter(
          routes: [
            ActivityRoute(
              path: 'relative',
              builder: (_, __) => const SizedBox(),
            ),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => ActivityRouter(
          routes: [
            ActivityRoute(
              path: '/:id',
              builder: (_, __) => const SizedBox(),
              routes: [
                ActivityRoute(
                  path: ':id',
                  builder: (_, __) => const SizedBox(),
                ),
              ],
            ),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => ActivityRouter(
          routes: [
            ActivityRoute(
              path: '/',
              parentNavigatorKey: GlobalKey<NavigatorState>(),
              builder: (_, __) => const SizedBox(),
            ),
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => ActivityStatefulShellRoute.indexedStack(
          branches: [],
          builder: (_, __, shell) => shell,
        ),
        throwsArgumentError,
      );
    },
  );

  testWidgets(
    'case-insensitive matching preserves encoded parameters, repeated query and fragments',
    (tester) async {
      final router = ActivityRouter(
        routes: [
          ActivityRoute(
            path: '/items/:id',
            name: 'item',
            caseSensitive: false,
            builder:
                (context, state) => screen(
                  '${context.activityRoute.pathParameters['id']} / ${state.queryParametersAll['tag']!.join(',')} / ${Uri.decodeComponent(state.uri.fragment)}',
                ),
          ),
        ],
      );
      final location = router.namedLocation(
        'item',
        pathParameters: {'id': 'a/b 雪'},
        queryParameters: {
          'tag': ['one', 'two words'],
        },
        fragment: 'part two',
      );
      await mount(tester, router);
      router.go(location.replaceFirst('/items/', '/ITEMS/'));
      await tester.pumpAndSettle();
      expect(find.text('a/b 雪 / one,two words / part two'), findsOneWidget);
      expect(
        () => router.go('https://example.com/private'),
        throwsArgumentError,
      );
      await close(tester, router);
    },
  );

  testWidgets(
    'custom transition pages update scoped query state without resetting widgets',
    (tester) async {
      final router = ActivityRouter(
        initialLocation: '/counter?tab=one',
        routes: [
          ActivityRoute(
            path: '/counter',
            pageBuilder:
                (_, state) => ActivityTransitionPage<void>(
                  key: state.pageKey,
                  restorationId: 'counter',
                  child: const CountPage(),
                  transitionsBuilder:
                      (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                ),
          ),
        ],
      );
      await mount(tester, router);
      await tester.tap(find.text('increment'));
      router.go('/counter?tab=two');
      await tester.pumpAndSettle();
      expect(find.text('count 1 / two'), findsOneWidget);
      await close(tester, router);
    },
  );

  testWidgets(
    'repeated custom page pushes have distinct keys and typed results',
    (tester) async {
      final router = ActivityRouter(
        routes: [
          ActivityRoute(path: '/', builder: (_, __) => screen('home')),
          ActivityRoute(
            path: '/pick',
            pageBuilder:
                (_, state) => ActivityNoTransitionPage<int>(
                  key: state.pageKey,
                  child: screen('pick'),
                ),
          ),
        ],
      );
      await mount(tester, router);
      final first = router.push<int>('/pick');
      await tester.pumpAndSettle();
      final second = router.push<int>('/pick');
      await tester.pumpAndSettle();
      router.pop<int>(2);
      await tester.pumpAndSettle();
      expect(await second, 2);
      router.pop<int>(1);
      await tester.pumpAndSettle();
      expect(await first, 1);
      expect(find.text('home'), findsOneWidget);
      await close(tester, router);
    },
  );

  testWidgets(
    'tab switching retains a pending push result until the detail is popped',
    (tester) async {
      late ActivityNavigationShell tabs;
      final router = ActivityRouter(
        initialLocation: '/a',
        routes: [
          ActivityStatefulShellRoute.indexedStack(
            branches: [
              ActivityShellBranch(
                routes: [
                  ActivityRoute(
                    path: '/a',
                    builder: (_, __) => screen('A'),
                    routes: [
                      ActivityRoute(
                        path: 'detail',
                        builder: (_, __) => screen('detail'),
                      ),
                    ],
                  ),
                ],
              ),
              ActivityShellBranch(
                routes: [
                  ActivityRoute(path: '/b', builder: (_, __) => screen('B')),
                ],
              ),
            ],
            builder: (_, __, shell) {
              tabs = shell;
              return shell;
            },
          ),
        ],
      );
      await mount(tester, router);
      var complete = false;
      final result = router.push<int>('/a/detail')
        ..then((_) => complete = true);
      await tester.pumpAndSettle();
      tabs.goBranch(1);
      await tester.pumpAndSettle();
      expect(complete, isFalse);
      tabs.goBranch(0);
      await tester.pumpAndSettle();
      expect(find.text('detail'), findsOneWidget);
      router.pop<int>(7);
      await tester.pumpAndSettle();
      expect(await result, 7);
      expect(() => tabs.goBranch(2), throwsRangeError);
      await close(tester, router);
    },
  );

  testWidgets(
    'system back closes a dialog before removing its owning detail page',
    (tester) async {
      final router = ActivityRouter(
        routes: [
          ActivityRoute(path: '/', builder: (_, __) => screen('home')),
          ActivityRoute(
            path: '/detail',
            builder:
                (context, _) => Scaffold(
                  body: TextButton(
                    onPressed:
                        () => showDialog<void>(
                          context: context,
                          builder:
                              (_) => const AlertDialog(title: Text('dialog')),
                        ),
                    child: const Text('open dialog'),
                  ),
                ),
          ),
        ],
      );
      await mount(tester, router);
      router.push<void>('/detail');
      await tester.pumpAndSettle();
      await tester.tap(find.text('open dialog'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('dialog'), findsNothing);
      expect(find.text('open dialog'), findsOneWidget);
      expect(router.state.uri.path, '/detail');
      await close(tester, router);
    },
  );

  testWidgets(
    'parser round-trip preserves a custom extra codec and rejects forged state',
    (tester) async {
      final router = ActivityRouter(
        extraCodec: const ExtraCodec(),
        routes: [
          ActivityRoute(
            path: '/',
            builder:
                (_, state) => screen('extra ${(state.extra as Extra?)?.value}'),
          ),
        ],
      );
      await mount(tester, router);
      router.go('/', extra: const Extra(42));
      await tester.pumpAndSettle();
      final info = router.routeInformationParser.restoreRouteInformation(
        router.routerDelegate.currentConfiguration!,
      );
      final restored = await router.routeInformationParser
          .parseRouteInformation(info);
      await router.routerDelegate.setNewRoutePath(restored);
      await tester.pumpAndSettle();
      expect((router.state.extra as Extra).value, 42);
      final fallback = await router.routeInformationParser
          .parseRouteInformation(
            RouteInformation(
              uri: Uri(path: '/'),
              state: {'activityRouter': 1, 'stack': 'invalid'},
            ),
          );
      await router.routerDelegate.setNewRoutePath(fallback);
      await tester.pumpAndSettle();
      expect(router.state.extra, isNull);
      await close(tester, router);
    },
  );

  testWidgets(
    'disposal completes outstanding page results and rejects new operations',
    (tester) async {
      final router = ActivityRouter(
        routes: [
          ActivityRoute(path: '/', builder: (_, __) => screen('home')),
          ActivityRoute(path: '/pick', builder: (_, __) => screen('pick')),
        ],
      );
      await mount(tester, router);
      final result = router.push<int>('/pick');
      await tester.pumpAndSettle();
      await close(tester, router);
      expect(await result, isNull);
      expect(() => router.go('/'), throwsStateError);
      router.dispose();
    },
  );
  testWidgets('reactive refresh rechecks the newest pending destination', (
    tester,
  ) async {
    final session = _Session();
    final gate = Completer<void>();
    final router = ActivityRouter(
      initialLocation: '/login',
      refreshController: session,
      routes: [
        ActivityRoute(path: '/login', builder: (_, __) => screen('login')),
        ActivityRoute(
          path: '/account',
          redirect: (_) async {
            await gate.future;
            return session.allowed.value ? null : '/login';
          },
          builder: (_, __) => screen('account'),
        ),
      ],
    );
    await mount(tester, router);
    session.allowed.setTrue();
    router.go('/account');
    await tester.pump();
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.text('account'), findsOneWidget);
    await close(tester, router);
    await session.dispose();
  });

  testWidgets('disposing during a pending push guard completes its result', (
    tester,
  ) async {
    final gate = Completer<String?>();
    final router = ActivityRouter(
      routes: [
        ActivityRoute(path: '/', builder: (_, __) => screen('home')),
        ActivityRoute(
          path: '/slow',
          redirect: (_) => gate.future,
          builder: (_, __) => screen('slow'),
        ),
      ],
    );
    await mount(tester, router);
    final result = router.push<int>('/slow');
    await tester.pump();
    await close(tester, router);
    expect(await result, isNull);
    gate.completeError(StateError('late guard failure'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('serialized repeated custom pushes restore distinct page keys', (
    tester,
  ) async {
    final router = ActivityRouter(
      routes: [
        ActivityRoute(path: '/', builder: (_, __) => screen('home')),
        ActivityRoute(
          path: '/pick',
          pageBuilder:
              (_, state) => ActivityNoTransitionPage<int>(
                key: state.pageKey,
                child: screen('pick'),
              ),
        ),
      ],
    );
    await mount(tester, router);
    router.push<int>('/pick');
    await tester.pumpAndSettle();
    router.push<int>('/pick');
    await tester.pumpAndSettle();
    final info = router.routeInformationParser.restoreRouteInformation(
      router.routerDelegate.currentConfiguration!,
    );
    final restored = await router.routeInformationParser.parseRouteInformation(
      info,
    );
    await router.routerDelegate.setNewRoutePath(restored);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final result = router.push<int>('/pick');
    await tester.pumpAndSettle();
    router.pop<int>(3);
    await tester.pumpAndSettle();
    expect(await result, 3);
    await close(tester, router);
  });

  testWidgets('system back closes local drawer history at the root', (
    tester,
  ) async {
    final router = ActivityRouter(
      routes: [
        ActivityRoute(
          path: '/',
          builder:
              (context, _) => Scaffold(
                appBar: AppBar(title: const Text('home')),
                drawer: const Drawer(child: Text('drawer contents')),
              ),
        ),
      ],
    );
    await mount(tester, router);
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('drawer contents'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('drawer contents'), findsNothing);
    expect(router.state.uri.path, '/');
    await close(tester, router);
  });
}

class _Session extends ActiveController {
  final allowed = ActiveBool(false);
  @override
  Iterable<ActiveType> get activities => [allowed];
}

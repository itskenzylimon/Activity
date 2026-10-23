import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class Auth extends ActiveController {
  final signedIn = ActiveBool(false);
  @override
  Iterable<ActiveType> get activities => [signedIn];
}

List<ActivityRoute> routes() => [
  ActivityRoute(
    path: '/',
    name: 'home',
    builder: (_, state) => const Scaffold(body: Text('Home')),
  ),
  ActivityRoute(
    path: '/users/:id',
    name: 'user',
    builder:
        (_, state) => Scaffold(
          body: Text(
            'User ${state.pathParameters['id']} ${state.queryParameters['tab']}',
          ),
        ),
  ),
  ActivityRoute(
    path: '/login',
    builder: (_, state) => const Scaffold(body: Text('Login')),
  ),
];
void main() {
  test(
    'named locations encode path and query values and reject missing params',
    () {
      final router = ActivityRouter(routes: routes());
      final uri = Uri.parse(
        router.namedLocation(
          'user',
          pathParameters: {'id': 'a/b'},
          queryParameters: {'tab': 'a b'},
        ),
      );
      expect(uri.pathSegments, ['users', 'a/b']);
      expect(uri.queryParameters['tab'], 'a b');
      expect(() => router.namedLocation('user'), throwsArgumentError);
      expect(() => router.namedLocation('unknown'), throwsArgumentError);
      router.dispose();
    },
  );
  testWidgets('redirect cycles reach errorBuilder instead of hanging', (
    tester,
  ) async {
    final router = ActivityRouter(
      routes: [
        ...routes(),
        ActivityRoute(path: '/a', builder: (_, state) => const SizedBox()),
        ActivityRoute(path: '/b', builder: (_, state) => const SizedBox()),
      ],
      redirect:
          (state) =>
              state.uri.path == '/a'
                  ? '/b'
                  : state.uri.path == '/b'
                  ? '/a'
                  : null,
      errorBuilder: (_, state) => Scaffold(body: Text('error: ${state.error}')),
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
    await tester.pumpAndSettle();
    router.go('/a');
    await tester.pumpAndSettle();
    expect(find.textContaining('redirect loop'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    router.dispose();
  });
  testWidgets(
    'URL parsing, back, replacement, unknown pages and activity refresh',
    (tester) async {
      final auth = Auth();
      final router = ActivityRouter(
        routes: routes(),
        refreshController: auth,
        redirect:
            (state) =>
                state.uri.path.startsWith('/users') && !auth.signedIn.value
                    ? '/login'
                    : null,
      );
      await tester.pumpWidget(MaterialApp.router(routerConfig: router.config));
      await tester.pumpAndSettle();
      router.go('/users/1');
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
      auth.signedIn.setTrue();
      await tester.pump();
      router.goNamed(
        'user',
        pathParameters: {'id': '42'},
        queryParameters: {'tab': 'posts'},
      );
      await tester.pumpAndSettle();
      expect(find.text('User 42 posts'), findsOneWidget);
      router.push('/');
      await tester.pumpAndSettle();
      expect(router.canPop, isTrue);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('User 42 posts'), findsOneWidget);
      router.replace('/');
      await tester.pumpAndSettle();
      expect(router.canPop, isFalse);
      await router.setNewRoutePath(Uri.parse('/users/7?tab=likes'));
      await tester.pumpAndSettle();
      expect(find.text('User 7 likes'), findsOneWidget);
      auth.signedIn.setFalse();
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
      router.go('/missing');
      await tester.pumpAndSettle();
      expect(find.text('Page not found: /missing'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      router.dispose();
      await auth.dispose();
    },
  );
  testWidgets('imperative navigation returns results and offAll clears stack', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: Text('root'));
          },
        ),
      ),
    );
    final result = Nav.to<int>(
      context,
      () => const Scaffold(body: Text('detail')),
    );
    await tester.pumpAndSettle();
    Nav.off<int>(tester.element(find.text('detail')), 42);
    await tester.pumpAndSettle();
    expect(await result, 42);
    Nav.to<void>(context, () => const Scaffold(body: Text('middle')));
    await tester.pumpAndSettle();
    Nav.offAll<void>(
      tester.element(find.text('middle')),
      () => const Scaffold(body: Text('only')),
    );
    await tester.pumpAndSettle();
    expect(Navigator.canPop(tester.element(find.text('only'))), isFalse);
  });
  testWidgets('pushUntil retains actual route matching a predicate', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: Text('root'));
          },
        ),
      ),
    );
    Nav.to<void>(context, () => const Scaffold(body: Text('middle')));
    await tester.pumpAndSettle();
    Nav.pushUntil<void>(
      tester.element(find.text('middle')),
      () => const Scaffold(body: Text('top')),
      (r) => r.isFirst,
    );
    await tester.pumpAndSettle();
    Nav.off(tester.element(find.text('top')));
    await tester.pumpAndSettle();
    expect(find.text('root'), findsOneWidget);
    expect(find.text('middle'), findsNothing);
  });
}

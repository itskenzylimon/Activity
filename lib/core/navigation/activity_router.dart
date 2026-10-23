import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../src/controller.dart';

/// Return null to allow a location or an absolute app path to redirect.
/// Both global and route guards run before destination builders.
typedef ActivityRedirect = FutureOr<String?> Function(ActivityRouteState state);

/// Immutable location supplied to builders, guards and error pages.
class ActivityRouteState {
  final Uri uri;
  final Map<String, String> pathParameters;
  final Object? extra;
  final String? name;
  final String? fullPath;
  final ValueKey<String> pageKey;
  final Exception? error;
  ActivityRouteState(
    this.uri, {
    Map<String, String> pathParameters = const {},
    this.extra,
    this.name,
    this.fullPath,
    ValueKey<String>? pageKey,
    this.error,
  }) : pathParameters = Map.unmodifiable(pathParameters),
       pageKey = pageKey ?? ValueKey(uri.toString());
  static ActivityRouteState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_RouteScope>();
    if (scope == null) return ActivityRouter.of(context).state;
    return scope.state;
  }

  Map<String, String> get queryParameters => uri.queryParameters;
  Map<String, List<String>> get queryParametersAll => uri.queryParametersAll;
}

/// Base for Activity pages and persistent navigator layouts.
abstract class ActivityRouteBase {
  ActivityRouteBase({
    required List<ActivityRouteBase> routes,
    this.redirect,
    this.parentNavigatorKey,
  }) : routes = List.unmodifiable(routes);
  final List<ActivityRouteBase> routes;
  final ActivityRedirect? redirect;
  final GlobalKey<NavigatorState>? parentNavigatorKey;
}

/// Named page with relative children, an optional guard and a custom Page.
/// Use `:id` segments for parameters; top-level paths start with `/`.
class ActivityRoute extends ActivityRouteBase {
  ActivityRoute({
    required this.path,
    this.name,
    this.builder,
    this.pageBuilder,
    super.redirect,
    List<ActivityRouteBase> routes = const [],
    super.parentNavigatorKey,
    this.onExit,
    this.caseSensitive = true,
  }) : super(routes: routes) {
    if (builder == null && pageBuilder == null && redirect == null) {
      throw ArgumentError('A route needs a builder, pageBuilder or redirect');
    }
  }
  final String path;
  final String? name;
  final Widget Function(BuildContext, ActivityRouteState)? builder;
  final Page<dynamic> Function(BuildContext, ActivityRouteState)? pageBuilder;
  final FutureOr<bool> Function(BuildContext, ActivityRouteState)? onExit;
  final bool caseSensitive;
}

/// Shared layout with its own Navigator; root-targeted children appear above it.
class ActivityShellRoute extends ActivityRouteBase {
  ActivityShellRoute({
    required this.builder,
    required super.routes,
    GlobalKey<NavigatorState>? navigatorKey,
    super.parentNavigatorKey,
    this.restorationScopeId,
    this.observers = const [],
    super.redirect,
  }) : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>();
  final Widget Function(BuildContext, ActivityRouteState, Widget) builder;
  final GlobalKey<NavigatorState> navigatorKey;
  final String? restorationScopeId;
  final List<NavigatorObserver> observers;
}

/// A tab's route tree, navigator key, initial URL and restoration namespace.
class ActivityShellBranch {
  ActivityShellBranch({
    required List<ActivityRouteBase> routes,
    GlobalKey<NavigatorState>? navigatorKey,
    this.initialLocation,
    this.restorationScopeId,
    this.observers = const [],
  }) : routes = List.unmodifiable(routes),
       navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>() {
    if (routes.isEmpty) throw ArgumentError('A shell branch needs routes');
  }
  final List<ActivityRouteBase> routes;
  final GlobalKey<NavigatorState> navigatorKey;
  final String? initialLocation;
  final String? restorationScopeId;
  final List<NavigatorObserver> observers;
}

/// IndexedStack tabs retain their own pages, widget state and push results.
class ActivityStatefulShellRoute extends ActivityRouteBase {
  ActivityStatefulShellRoute.indexedStack({
    required List<ActivityShellBranch> branches,
    required this.builder,
    this.restorationScopeId,
    super.parentNavigatorKey,
    super.redirect,
  }) : branches = List.unmodifiable(branches),
       super(routes: [for (final branch in branches) ...branch.routes]) {
    if (branches.isEmpty) {
      throw ArgumentError('A stateful shell needs branches');
    }
  }
  final List<ActivityShellBranch> branches;
  final String? restorationScopeId;
  final Widget Function(
    BuildContext,
    ActivityRouteState,
    ActivityNavigationShell,
  )
  builder;
}

/// Legacy spelling retained for Activity 2.0 development checkouts.
@Deprecated('Use ActivityShellBranch')
typedef StatefulShellBranch = ActivityShellBranch;

/// Legacy spelling retained for route-list declarations.
@Deprecated('Use ActivityRouteBase')
typedef RouteBase = ActivityRouteBase;

/// Shell child and tab controller supplied to the stateful layout builder.
class ActivityNavigationShell extends StatelessWidget {
  const ActivityNavigationShell._({
    required this.currentIndex,
    required this.children,
    required this.onBranch,
  });
  final int currentIndex;
  final List<Widget> children;
  final void Function(int, bool) onBranch;
  void goBranch(int index, {bool initialLocation = false}) {
    RangeError.checkValidIndex(index, children);
    onBranch(index, initialLocation);
  }

  @override
  Widget build(BuildContext context) =>
      IndexedStack(index: currentIndex, children: children);
}

/// A page without animated transitions, useful for top-level tabs.
class ActivityNoTransitionPage<T> extends Page<T> {
  const ActivityNoTransitionPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });
  final Widget child;
  @override
  Route<T> createRoute(BuildContext context) => PageRouteBuilder<T>(
    settings: this,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) => child,
  );
}

/// A declarative page with Flutter animation control.
class ActivityTransitionPage<T> extends Page<T> {
  const ActivityTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.reverseTransitionDuration = const Duration(milliseconds: 300),
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });
  final Widget child;
  final RouteTransitionsBuilder transitionsBuilder;
  final Duration transitionDuration, reverseTransitionDuration;
  @override
  Route<T> createRoute(BuildContext context) => PageRouteBuilder<T>(
    settings: this,
    transitionDuration: transitionDuration,
    reverseTransitionDuration: reverseTransitionDuration,
    pageBuilder: (_, __, ___) => child,
    transitionsBuilder: transitionsBuilder,
  );
}

/// Error supplied to the error builder when matching, guards or codecs fail.
class ActivityNavigationException implements Exception {
  const ActivityNavigationException(this.message);
  final String message;
  @override
  String toString() => 'ActivityNavigationException: $message';
}

class _ScopeSelection {
  const _ScopeSelection(this.route, this.branch);
  final ActivityRouteBase route;
  final int? branch;
}

class _RouteEntry {
  _RouteEntry(this.route, this.state, this.scopes, this.key, {this.completer});
  final ActivityRoute? route;
  ActivityRouteState state;
  final List<_ScopeSelection> scopes;
  final String key;
  final Completer<Object?>? completer;
  final GlobalKey contextKey = GlobalKey();
}

/// Immutable Router configuration. Its serializable state includes visited tabs.
/// Use [ActivityRouter.config] for MaterialApp; the parser and delegate are also
/// exposed for apps that assemble Flutter's Router widget directly.
class ActivityRouteConfiguration {
  ActivityRouteConfiguration._(this._entries, this._branches);
  final List<_RouteEntry> _entries;
  final Map<ActivityStatefulShellRoute, Map<int, List<_RouteEntry>>> _branches;
  Uri get uri => _entries.isEmpty ? Uri(path: '/') : _entries.last.state.uri;
}

class _RouterScope extends InheritedWidget {
  const _RouterScope(this.router, {required super.child});
  final ActivityRouter router;
  @override
  bool updateShouldNotify(_RouterScope oldWidget) => router != oldWidget.router;
}

class _RouteScope extends InheritedWidget {
  const _RouteScope(this.state, {required super.child});
  final ActivityRouteState state;
  @override
  bool updateShouldNotify(_RouteScope oldWidget) => state != oldWidget.state;
}

/// URL routing implemented with Flutter Router and declarative Navigators.
///
/// Use MaterialApp.router with router.config. The gallery demonstrates nested/shell/restorable routes, async guards and unknown-route recovery. Client guards are not server authorization. Pushes update browser URLs and preserve typed results.
///
/// [Gallery walkthrough](https://github.com/itskenzylimon/Activity/blob/main/example/README.md#navigation) · browser route `/#/navigation`.
/// These examples use the current checkout; published 1.x APIs can differ.
///
/// ### Named parameters and query values
///
/// <!-- activity-snippet: class-activityrouter-extends-1 -->
/// ```dart
/// import 'package:activity/activity.dart';
/// import 'package:flutter/material.dart';
///
/// void main() => runApp(const RouteOwner());
///
/// class RouteOwner extends StatefulWidget {
///   const RouteOwner({super.key});
///   @override
///   State<RouteOwner> createState() => _RouteOwnerState();
/// }
///
/// class _RouteOwnerState extends State<RouteOwner> {
///   late final router = ActivityRouter(
///     routes: [
///       ActivityRoute(
///         path: '/',
///         builder:
///             (context, state) => Scaffold(
///               body: TextButton(
///                 onPressed:
///                     () => ActivityRouter.of(context).goNamed(
///                       'detail',
///                       pathParameters: {'id': '42'},
///                       queryParameters: {'tab': 'summary'},
///                     ),
///                 child: const Text('Open detail'),
///               ),
///             ),
///       ),
///       ActivityRoute(
///         path: '/detail/:id',
///         name: 'detail',
///         builder:
///             (_, state) => Scaffold(
///               body: Text(
///                 '${state.pathParameters['id']} / ${state.queryParameters['tab']}',
///               ),
///             ),
///       ),
///     ],
///   );
///   @override
///   void dispose() {
///     router.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) =>
///       MaterialApp.router(routerConfig: router.config);
/// }
/// ```
///
/// ### Return a typed detail result
///
/// <!-- activity-snippet: class-activityrouter-extends-2 -->
/// ```dart
/// import 'package:activity/activity.dart';
/// import 'package:flutter/material.dart';
///
/// void main() => runApp(const RouteOwner());
///
/// class RouteOwner extends StatefulWidget {
///   const RouteOwner({super.key});
///   @override
///   State<RouteOwner> createState() => _RouteOwnerState();
/// }
///
/// class _RouteOwnerState extends State<RouteOwner> {
///   late final router = ActivityRouter(
///     routes: [
///       ActivityRoute(
///         path: '/',
///         builder:
///             (context, state) => Scaffold(
///               body: TextButton(
///                 onPressed: () async {
///                   final selected = await ActivityRouter.of(
///                     context,
///                   ).pushNamed<int>('pick');
///                   if (context.mounted && selected != null)
///                     ScaffoldMessenger.of(context).showSnackBar(
///                       SnackBar(content: Text('Selected $selected')),
///                     );
///                 },
///                 child: const Text('Choose'),
///               ),
///             ),
///       ),
///       ActivityRoute(
///         path: '/pick',
///         name: 'pick',
///         builder:
///             (context, state) => Scaffold(
///               body: TextButton(
///                 onPressed: () => ActivityRouter.of(context).pop<int>(42),
///                 child: const Text('Return 42'),
///               ),
///             ),
///       ),
///     ],
///   );
///   @override
///   void dispose() {
///     router.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) =>
///       MaterialApp.router(routerConfig: router.config);
/// }
/// ```
class ActivityRouter extends ChangeNotifier {
  ActivityRouter({
    required List<ActivityRouteBase> routes,
    String initialLocation = '/',
    this.redirect,
    this.errorBuilder,
    this.redirectLimit = 8,
    ActiveController? refreshController,
    this.restorationScopeId,
    GlobalKey<NavigatorState>? navigatorKey,
    this.extraCodec,
    this.observers = const [],
    bool overridePlatformDefaultLocation = false,
    this.debugLogDiagnostics = false,
  }) : routes = List.unmodifiable(routes),
       navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
       _controller = refreshController {
    if (redirectLimit < 1) {
      throw ArgumentError.value(redirectLimit, 'redirectLimit');
    }
    _collect(this.routes, '', [this.navigatorKey]);
    final platform =
        WidgetsBinding.instance.platformDispatcher.defaultRouteName;
    final location =
        !overridePlatformDefaultLocation && platform != '/'
            ? platform
            : initialLocation;
    _initialUri = _parseUri(location);
    routeInformationProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(uri: _initialUri),
    );
    routerDelegate = ActivityRouterDelegate._(this);
    routeInformationParser = ActivityRouteInformationParser._(this);
    config = RouterConfig<ActivityRouteConfiguration>(
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
      routeInformationProvider: routeInformationProvider,
      backButtonDispatcher: RootBackButtonDispatcher(),
    );
    _subscription = _controller?.addOnStateChangedListener((_) => refresh());
  }
  static ActivityRouter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_RouterScope>();
    if (scope == null) throw StateError('No ActivityRouter found in context');
    return scope.router;
  }

  final List<ActivityRouteBase> routes;
  final ActivityRedirect? redirect;
  final Widget Function(BuildContext, ActivityRouteState)? errorBuilder;
  final int redirectLimit;
  final String? restorationScopeId;
  final GlobalKey<NavigatorState> navigatorKey;
  final Codec<Object?, Object?>? extraCodec;
  final List<NavigatorObserver> observers;
  final bool debugLogDiagnostics;
  late final RouterConfig<ActivityRouteConfiguration> config;
  late final ActivityRouterDelegate routerDelegate;
  late final ActivityRouteInformationParser routeInformationParser;
  late final PlatformRouteInformationProvider routeInformationProvider;
  late final Uri _initialUri;
  final ActiveController? _controller;
  StreamSubscription? _subscription;
  final Map<String, String> _namedPaths = {};
  final Map<ActivityRouteBase, String> _routeIds = {};
  final Map<ActivityRouteBase, String> _fullPaths = {};
  List<_RouteEntry> _entries = [];
  Map<ActivityStatefulShellRoute, Map<int, List<_RouteEntry>>> _branches = {};
  final Map<GlobalKey<NavigatorState>, _NavigationObserver>
  _navigationObservers = {};
  bool _disposed = false;
  Uri? _requestedUri;
  Object? _requestedExtra;
  final Set<Completer<Object?>> _pendingPushes = {};
  int _revision = 0, _nextKey = 0;
  ActivityRouteState get state =>
      _entries.isEmpty ? ActivityRouteState(_initialUri) : _entries.last.state;
  Uri get currentConfiguration => state.uri;
  bool get canPop => _entries.length > 1;

  void _collect(
    List<ActivityRouteBase> entries,
    String parent,
    List<GlobalKey<NavigatorState>> ancestors,
  ) {
    for (final route in entries) {
      if (_routeIds.containsKey(route)) {
        throw ArgumentError('Route objects cannot be reused');
      }
      _routeIds[route] = 'route_${_routeIds.length}';
      final target = route.parentNavigatorKey;
      if (target != null && !ancestors.contains(target)) {
        throw ArgumentError(
          'parentNavigatorKey must belong to an ancestor Navigator',
        );
      }
      var path = parent;
      if (route is ActivityRoute) {
        if (route.path.isEmpty ||
            (parent.isEmpty && !route.path.startsWith('/')) ||
            (parent.isNotEmpty && route.path.startsWith('/')) ||
            route.path.contains('?') ||
            route.path.contains('#')) {
          throw ArgumentError(
            'Use absolute top-level and relative child paths: ${route.path}',
          );
        }
        path = '${parent == '/' ? '' : parent}/${route.path}'.replaceAll(
          RegExp('/+'),
          '/',
        );
        _routeIds[route] = 'page:${route.name ?? path}';
        _fullPaths[route] = path;
        final parameters =
            RegExp(r':(\w+)').allMatches(path).map((m) => m[1]).toList();
        if (parameters.toSet().length != parameters.length) {
          throw ArgumentError('Duplicate path parameter in $path');
        }
        if (route.name != null) {
          if (_namedPaths.containsKey(route.name)) {
            throw ArgumentError('Duplicate route name: ${route.name}');
          }
          _namedPaths[route.name!] = path;
        }
      }
      if (route is ActivityShellRoute && route.restorationScopeId != null) {
        _routeIds[route] = 'shell:${route.restorationScopeId}';
      }
      if (route is ActivityStatefulShellRoute &&
          route.restorationScopeId != null) {
        _routeIds[route] = 'tabs:${route.restorationScopeId}';
      }
      if (route is ActivityStatefulShellRoute) {
        for (final branch in route.branches) {
          _collect(branch.routes, path, [...ancestors, branch.navigatorKey]);
        }
      } else {
        _collect(route.routes, path, [
          ...ancestors,
          if (route is ActivityShellRoute) route.navigatorKey,
        ]);
      }
    }
  }

  Uri _parseUri(String location) {
    final uri = Uri.parse(location);
    if (!uri.path.startsWith('/') || uri.hasScheme || uri.hasAuthority) {
      throw ArgumentError.value(
        location,
        'location',
        'Use an absolute local path',
      );
    }
    return uri;
  }

  List<_RouteEntry>? _match(Uri uri, Object? extra) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    List<_RouteEntry>? visit(
      List<ActivityRouteBase> entries,
      int offset,
      Map<String, String> parameters,
      List<_ScopeSelection> scopes,
    ) {
      for (final route in entries) {
        var effectiveScopes = scopes;
        final target = route.parentNavigatorKey;
        if (target != null) {
          if (target == navigatorKey) {
            effectiveScopes = [];
          } else {
            final depth = scopes.indexWhere((s) => _navigatorFor(s) == target);
            if (depth >= 0) effectiveScopes = scopes.take(depth + 1).toList();
          }
        }
        if (route is ActivityShellRoute) {
          final result = visit(route.routes, offset, parameters, [
            ...effectiveScopes,
            _ScopeSelection(route, null),
          ]);
          if (result != null) return result;
        } else if (route is ActivityStatefulShellRoute) {
          for (var i = 0; i < route.branches.length; i++) {
            final result = visit(route.branches[i].routes, offset, parameters, [
              ...effectiveScopes,
              _ScopeSelection(route, i),
            ]);
            if (result != null) return result;
          }
        } else if (route is ActivityRoute) {
          final pattern =
              route.path.split('/').where((s) => s.isNotEmpty).toList();
          if (offset + pattern.length > segments.length) continue;
          final params = Map<String, String>.of(parameters);
          var matches = true;
          for (var i = 0; i < pattern.length; i++) {
            final token = pattern[i], value = segments[offset + i];
            if (token.startsWith(':')) {
              params[token.substring(1)] = value;
            } else if (route.caseSensitive
                ? token != value
                : token.toLowerCase() != value.toLowerCase()) {
              matches = false;
              break;
            }
          }
          if (!matches) continue;
          final end = offset + pattern.length;
          final prefix =
              '/${segments.take(end).map(Uri.encodeComponent).join('/')}';
          final location = uri.replace(path: prefix);
          final key = _routeIds[route]!;
          final state = ActivityRouteState(
            location,
            pathParameters: params,
            extra: extra,
            fullPath: _fullPaths[route],
            name: route.name,
            pageKey: ValueKey(key),
          );
          final entry = _RouteEntry(route, state, effectiveScopes, key);
          if (end == segments.length) return [entry];
          final children = visit(route.routes, end, params, effectiveScopes);
          if (children != null) return [entry, ...children];
        }
      }
      return null;
    }

    return visit(routes, 0, {}, []);
  }

  GlobalKey<NavigatorState> _navigatorFor(_ScopeSelection scope) {
    final route = scope.route;
    return route is ActivityShellRoute
        ? route.navigatorKey
        : (route as ActivityStatefulShellRoute)
            .branches[scope.branch!]
            .navigatorKey;
  }

  Future<List<_RouteEntry>> _resolve(Uri uri, Object? extra) async {
    final visited = <String>{};
    try {
      for (var attempt = 0; attempt <= redirectLimit; attempt++) {
        if (!visited.add(uri.toString())) {
          throw const ActivityNavigationException('redirect loop detected');
        }
        final matched = _match(uri, extra);
        final target =
            matched?.last.state ?? ActivityRouteState(uri, extra: extra);
        String? destination = await redirect?.call(target);
        if (destination == null && matched != null) {
          final checked = <ActivityRouteBase>{};
          for (final entry in matched) {
            for (final route in [
              ...entry.scopes.map((s) => s.route),
              entry.route!,
            ]) {
              if (checked.add(route)) {
                destination = await route.redirect?.call(target);
              }
              if (destination != null) break;
            }
            if (destination != null) break;
          }
        }
        if (destination != null) {
          uri = _parseUri(destination);
          continue;
        }
        if (matched == null) {
          throw ActivityNavigationException('Page not found: ${uri.path}');
        }
        return matched;
      }
      throw const ActivityNavigationException('redirect limit exceeded');
    } catch (error) {
      final exception =
          error is Exception
              ? error
              : ActivityNavigationException(error.toString());
      final state = ActivityRouteState(uri, extra: extra, error: exception);
      return [_RouteEntry(null, state, [], 'error:$uri')];
    }
  }

  void _ensureOpen() {
    if (_disposed) throw StateError('ActivityRouter is disposed');
  }

  void _saveBranches() {
    for (final entry in _entries) {
      for (final scope in entry.scopes) {
        if (scope.route is ActivityStatefulShellRoute) {
          final route = scope.route as ActivityStatefulShellRoute;
          (_branches[route] ??= {})[scope.branch!] =
              _entries
                  .where(
                    (e) => e.scopes.any(
                      (s) => s.route == route && s.branch == scope.branch,
                    ),
                  )
                  .toList();
        }
      }
    }
  }

  Future<bool> _allowExit(List<_RouteEntry> next) async {
    for (final entry in _entries.reversed) {
      if (next.any((e) => e.key == entry.key)) continue;
      final onExit = entry.route?.onExit,
          context = entry.contextKey.currentContext;
      if (onExit != null &&
          context != null &&
          !await onExit(context, entry.state)) {
        return false;
      }
      if (_disposed) return false;
    }
    return true;
  }

  void _install(
    List<_RouteEntry> next, {
    Object? result,
    bool completeRemoved = true,
  }) {
    _saveBranches();
    if (completeRemoved) {
      for (final entry in _entries) {
        if (!next.contains(entry) &&
            !next.any((e) => e.key == entry.key) &&
            !entry.scopes.any(
              (scope) =>
                  scope.route is ActivityStatefulShellRoute &&
                  next.any(
                    (candidate) => candidate.scopes.any(
                      (s) => s.route == scope.route && s.branch != scope.branch,
                    ),
                  ),
            )) {
          final completer = entry.completer;
          if (completer != null && !completer.isCompleted) {
            completer.complete(result);
          }
        }
      }
    }
    // Page identity owns the subtree; new query/extra values update its state
    // without replacing the Builder key and destroying RestorableProperties.
    _entries = [for (final entry in next) _reuse(entry)];
    _saveBranches();
    _requestedUri = state.uri;
    _requestedExtra = state.extra;
    if (debugLogDiagnostics && kDebugMode) {
      debugPrint('Activity navigation: ${state.fullPath ?? 'unmatched route'}');
    }
    routerDelegate._changed();
    notifyListeners();
  }

  _RouteEntry _reuse(_RouteEntry entry) {
    final previous =
        <_RouteEntry>[
          ..._entries,
          for (final branches in _branches.values)
            for (final saved in branches.values) ...saved,
        ].where((e) => e.key == entry.key).firstOrNull;
    if (previous == null) return entry;
    previous.state = entry.state;
    return previous;
  }

  Future<void> _navigate(
    String location, {
    Object? extra,
    String mode = 'go',
    Completer<Object?>? completer,
  }) async {
    final revision = ++_revision;
    _requestedUri = _parseUri(location);
    _requestedExtra = extra;
    final resolved = await _resolve(_requestedUri!, extra);
    if (_disposed || revision != _revision) {
      if (completer != null && !completer.isCompleted) completer.complete(null);
      return;
    }
    var next = resolved;
    if (mode != 'go') {
      final base = List<_RouteEntry>.of(_entries);
      if (mode == 'replace' && base.isNotEmpty) base.removeLast();
      final leaf = resolved.last;
      final pushedKey = '${leaf.key}:push${_nextKey++}';
      final pushedState = ActivityRouteState(
        leaf.state.uri,
        pathParameters: leaf.state.pathParameters,
        extra: leaf.state.extra,
        name: leaf.state.name,
        fullPath: leaf.state.fullPath,
        pageKey: ValueKey(pushedKey),
        error: leaf.state.error,
      );
      final pushed = _RouteEntry(
        leaf.route,
        pushedState,
        leaf.scopes,
        pushedKey,
        completer: completer,
      );
      next = [
        ...base,
        ...resolved
            .take(resolved.length - 1)
            .where((r) => !base.any((b) => b.key == r.key)),
        pushed,
      ];
    }
    try {
      if (!await _allowExit(next) || _disposed || revision != _revision) {
        if (completer != null && !completer.isCompleted) {
          completer.complete(null);
        }
        return;
      }
      _install(next);
    } catch (error) {
      if (!_disposed && revision == _revision) {
        final state = ActivityRouteState(
          _parseUri(location),
          error: ActivityNavigationException('Exit guard failed: $error'),
        );
        _install([_RouteEntry(null, state, [], 'exit-error:$location')]);
      }
      if (completer != null && !completer.isCompleted) completer.complete(null);
    }
  }

  void go(String location, {Object? extra}) {
    _ensureOpen();
    _parseUri(location);
    unawaited(_navigate(location, extra: extra));
  }

  Future<T?> push<T extends Object?>(String location, {Object? extra}) {
    _ensureOpen();
    _parseUri(location);
    final completer = Completer<Object?>();
    _pendingPushes.add(completer);
    unawaited(completer.future.then((_) => _pendingPushes.remove(completer)));
    unawaited(
      _navigate(location, extra: extra, mode: 'push', completer: completer),
    );
    return completer.future.then((value) => value as T?);
  }

  Future<T?> replace<T extends Object?>(String location, {Object? extra}) {
    _ensureOpen();
    _parseUri(location);
    final completer = Completer<Object?>();
    _pendingPushes.add(completer);
    unawaited(completer.future.then((_) => _pendingPushes.remove(completer)));
    unawaited(
      _navigate(location, extra: extra, mode: 'replace', completer: completer),
    );
    return completer.future.then((value) => value as T?);
  }

  Future<bool> _pop([Object? result]) async {
    if (_disposed || !canPop) return false;
    final revision = ++_revision;
    final next = _entries.take(_entries.length - 1).toList();
    try {
      if (!await _allowExit(next) || _disposed || revision != _revision) {
        return false;
      }
      _install(next, result: result);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Requests a pop. The exit guard may asynchronously veto it.
  bool pop<T extends Object?>([T? result]) {
    _ensureOpen();
    if (!canPop) return false;
    unawaited(_pop(result));
    return true;
  }

  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    String? fragment,
  }) {
    _ensureOpen();
    final path = _namedPaths[name];
    if (path == null) throw ArgumentError.value(name, 'name', 'Unknown route');
    final required =
        RegExp(r':(\w+)').allMatches(path).map((m) => m[1]!).toSet();
    if (!required.every(pathParameters.containsKey) ||
        pathParameters.keys.any((p) => !required.contains(p))) {
      throw ArgumentError('Path parameters must match $required');
    }
    final encoded = path.replaceAllMapped(
      RegExp(r':(\w+)'),
      (m) => Uri.encodeComponent(pathParameters[m[1]]!),
    );
    // Parse an already escaped path, rather than passing it to Uri(path: ...).
    return Uri.parse(encoded)
        .replace(
          queryParameters: queryParameters.isEmpty ? null : queryParameters,
          fragment: fragment,
        )
        .toString();
  }

  void goNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
    String? fragment,
  }) => go(
    namedLocation(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      fragment: fragment,
    ),
    extra: extra,
  );
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
    String? fragment,
  }) => push<T>(
    namedLocation(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      fragment: fragment,
    ),
    extra: extra,
  );
  void refresh() {
    _ensureOpen();
    unawaited(
      _navigate(
        (_requestedUri ?? state.uri).toString(),
        extra: _requestedUri == null ? state.extra : _requestedExtra,
      ),
    );
  }

  Future<void> setNewRoutePath(Uri configuration) {
    _ensureOpen();
    return _navigate(configuration.toString());
  }

  String _branchInitial(ActivityShellBranch branch) {
    if (branch.initialLocation != null) return branch.initialLocation!;
    ActivityRoute? first(List<ActivityRouteBase> routes) {
      for (final route in routes) {
        if (route is ActivityRoute) return route;
        final found = first(route.routes);
        if (found != null) return found;
      }
      return null;
    }

    final route = first(branch.routes)!;
    final path = _fullPaths[route]!;
    if (path.contains(':')) {
      throw StateError('A parameterized branch needs initialLocation');
    }
    return path;
  }

  Future<void> _goBranch(
    ActivityStatefulShellRoute route,
    int index,
    bool initial,
  ) async {
    _ensureOpen();
    RangeError.checkValidIndex(index, route.branches);
    _saveBranches();
    final saved = initial ? null : _branches[route]?[index];
    if (saved == null || saved.isEmpty) {
      await _navigate(_branchInitial(route.branches[index]));
      return;
    }
    final revision = ++_revision;
    // Guards run again, including after restoration. Preserve live completers.
    final resolved = await _resolve(
      saved.last.state.uri,
      saved.last.state.extra,
    );
    if (_disposed || revision != _revision) return;
    if (resolved.last.state.uri != saved.last.state.uri ||
        resolved.last.state.error != null) {
      _install(resolved);
      return;
    }
    try {
      if (await _allowExit(saved) && !_disposed && revision == _revision) {
        final ancestors = resolved.where(
          (entry) => !entry.scopes.any((scope) => scope.route == route),
        );
        _install([...ancestors, ...saved], completeRemoved: false);
      }
    } catch (error) {
      if (!_disposed && revision == _revision) {
        final failed = ActivityRouteState(
          saved.last.state.uri,
          error: ActivityNavigationException('Exit guard failed: $error'),
        );
        _install([_RouteEntry(null, failed, [], 'exit-error:${failed.uri}')]);
      }
    }
  }

  ActivityRouteConfiguration _snapshot() =>
      ActivityRouteConfiguration._(List.unmodifiable(_entries), {
        for (final item in _branches.entries)
          item.key: {
            for (final branch in item.value.entries)
              branch.key: List.unmodifiable(branch.value),
          },
      });

  Map<String, Object?> _encode(ActivityRouteConfiguration value) {
    Map<String, Object?> encodeEntry(_RouteEntry entry) => {
      'uri': entry.state.uri.toString(),
      'key': entry.key,
      'extra':
          extraCodec == null
              ? entry.state.extra
              : extraCodec!.encode(entry.state.extra),
    };
    return {
      'activityRouter': 1,
      'stack': value._entries.map(encodeEntry).toList(),
      'branches': {
        for (final route in value._branches.entries)
          _routeIds[route.key]!: {
            for (final branch in route.value.entries)
              '${branch.key}': branch.value.map(encodeEntry).toList(),
          },
      },
    };
  }

  Future<ActivityRouteConfiguration> _parse(RouteInformation info) async {
    final revision = ++_revision;
    final saved = info.state;
    if (saved is Map && saved['activityRouter'] == 1) {
      try {
        List<_RouteEntry> decodeEntries(Object? data) => [
          for (final raw in data as List) ..._decodeEntry(raw as Map),
        ];
        final stack = decodeEntries(saved['stack']);
        final branches =
            <ActivityStatefulShellRoute, Map<int, List<_RouteEntry>>>{};
        final rawBranches = saved['branches'] as Map;
        for (final route
            in _routeIds.keys.whereType<ActivityStatefulShellRoute>()) {
          final raw = rawBranches[_routeIds[route]];
          if (raw is Map) {
            branches[route] = {
              for (final item in raw.entries)
                int.parse(item.key as String): decodeEntries(item.value),
            };
          }
        }
        if (stack.isNotEmpty) {
          final checked = await _resolve(
            stack.last.state.uri,
            stack.last.state.extra,
          );
          if (checked.last.state.uri == stack.last.state.uri &&
              checked.last.state.error == null) {
            return ActivityRouteConfiguration._(stack, branches);
          }
          return ActivityRouteConfiguration._(checked, branches);
        }
      } catch (_) {
        /* Invalid/obsolete browser state falls back to its URL. */
      }
    }
    final entries = await _resolve(info.uri, null);
    if (_disposed || revision != _revision) return _snapshot();
    return ActivityRouteConfiguration._(entries, {});
  }

  List<_RouteEntry> _decodeEntry(Map raw) {
    final uri = _parseUri(raw['uri'] as String);
    final extra =
        extraCodec == null ? raw['extra'] : extraCodec!.decode(raw['extra']);
    final matched = _match(uri, extra);
    if (matched == null) throw const FormatException('Unknown restored route');
    final leaf = matched.last;
    final pushed = RegExp(r':push(\d+)$').firstMatch(raw['key'] as String);
    if (pushed != null) {
      final next = int.parse(pushed[1]!) + 1;
      if (next > _nextKey) _nextKey = next;
    }
    final restoredState = ActivityRouteState(
      leaf.state.uri,
      pathParameters: leaf.state.pathParameters,
      extra: leaf.state.extra,
      name: leaf.state.name,
      fullPath: leaf.state.fullPath,
      pageKey: ValueKey(raw['key'] as String),
    );
    return [
      _RouteEntry(leaf.route, restoredState, leaf.scopes, raw['key'] as String),
    ];
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _revision++;
    final sub = _subscription;
    if (sub != null) unawaited(_controller!.cancelSubscription(sub));
    for (final completer in _pendingPushes.toList()) {
      if (!completer.isCompleted) completer.complete(null);
    }
    final all = <_RouteEntry>{
      ..._entries,
      for (final branches in _branches.values)
        for (final entries in branches.values) ...entries,
    };
    for (final entry in all) {
      if (entry.completer != null && !entry.completer!.isCompleted) {
        entry.completer!.complete(null);
      }
    }
    routerDelegate.dispose();
    routeInformationProvider.dispose();
    super.dispose();
  }
}

/// Flutter parser exposed for custom Router integration and URL restoration.
class ActivityRouteInformationParser
    extends RouteInformationParser<ActivityRouteConfiguration> {
  ActivityRouteInformationParser._(this.router);
  final ActivityRouter router;
  @override
  Future<ActivityRouteConfiguration> parseRouteInformation(
    RouteInformation routeInformation,
  ) => router._parse(routeInformation);
  @override
  RouteInformation restoreRouteInformation(
    ActivityRouteConfiguration configuration,
  ) => RouteInformation(
    uri: configuration.uri,
    state: router._encode(configuration),
  );
}

/// Flutter delegate exposed for custom Router integration and system back.
class ActivityRouterDelegate extends RouterDelegate<ActivityRouteConfiguration>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<ActivityRouteConfiguration> {
  ActivityRouterDelegate._(this.router);
  final ActivityRouter router;
  @override
  GlobalKey<NavigatorState> get navigatorKey => router.navigatorKey;
  @override
  ActivityRouteConfiguration? get currentConfiguration =>
      router._entries.isEmpty ? null : router._snapshot();
  void _changed() => notifyListeners();
  @override
  Future<void> setNewRoutePath(ActivityRouteConfiguration configuration) async {
    if (router._disposed) return;
    final revision = router._revision;
    if (!await router._allowExit(configuration._entries) ||
        router._disposed ||
        revision != router._revision) {
      return;
    }
    router._branches = configuration._branches;
    router._install(configuration._entries);
  }

  @override
  Future<bool> popRoute() async {
    // Pageless dialogs are owned by Navigator, not the declarative page stack.
    for (final key in [
      navigatorKey,
      ...router._entries.isEmpty
          ? <GlobalKey<NavigatorState>>[]
          : router._entries.last.scopes.map(router._navigatorFor),
    ]) {
      final top = router._navigationObservers[key]?.top;
      if (top != null && top.willHandlePopInternally) {
        key.currentState!.pop();
        return true;
      }
      if (top != null && top.settings is! Page) {
        return key.currentState!.maybePop();
      }
    }
    return router._pop();
  }

  @override
  Widget build(BuildContext context) => _RouterScope(
    router,
    child: Builder(
      builder:
          (context) => _navigator(
            context,
            router._entries,
            0,
            navigatorKey,
            router.restorationScopeId,
            router.observers,
          ),
    ),
  );

  Widget _navigator(
    BuildContext context,
    List<_RouteEntry> entries,
    int depth,
    GlobalKey<NavigatorState> key,
    String? restorationId,
    List<NavigatorObserver> observers,
  ) {
    final pages = <Page<dynamic>>[];
    final seenShells = <ActivityRouteBase>{};
    for (final entry in entries) {
      if (entry.scopes.length > depth) {
        final selection = entry.scopes[depth];
        final shell = selection.route;
        if (!seenShells.add(shell)) continue;
        final selectedEntries =
            entries
                .where(
                  (e) =>
                      e.scopes.length > depth && e.scopes[depth].route == shell,
                )
                .toList();
        final selected = selectedEntries.last;
        final shellKey = router._routeIds[shell]!;
        final scopeId =
            shell is ActivityShellRoute
                ? shell.restorationScopeId
                : (shell as ActivityStatefulShellRoute).restorationScopeId;
        Widget child;
        if (shell is ActivityShellRoute) {
          child = Builder(
            builder:
                (context) => shell.builder(
                  context,
                  selected.state,
                  _navigator(
                    context,
                    selectedEntries,
                    depth + 1,
                    shell.navigatorKey,
                    scopeId,
                    shell.observers,
                  ),
                ),
          );
        } else {
          final tabs = shell as ActivityStatefulShellRoute;
          final currentIndex = selected.scopes[depth].branch!;
          child = Builder(
            builder:
                (context) => tabs.builder(
                  context,
                  selected.state,
                  ActivityNavigationShell._(
                    currentIndex: currentIndex,
                    onBranch:
                        (index, initial) =>
                            unawaited(router._goBranch(tabs, index, initial)),
                    children: [
                      for (var i = 0; i < tabs.branches.length; i++)
                        if (router._branches[tabs]?[i] case final branch?)
                          _navigator(
                            context,
                            branch,
                            depth + 1,
                            tabs.branches[i].navigatorKey,
                            tabs.branches[i].restorationScopeId,
                            tabs.branches[i].observers,
                          )
                        else
                          const SizedBox.shrink(),
                    ],
                  ),
                ),
          );
        }
        pages.add(
          MaterialPage<void>(
            key: ValueKey(shellKey),
            restorationId: scopeId,
            child: _RouteScope(selected.state, child: child),
          ),
        );
      } else {
        final route = entry.route;
        final state = entry.state;
        final contextKey = entry.contextKey;
        Widget body = _RouteScope(
          state,
          child: Builder(
            key: contextKey,
            builder: (context) {
              if (state.error != null) {
                return router.errorBuilder?.call(context, state) ??
                    Scaffold(
                      body: Center(
                        child: Text(
                          state.error.toString().contains('Page not found:')
                              ? 'Page not found: ${state.uri.path}'
                              : 'Navigation failed: ${state.error}',
                        ),
                      ),
                    );
              }
              return route?.builder?.call(context, state) ??
                  const SizedBox.shrink();
            },
          ),
        );
        if (route?.pageBuilder != null) {
          // Custom pages still receive router and route-state context.
          pages.add(
            _ScopedPage(route!.pageBuilder!(context, state), entry, router),
          );
        } else {
          pages.add(
            MaterialPage<dynamic>(
              key: ValueKey(entry.key),
              name: state.name,
              arguments: state.extra,
              restorationId: entry.key,
              child: PopScope<Object?>(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) unawaited(router._pop(result));
                },
                child: body,
              ),
            ),
          );
        }
      }
    }
    if (pages.isEmpty) {
      pages.add(
        const MaterialPage<void>(
          key: ValueKey('loading'),
          child: SizedBox.shrink(),
        ),
      );
    }
    return Navigator(
      key: key,
      restorationScopeId: restorationId,
      observers: [
        router._navigationObservers.putIfAbsent(key, _NavigationObserver.new),
        ...observers,
      ],
      pages: pages,
      // A synchronous Navigator pop must wait for asynchronous exit guards.
      onDidRemovePage: (_) {},
    );
  }
}

class _ScopedPage extends Page<dynamic> {
  _ScopedPage(this.page, this.entry, this.router)
    : super(
        key: page.key,
        name: page.name,
        arguments: page.arguments,
        restorationId: page.restorationId,
      );
  final Page<dynamic> page;
  final _RouteEntry entry;
  ActivityRouteState get state => entry.state;
  GlobalKey get contextKey => entry.contextKey;
  final ActivityRouter router;
  @override
  Route<dynamic> createRoute(BuildContext context) {
    final original = page;
    if (original is! MaterialPage &&
        original is! ActivityTransitionPage &&
        original is! ActivityNoTransitionPage) {
      throw ArgumentError(
        'Use MaterialPage, ActivityTransitionPage or ActivityNoTransitionPage',
      );
    }
    final scoped = AnimatedBuilder(
      animation: router,
      builder: (context, _) {
        final current = entry.route!.pageBuilder!(context, entry.state);
        final Widget content;
        if (current is MaterialPage) {
          content = current.child;
        } else if (current is ActivityTransitionPage) {
          content = current.child;
        } else {
          content = (current as ActivityNoTransitionPage).child;
        }
        return _RouteScope(
          entry.state,
          child: Builder(
            key: contextKey,
            builder:
                (_) => PopScope<Object?>(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (!didPop) unawaited(router._pop(result));
                  },
                  child: content,
                ),
          ),
        );
      },
    );
    if (original is MaterialPage) {
      return MaterialPageRoute<dynamic>(
        settings: this,
        builder: (_) => scoped,
        maintainState: original.maintainState,
        fullscreenDialog: original.fullscreenDialog,
      );
    }
    return PageRouteBuilder<dynamic>(
      settings: this,
      pageBuilder: (_, __, ___) => scoped,
      transitionDuration:
          original is ActivityTransitionPage
              ? original.transitionDuration
              : Duration.zero,
      reverseTransitionDuration:
          original is ActivityTransitionPage
              ? original.reverseTransitionDuration
              : Duration.zero,
      transitionsBuilder:
          original is ActivityTransitionPage
              ? original.transitionsBuilder
              : (_, __, ___, child) => child,
    );
  }
}

class _NavigationObserver extends NavigatorObserver {
  final List<Route<dynamic>> _routes = [];
  Route<dynamic>? get top => _routes.lastOrNull;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.add(route);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.remove(route);
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.remove(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute == null) {
      if (newRoute != null) _routes.add(newRoute);
      return;
    }
    final index = _routes.indexOf(oldRoute);
    if (index >= 0) {
      if (newRoute == null) {
        _routes.removeAt(index);
      } else {
        _routes[index] = newRoute;
      }
    }
  }
}

/// Concise access without exporting a third-party router extension namespace.
extension ActivityRouterContext on BuildContext {
  ActivityRouter get activityRouter => ActivityRouter.of(this);
  ActivityRouteState get activityRoute => ActivityRouteState.of(this);
}

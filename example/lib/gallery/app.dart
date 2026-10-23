import 'dart:async';
import 'package:quickeydb/quickeydb.dart';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'catalog.dart';
import 'branding.dart';
import 'controllers.dart';
import 'widgets.dart';
import 'support_links.dart';
import 'recipes/workbench.dart';
import 'recipes/database_page.dart';
import 'recipes/database_controller.dart';
import 'pages/state_pages.dart';
import 'pages/service_pages.dart';
import 'pages/utility_pages.dart';
import 'pages/learning_pages.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.openDatabase});
  final Future<QuickeyDBImpl> Function()? openDatabase;
  @override
  Widget build(BuildContext context) => RootRestorationScope(
    restorationId: 'gallery_root',
    child: _GalleryApp(openDatabase: openDatabase),
  );
}

class _GalleryApp extends StatefulWidget {
  const _GalleryApp({this.openDatabase});
  final Future<QuickeyDBImpl> Function()? openDatabase;
  @override
  State<_GalleryApp> createState() => _MyAppState();
}

class _MyAppState extends State<_GalleryApp> with RestorationMixin {
  final settings = GallerySettings();
  final lab = PlaygroundController();
  final console = GalleryConsole();
  late final database = RecordsController(console, open: widget.openDatabase);
  void recordNavigation() {
    // Match template excludes path values, query parameters and extra payloads.
    console.add('Navigation', router.state.fullPath ?? 'Unknown route');
  }

  final themeChoice = RestorableInt(1),
      localeChoice = RestorableInt(0),
      accentChoice = RestorableInt(0);
  StreamSubscription? _settingsSubscription;
  static const locales = [
    Locale('en'),
    Locale('sw'),
    Locale('fr'),
    Locale('ar'),
  ];
  late final translations = ActiveLocalizationDelegate(
    supportedLocales: locales,
    fallbackLocale: const Locale('en'),
    assetPath: 'assets/i18n',
  );
  late final ActivityRouter router = ActivityRouter(
    restorationScopeId: 'gallery_router',
    refreshController: settings,
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Destination unavailable')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The address does not match a gallery route, or a navigation check failed.',
            ),
            TextButton(
              onPressed: () => router.goNamed('overview'),
              child: const Text('Recover to overview'),
            ),
          ],
        ),
      ),
    ),
    routes: [
      ActivityStatefulShellRoute.indexedStack(
        restorationScopeId: 'gallery_sections',
        branches: [
          for (final destination in destinations)
            ActivityShellBranch(
              restorationScopeId: 'section_${destination.id}',
              routes: [
                ActivityRoute(
                  path: destination.path,
                  name: destination.id,
                  builder: (_, state) => _page(destination.id),
                  routes: destination.id == 'navigation'
                      ? [
                          ActivityRoute(
                            path: 'details/:id',
                            name: 'route-detail',
                            builder: (_, state) => RouteDetailPage(state),
                          ),
                          ActivityRoute(
                            path: 'transition',
                            name: 'route-transition',
                            pageBuilder: (_, state) => ActivityTransitionPage<void>(
                              key: state.pageKey,
                              restorationId: 'gallery_transition',
                              transitionDuration: const Duration(
                                milliseconds: 180,
                              ),
                              transitionsBuilder: (_, animation, __, child) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: Scaffold(
                                appBar: AppBar(
                                  title: const Text('Activity transition'),
                                ),
                                body: const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'This fade page is built by ActivityTransitionPage on Flutter Navigator. Use Back to return.',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ActivityRoute(
                            path: 'editor',
                            name: 'route-editor',
                            onExit: (context, state) async {
                              if (!lab.draftDirty.value) return true;
                              final leave = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Discard unsaved changes?'),
                                  content: const Text(
                                    'The exit guard keeps this editor open until you choose to leave.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: const Text('Keep editing'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      child: const Text('Discard changes'),
                                    ),
                                  ],
                                ),
                              );
                              if (leave == true && !lab.isDisposed) {
                                lab.draftDirty(false);
                              }
                              return leave ?? false;
                            },
                            builder: (_, state) => const EditorPage(),
                          ),
                          ActivityRoute(
                            path: 'account',
                            name: 'route-account',
                            redirect: (state) async {
                              await Future<void>.delayed(
                                const Duration(milliseconds: 180),
                              );
                              return settings.isDisposed ||
                                      !settings.signedIn.value
                                  ? '/navigation/login'
                                  : null;
                            },
                            builder: (_, state) => const AccountPage(),
                          ),
                          ActivityRoute(
                            path: 'login',
                            name: 'route-login',
                            builder: (_, state) => const LoginPage(),
                          ),
                        ]
                      : destination.id == 'database'
                      ? [
                          ActivityRoute(
                            path: 'record/:id',
                            name: 'database-detail',
                            builder: (_, state) => RecordDetailPage(
                              controller: database,
                              id: int.tryParse(
                                state.pathParameters['id'] ?? '',
                              ),
                            ),
                          ),
                        ]
                      : destination.id == 'settings'
                      ? [
                          ActivityRoute(
                            path: 'privacy',
                            name: 'settings-privacy',
                            builder: (_, state) => const SettingsPrivacyPage(),
                          ),
                        ]
                      : const [],
                ),
              ],
            ),
        ],
        builder: (_, state, shell) => GalleryShell(shell: shell),
      ),
    ],
  );
  Widget _page(String id) => switch (id) {
    'overview' => const OverviewPage(),
    'recipes' => RecipesPage(console: console),
    'database' => DatabasePage(controller: database),
    'start' => const StartPage(),
    'values' => const ValuesPage(),
    'collections' => const CollectionsPage(),
    'models' => const ModelsPage(),
    'views' => const ViewsPage(),
    'async' => const AsyncPage(),
    'events' => const EventsPage(),
    'navigation' => const NavigationPage(),
    'restoration' => const RestorationPage(),
    'localization' => const LocalizationPage(),
    'validation' => const ValidationPage(),
    'environment' => const EnvironmentPage(),
    'helpers' => const HelpersPage(),
    'lifecycle' => const LifecyclePage(),
    'guidance' => const GuidancePage(),
    'settings' => const SettingsPage(),
    _ => const OverviewPage(),
  };
  @override
  String get restorationId => 'gallery_preferences';
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(themeChoice, 'theme');
    registerForRestoration(localeChoice, 'locale');
    registerForRestoration(accentChoice, 'accent');
    settings.theme.set(
      ThemeMode.values[themeChoice.value.clamp(0, 2)],
      notifyChange: false,
    );
    settings.locale.set(
      locales[localeChoice.value.clamp(0, 3)],
      notifyChange: false,
    );
    settings.accent.set(
      accentChoice.value.clamp(0, accents.length - 1),
      notifyChange: false,
    );
  }

  @override
  void initState() {
    super.initState();
    router.addListener(recordNavigation);
    console.watch(lab, 'Playground');
    console.watch(settings, 'Preferences');
    console.add(
      'Gallery',
      'Ready. Try a live example, then inspect its source.',
    );
    _settingsSubscription = settings.addOnStateChangedListener((_) {
      themeChoice.value = settings.theme.value.index;
      localeChoice.value = locales.indexOf(settings.locale.value);
      accentChoice.value = settings.accent.value;
    });
  }

  ThemeData theme(Brightness brightness, int accent) {
    final scheme = ColorScheme.fromSeed(
      seedColor: accents[accent],
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF4F9FC)
          : const Color(0xFF101D25),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .65)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      dividerColor: scheme.outlineVariant.withValues(alpha: .65),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 14, height: 1.45),
        bodySmall: TextStyle(fontSize: 12, height: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GalleryScope(
    settings: settings,
    lab: lab,
    console: console,
    child: Activity(
      settings,
      child: ActivitySelector<GallerySettings, (ThemeMode, Locale, int)>(
        controller: settings,
        select: (c) => (c.theme.value, c.locale.value, c.accent.value),
        builder: (_, value, child) => MaterialApp.router(
          title: 'Activity Gallery',
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'activity_gallery',
          routerConfig: router.config,
          theme: theme(Brightness.light, value.$3),
          darkTheme: theme(Brightness.dark, value.$3),
          themeMode: value.$1,
          locale: value.$2,
          supportedLocales: locales,
          localizationsDelegates: [
            translations,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    ),
  );
  @override
  void dispose() {
    router.removeListener(recordNavigation);
    router.dispose();
    unawaited(database.dispose());
    console.dispose();
    unawaited(settings.cancelSubscription(_settingsSubscription));
    unawaited(lab.dispose());
    unawaited(settings.dispose());
    themeChoice.dispose();
    localeChoice.dispose();
    accentChoice.dispose();
    super.dispose();
  }
}

class GalleryShell extends StatefulWidget {
  final ActivityNavigationShell shell;
  const GalleryShell({super.key, required this.shell});
  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  final search = TextEditingController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String query = '';
  bool consoleOpen = false;
  void navigate(int index, {bool closeDrawer = false}) {
    if (closeDrawer) Navigator.of(context).pop();
    widget.shell.goBranch(index);
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Widget sidebar(bool drawer) => SizedBox(
    width: 252,
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 18, 20),
              child: Row(
                children: [
                  const ActivityLogo(),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.5,
                              ),
                        ),
                        Text(
                          'Flutter Activity Doc',
                          style: TextStyle(
                            fontSize: 9,
                            letterSpacing: 1.4,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: search,
                onChanged: (value) =>
                    setState(() => query = value.toLowerCase().trim()),
                decoration: const InputDecoration(
                  hintText: 'Find an example',
                  prefixIcon: Icon(Icons.search, size: 19),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    if (query.isEmpty ||
                        '${destinations[i].title} ${destinations[i].summary} ${destinations[i].api}'
                            .toLowerCase()
                            .contains(query)) ...[
                      if (query.isEmpty &&
                          (i == 0 ||
                              destinations[i].group !=
                                  destinations[i - 1].group))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 20, 0, 8),
                          child: Text(
                            destinations[i].group,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Material(
                          color: widget.shell.currentIndex == i
                              ? Theme.of(context).colorScheme.primaryContainer
                                    .withValues(alpha: .65)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          child: ListTile(
                            key: ValueKey('nav-${destinations[i].id}'),
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            leading: Icon(
                              destinations[i].icon,
                              size: 19,
                              color: widget.shell.currentIndex == i
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            minLeadingWidth: 20,
                            title: Text(
                              destinations[i].title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: widget.shell.currentIndex == i
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            onTap: () => navigate(i, closeDrawer: drawer),
                          ),
                        ),
                      ),
                    ],
                  if (query.isNotEmpty &&
                      !destinations.any(
                        (d) => '${d.title} ${d.summary} ${d.api}'
                            .toLowerCase()
                            .contains(query),
                      ))
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No matching examples. Try “ICU”, “state” or “events”.',
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              dense: true,
              leading: const Icon(Icons.terminal_rounded, size: 19),
              title: const Text(
                'Activity console',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                if (drawer) Navigator.pop(context);
                setState(() => consoleOpen = true);
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  Pill('2.0.0'),
                  SizedBox(width: 8),
                  Text('Local preview', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final settings = GalleryScope.of(context).settings;
    return ConsoleDockRequest(
      open: () => setState(() => consoleOpen = true),
      child: Scaffold(
        key: scaffoldKey,
        drawer: compact ? Drawer(width: 280, child: sidebar(true)) : null,
        body: Row(
          children: [
            if (!compact) ...[sidebar(false), const VerticalDivider(width: 1)],
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 64,
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 12 : 28,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (compact)
                          IconButton(
                            tooltip: 'Open navigation',
                            onPressed: () =>
                                scaffoldKey.currentState!.openDrawer(),
                            icon: const Icon(Icons.menu_rounded),
                          ),
                        Icon(
                          destinations[widget.shell.currentIndex].icon,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            destinations[widget.shell.currentIndex].title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (!compact) const Pill('\'Active\' examples'),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Toggle light / dark theme',
                          onPressed: () => settings.theme(
                            Theme.of(context).brightness == Brightness.dark
                                ? ThemeMode.light
                                : ThemeMode.dark,
                          ),
                          icon: Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Open Activity console',
                          onPressed: () =>
                              setState(() => consoleOpen = !consoleOpen),
                          icon: const Icon(Icons.terminal_rounded, size: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: widget.shell),
                  if (consoleOpen)
                    SizedBox(
                      height: (MediaQuery.sizeOf(context).height * .36).clamp(
                        150.0,
                        300.0,
                      ),
                      child: DeveloperConsole(
                        console: GalleryScope.of(context).console,
                        onClose: () => setState(() => consoleOpen = false),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPrivacyPage extends StatelessWidget {
  const SettingsPrivacyPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Support')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TextButton(
          onPressed: () => ActivityRouter.of(context).pop(),
          child: const Text('Return to appearance'),
        ),
        const SupportLinks(),
      ],
    ),
  );
}

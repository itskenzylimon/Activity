import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import '../controllers.dart';
import '../widgets.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  Deamon bus = Deamon();
  final message = TextEditingController(text: 'Hello from Activity');
  final List<StreamSubscription> subscriptions = [];
  final List<String> log = [];
  bool stickyAttached = false, waiting = false;
  void record(String text) {
    if (mounted) {
      GalleryScope.of(
        context,
      ).console.add('Events', 'Local event delivered; payload omitted');
      setState(() {
        log.insert(0, text);
        if (log.length > 40) log.removeLast();
      });
    }
  }

  void subscribe() => subscriptions.add(
    bus.listen<String>(
      (event) => record('Live subscriber → $event'),
      onError: (Object error) => record('Handled error → $error'),
    ),
  );
  @override
  void initState() {
    super.initState();
    subscribe();
  }

  @override
  void dispose() {
    for (final sub in subscriptions) {
      unawaited(sub.cancel());
    }
    unawaited(bus.close());
    message.dispose();
    super.dispose();
  }

  Future<void> restart() async {
    for (final sub in subscriptions) {
      await sub.cancel();
    }
    subscriptions.clear();
    await bus.close();
    if (!mounted) return;
    setState(() {
      bus = Deamon();
      stickyAttached = false;
      waiting = false;
      log.clear();
    });
    subscribe();
  }

  Future<void> next() async {
    setState(() => waiting = true);
    try {
      final event = await bus.next<String>();
      record('next<String>() resolved → $event');
    } catch (error) {
      record('next<String>() completed with $error');
    }
    if (mounted) setState(() => waiting = false);
  }

  @override
  Widget build(BuildContext context) => GalleryPage(
    'events',
    children: [
      DemoCard(
        title: 'Typed broadcast & sticky replay',
        description:
            'Emit a sticky message first, then attach the late subscriber to see per-subscriber replay.',
        code:
            "final bus = Deamon();\nfinal live = bus.listen<String>(onMessage, onError: onError);\nbus.emitSticky<String>('Latest value');\nfinal late = bus.onSticky<String>().listen(onMessage);\n// The latest sticky String is replayed to this new subscriber.\nawait live.cancel();\nawait late.cancel();\nawait bus.close();",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: message,
              decoration: const InputDecoration(labelText: 'Event payload'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: bus.isClosed ? null : () => bus.emit(message.text),
                  child: const Text('Emit event'),
                ),
                OutlinedButton(
                  onPressed: bus.isClosed
                      ? null
                      : () => bus.emitSticky<String>(message.text),
                  child: const Text('Emit sticky'),
                ),
                OutlinedButton(
                  onPressed: bus.isClosed || stickyAttached
                      ? null
                      : () {
                          setState(() => stickyAttached = true);
                          subscriptions.add(
                            bus.onSticky<String>().listen(
                              (value) =>
                                  record('Late sticky subscriber → $value'),
                              onError: (Object error) =>
                                  record('Late subscriber handled → $error'),
                            ),
                          );
                        },
                  child: Text(
                    stickyAttached
                        ? 'Late subscriber attached'
                        : 'Attach late subscriber',
                  ),
                ),
                TextButton(
                  onPressed: bus.isClosed
                      ? null
                      : () {
                          bus.clearSticky<String>();
                          record('Sticky cache cleared');
                        },
                  child: const Text('Clear sticky'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: bus.isClosed || waiting ? null : next,
                  child: Text(
                    waiting ? 'Waiting for an event…' : 'Await next event',
                  ),
                ),
                OutlinedButton(
                  onPressed: bus.isClosed
                      ? null
                      : () => bus.emitError(StateError('Demo event error')),
                  child: const Text('Emit handled error'),
                ),
                TextButton(
                  onPressed: bus.isClosed
                      ? null
                      : () async {
                          await bus.close();
                          if (mounted) setState(() {});
                        },
                  child: const Text('Close bus'),
                ),
                TextButton(
                  onPressed: restart,
                  child: const Text('Start fresh'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Pill(
              bus.isClosed
                  ? 'Closed'
                  : 'Open · ${stickyAttached ? 2 : 1} subscribers',
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: log.isEmpty
                  ? const Center(child: Text('Your event trace appears here.'))
                  : ListView.builder(
                      itemCount: log.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          log[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      const Guidance(
        doText:
            'Cancel subscriptions when their consumer leaves. Use the exact emission generic type for sticky replay and provide error handlers.',
        dontText:
            'Do not emit after close or assume this isolate-local bus bridges processes, devices, or platform channels.',
      ),
    ],
  );
}

class NavigationPage extends StatelessWidget {
  const NavigationPage({super.key});
  @override
  Widget build(BuildContext context) {
    final scope = GalleryScope.of(context), router = ActivityRouter.of(context);
    return GalleryPage(
      'navigation',
      children: [
        DemoCard(
          title: 'Flutter-native routing and custom transitions',
          description:
              'Activity owns matching, guards, typed results and restoration directly on Flutter Router and Navigator. Inspect the exposed parser/delegate or try a fade page.',
          code:
              "final router = context.activityRouter;\nfinal parser = router.routeInformationParser;\nfinal delegate = router.routerDelegate;\n// MaterialApp.router(routerConfig: router.config)\n// A pageBuilder can return ActivityTransitionPage, ActivityNoTransitionPage or MaterialPage.",
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              const ValueTile('Routing engine', 'Flutter Router + Navigator'),
              FilledButton.tonal(
                onPressed: () => router.pushNamed<void>('route-transition'),
                child: const Text('Try a fade transition'),
              ),
            ],
          ),
        ),

        DemoCard(
          title: 'Nested destinations & typed results',
          description:
              'The details page is a child of this page. Back returns here; each gallery section keeps its own history.',
          code:
              "final result = await router.pushNamed<String>(\n  'route-detail',\n  pathParameters: {'id': '42'},\n  queryParameters: {'tab': 'summary'},\n);\n// In the details page: router.pop<String>('Selected #42');",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('open-detail'),
                    onPressed: () async {
                      final result = await router.pushNamed<String>(
                        'route-detail',
                        pathParameters: {'id': '42'},
                        queryParameters: {'tab': 'summary'},
                      );
                      if (!scope.lab.isDisposed) {
                        scope.lab.result(
                          result ?? 'Returned without a selection.',
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Open nested details'),
                  ),
                  OutlinedButton(
                    onPressed: () => router.goNamed('route-editor'),
                    child: const Text('Try exit confirmation'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ActivitySelector<PlaygroundController, String>(
                controller: scope.lab,
                select: (c) => c.result.value,
                builder: (_, value, child) => Text(value),
              ),
              const SizedBox(height: 12),
              CodeBlock(
                'Location: ${router.state.uri}\nNamed detail: ${router.namedLocation('route-detail', pathParameters: {'id': '42'}, queryParameters: {'tab': 'summary'})}',
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'Asynchronous session guard',
          description:
              'A simulated session check completes before the protected account builder runs. Sign-out triggers a fresh guard check.',
          code:
              "ActivityRoute(\n  path: 'account',\n  redirect: (state) async =>\n    await session.hasSession() ? null : '/navigation/login',\n  builder: (_, state) => const AccountPage(),\n);\n// ActivityRouter(refreshController: session, routes: ...)",
          child: ActivitySelector<GallerySettings, bool>(
            controller: scope.settings,
            select: (c) => c.signedIn.value,
            builder: (_, signedIn, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Pill(
                  signedIn ? 'Signed in' : 'Signed out',
                  color: signedIn ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => router.goNamed('route-account'),
                  child: const Text('Open guarded account'),
                ),
              ],
            ),
          ),
        ),
        const Guidance(
          doText:
              'Use relative child paths, unique route names, async guards and explicit restoration IDs. Keep one router owner outside build.',
          dontText:
              'Do not cast RouterDelegate to ActivityRouter. Use ActivityRouter.of(context), and do not treat a client guard as server authorization.',
        ),
      ],
    );
  }
}

class RouteDetailPage extends StatelessWidget {
  final ActivityRouteState state;
  const RouteDetailPage(this.state, {super.key});
  @override
  Widget build(BuildContext context) => GalleryPage(
    'navigation',
    children: [
      Row(
        children: [
          const BackButton(),
          const SizedBox(width: 8),
          Text('Nested details', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
      DemoCard(
        title: 'Route inspection',
        code:
            "final route = ActivityRouteState.of(context);\nfinal id = route.pathParameters['id'];\nfinal tab = route.queryParameters['tab'];\nActivityRouter.of(context).pop<String>('Selected #42');",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ValueTile('Path parameter', state.pathParameters['id'] ?? '—'),
                ValueTile('Query tab', state.queryParameters['tab'] ?? '—'),
              ],
            ),
            const SizedBox(height: 16),
            CodeBlock(
              'URI: ${state.uri}\nRoute: ${state.name}\nPattern: ${state.fullPath}\nExtra: ${state.extra}',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ActivityRouter.of(
                context,
              ).pop<String>('Selected #${state.pathParameters['id']}'),
              child: const Text('Return a typed result'),
            ),
          ],
        ),
      ),
    ],
  );
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});
  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final draft = TextEditingController();
  @override
  void dispose() {
    draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lab = GalleryScope.of(context).lab;
    return GalleryPage(
      'navigation',
      children: [
        Row(
          children: [
            const BackButton(),
            const SizedBox(width: 8),
            Text(
              'Editor with an exit guard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        DemoCard(
          title: 'Unsaved-change confirmation',
          code:
              "onExit: (context, state) async {\n  if (!draftDirty.value) return true;\n  return await confirmDiscard(context) ?? false;\n},",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: draft,
                minLines: 3,
                maxLines: 6,
                onChanged: (_) => lab.draftDirty(true),
                decoration: const InputDecoration(
                  labelText: 'Write a draft, then press Back',
                ),
              ),
              const SizedBox(height: 16),
              ActivitySelector<PlaygroundController, bool>(
                controller: lab,
                select: (c) => c.draftDirty.value,
                builder: (_, dirty, child) =>
                    Pill(dirty ? 'Unsaved changes' : 'Saved'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  lab.draftDirty(false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Draft marked saved for this demo.'),
                    ),
                  );
                },
                child: const Text('Mark as saved'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) => GalleryPage(
    'navigation',
    children: [
      DemoCard(
        title: 'The guard redirected you here',
        description:
            'This is a local demonstration session. No credentials or network service are used.',
        code: "session.signedIn(true);\nrouter.goNamed('route-account');",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 42),
            const SizedBox(height: 14),
            const Text('Sign in to view the protected page.'),
            const SizedBox(height: 18),
            FilledButton(
              key: const ValueKey('demo-sign-in'),
              onPressed: () {
                GalleryScope.of(context).settings.signedIn.setTrue();
                ActivityRouter.of(context).goNamed('route-account');
              },
              child: const Text('Sign in to demo session'),
            ),
            TextButton(
              onPressed: () => ActivityRouter.of(context).goNamed('navigation'),
              child: const Text('Return to routing examples'),
            ),
          ],
        ),
      ),
    ],
  );
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) => GalleryPage(
    'navigation',
    children: [
      DemoCard(
        title: 'Protected account',
        description:
            'This builder only runs after the async session guard allows entry.',
        code:
            "session.signedIn(false);\n// Controller refresh re-evaluates the route guard.",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 42,
              color: Color(0xFF087F5B),
            ),
            const SizedBox(height: 14),
            const Text('You are signed in to the local demo.'),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () =>
                  GalleryScope.of(context).settings.signedIn.setFalse(),
              child: const Text('Sign out and recheck guard'),
            ),
            TextButton(
              onPressed: () => ActivityRouter.of(context).goNamed('navigation'),
              child: const Text('Return to routing examples'),
            ),
          ],
        ),
      ),
    ],
  );
}

class RestorationPage extends StatelessWidget {
  const RestorationPage({super.key});
  @override
  Widget build(BuildContext context) => const GalleryPage(
    'restoration',
    children: [
      DemoCard(
        title: 'Restorable widget state',
        description:
            'The field and counter use RestorableProperty. Switching gallery sections keeps them mounted; process restoration uses their registered values.',
        code:
            "class CounterState extends State<Counter> with RestorationMixin {\n  final count = RestorableInt(0);\n  final draft = RestorableTextEditingController();\n  String get restorationId => 'counter';\n  void restoreState(RestorationBucket? old, bool initial) {\n    registerForRestoration(count, 'count');\n    registerForRestoration(draft, 'draft');\n  }\n  // Dispose both properties with the State.\n}",
        child: RestorablePlayground(),
      ),
      DemoCard(
        title: 'Navigation restoration setup',
        code:
            "MaterialApp.router(\n  restorationScopeId: 'activity_gallery',\n  routerConfig: router.config,\n);\n// Router: restorationScopeId: 'gallery_router'\n// Shell: restorationScopeId: 'gallery_sections'\n// Branch: restorationScopeId: 'section_restoration'",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Set stable scope IDs on app, router, shell and branches.'),
            SizedBox(height: 10),
            Text(
              '2. Use the ActivityNavigationShell goBranch method to restore each section’s history.',
            ),
            SizedBox(height: 10),
            Text(
              '3. Register widget properties separately. Persist domain models in your own data layer.',
            ),
            SizedBox(height: 10),
            Text(
              '4. On Android, use the developer “Don’t keep activities” setting to exercise process recreation. Browser refresh is a separate lifecycle.',
            ),
          ],
        ),
      ),
      Guidance(
        doText:
            'Test restoration with a new router instance, including an inactive tab and nested child destination.',
        dontText:
            'Do not confuse keeping an IndexedStack alive with process restoration. A plain controller field is not persisted automatically.',
      ),
    ],
  );
}

class RestorablePlayground extends StatefulWidget {
  const RestorablePlayground({super.key});
  @override
  State<RestorablePlayground> createState() => _RestorablePlaygroundState();
}

class _RestorablePlaygroundState extends State<RestorablePlayground>
    with RestorationMixin {
  final count = RestorableInt(0);
  final draft = RestorableTextEditingController();
  @override
  String get restorationId => 'gallery_restorable_demo';
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(count, 'count');
    registerForRestoration(draft, 'draft');
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Restorable count: ${count.value}',
        key: const ValueKey('restorable-count'),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: [
          FilledButton(
            onPressed: () => setState(() => count.value++),
            child: const Text('Increment restorable counter'),
          ),
          TextButton(
            onPressed: () => setState(() {
              count.value = 0;
              draft.value.clear();
            }),
            child: const Text('Reset example'),
          ),
        ],
      ),
      const SizedBox(height: 20),
      TextField(
        key: const ValueKey('restorable-draft'),
        controller: draft.value,
        decoration: const InputDecoration(
          labelText: 'Restorable draft',
          hintText: 'This text uses RestorableTextEditingController',
        ),
      ),
    ],
  );
  @override
  void dispose() {
    count.dispose();
    draft.dispose();
    super.dispose();
  }
}

class LocalizationPage extends StatefulWidget {
  const LocalizationPage({super.key});
  @override
  State<LocalizationPage> createState() => _LocalizationPageState();
}

class _LocalizationPageState extends State<LocalizationPage> {
  final pattern = TextEditingController(
    text: '{count, plural, =0{No files} one{# file} other{# files}}',
  );
  String? customOutput;
  @override
  void dispose() {
    pattern.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = GalleryScope.of(context);
    return ActivitySelector<PlaygroundController, (int, String)>(
      controller: scope.lab,
      select: (c) => (c.pluralCount.value, c.gender.value),
      builder: (context, state, _) => GalleryPage(
        'localization',
        children: [
          DemoCard(
            title: 'Asset-backed locale & ICU messages',
            description:
                'Translation JSON loads from assets/i18n. English is the fallback; Material controls use Flutter’s SDK delegates.',
            code:
                "final delegate = ActiveLocalizationDelegate(\n  supportedLocales: [Locale('en'), Locale('sw'), Locale('fr'), Locale('ar')],\n  fallbackLocale: Locale('en'), assetPath: 'assets/i18n',\n);\nText(context.tr('tasks', parameters: {'count': count}));",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in [
                      ('en', 'English'),
                      ('sw', 'Kiswahili'),
                      ('fr', 'Français'),
                      ('ar', 'العربية'),
                    ])
                      ChoiceChip(
                        label: Text(entry.$2),
                        selected:
                            Localizations.localeOf(context).languageCode ==
                            entry.$1,
                        onSelected: (_) {
                          scope.settings.locale(Locale(entry.$1));
                          setState(() => customOutput = null);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  context.tr('welcome', parameters: const {'name': 'Kenzy'}),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Decrease plural count',
                      onPressed: state.$1 > 0
                          ? scope.lab.pluralCount.decrement
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    SizedBox(
                      width: 45,
                      child: Text(
                        '${state.$1}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Increase plural count',
                      onPressed: scope.lab.pluralCount.increment,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        context.tr('tasks', parameters: {'count': state.$1}),
                        key: const ValueKey('plural-output'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(context.tr('guests', parameters: {'count': state.$1})),
                const SizedBox(height: 10),
                Text(context.tr('fallbackNote')),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final gender in ['female', 'male', 'other'])
                      ChoiceChip(
                        label: Text(gender),
                        selected: state.$2 == gender,
                        onSelected: (_) => scope.lab.gender(gender),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr(
                    'summary',
                    parameters: {'count': state.$1, 'gender': state.$2},
                  ),
                ),
              ],
            ),
          ),
          DemoCard(
            title: 'MessageFormat playground',
            description:
                'Edit a pattern and use the count above. Errors are shown here rather than crashing the gallery.',
            code:
                "final message = IcuMessage(pattern);\nmessage.format(locale: 'en', parameters: {'count': 3});\n// Supports cardinal plural, exact selectors, offsets, select and nesting.",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: pattern,
                  minLines: 3,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'ICU pattern'),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    try {
                      final output = IcuMessage(pattern.text).format(
                        locale: Localizations.localeOf(
                          context,
                        ).toLanguageTag().replaceAll('-', '_'),
                        parameters: {'count': state.$1, 'gender': state.$2},
                      );
                      setState(() => customOutput = output);
                    } catch (error) {
                      setState(() => customOutput = error.toString());
                    }
                  },
                  child: const Text('Format message'),
                ),
                const SizedBox(height: 14),
                SelectableText(
                  customOutput ?? 'Your formatted message will appear here.',
                ),
              ],
            ),
          ),
          const Guidance(
            doText:
                'Pass numbers as numbers and provide an other branch. Use =0 for an exact zero case, since plural categories depend on locale.',
            dontText:
                'Do not concatenate translated fragments or assume one means exactly 1 in every language. Selectordinal and date/number skeletons are outside this formatter.',
          ),
        ],
      ),
    );
  }
}

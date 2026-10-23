import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import '../catalog.dart';
import '../branding.dart';
import '../controllers.dart';
import '../widgets.dart';
import 'state_pages.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});
  @override
  Widget build(BuildContext context) {
    final router = ActivityRouter.of(context);
    return GalleryPage(
      'overview',
      children: [
        Container(
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 600 ? 24 : 34,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF163F52), activityDeep, activityBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BUILD WITH ACTIVITY',
                      style: TextStyle(
                        color: Color(0xFFBCE8FF),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'A place to explore.\nA foundation to build on.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        letterSpacing: -.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Real Flutter examples for reactive state, navigation and localization.\nTry a control. Inspect the code. Make it yours.',
                      style: TextStyle(
                        color: Color(0xFFDCF2FF),
                        height: 1.7,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: activityDeep,
                          ),
                          onPressed: () => router.goNamed('start'),
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('Start exploring'),
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: activitySky),
                          ),
                          onPressed: () => router.goNamed('guidance'),
                          child: const Text("To-dos & don'ts"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (MediaQuery.sizeOf(context).width > 1050)
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .96),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .15),
                      ),
                    ),
                    child: const Center(child: ActivityLogo(size: 120)),
                  ),
                ),
            ],
          ),
        ),
        LayoutBuilder(
          builder: (_, constraints) => Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final entry in [
                ('19', 'Example sections', Icons.widgets_outlined),
                ('Live', 'Interactive previews', Icons.touch_app_outlined),
                ('Dart', 'Copyable source', Icons.code_rounded),
              ])
                SizedBox(
                  width: constraints.maxWidth < 650
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 32) / 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(
                            entry.$3,
                            color: Theme.of(context).colorScheme.primary,
                            size: 26,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.$1,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  entry.$2,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SectionTitle('Explore the building blocks'),
        LayoutBuilder(
          builder: (_, constraints) {
            final columns = constraints.maxWidth > 950
                ? 3
                : constraints.maxWidth > 600
                ? 2
                : 1;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final item in destinations.where(
                  (item) => [
                    'values',
                    'collections',
                    'navigation',
                    'localization',
                    'async',
                    'validation',
                  ].contains(item.id),
                ))
                  SizedBox(
                    width:
                        (constraints.maxWidth - (columns - 1) * 16) / columns,
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => router.goNamed(item.id),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: .09),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Icon(
                                  item.icon,
                                  color: item.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                              const SizedBox(height: 9),
                              Text(
                                item.summary,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(height: 1.6),
                              ),
                              const SizedBox(height: 18),
                              Pill(item.api),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const Guidance(
          doText:
              'Try the preview, open the source panel and watch the Activity console. Every section calls the public package API.',
          dontText:
              'Do not treat a demo session or bundled settings as a production backend. Use the checklist to plan integration and testing.',
        ),
      ],
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int step = 0;
  static const titles = [
    'Create a controller',
    'Register values',
    'Connect a consumer',
    'Update deliberately',
    'Release the owner',
  ];
  static const descriptions = [
    'A controller holds application logic and owns observable fields. Keep one instance for the lifetime of its feature.',
    'Return the exact fields in activities. Final initializers run before the base constructor registers them.',
    'Use ActiveView for a full view, Activity for shared context access, or ActivitySelector for a small subtree.',
    'Set a new value, use a type helper, or commit typed changeTo assignments. Direct collection.value mutation bypasses notifications.',
    'Views release their listeners. Their owner disposes the controller. Reset restores values and leaves the controller usable.',
  ];
  static const codes = [
    "class CounterController extends ActiveController {\n  final count = ActiveInt(0);\n  @override\n  Iterable<ActiveType> get activities => [count];\n}",
    "final controller = CounterController();\n// Create it once in your owning State, not inside build.\n// Late fields need register() and activities membership.",
    "ActivitySelector<CounterController, int>(\n  controller: controller,\n  select: (c) => c.count.value,\n  builder: (_, count, child) => Text('\$count'),\n);",
    "controller.count.increment();\ncontroller.count.updateValue((n) => n + 5);\ncontroller.activate([controller.count.changeTo(10)]);",
    "@override\nvoid dispose() {\n  unawaited(controller.dispose());\n  super.dispose();\n}",
  ];
  @override
  Widget build(BuildContext context) => GalleryPage(
    'start',
    children: [
      DemoCard(
        title: 'Your first Activity feature',
        description: 'A short path from a value to a working interface.',
        code: codes[step],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < titles.length; i++)
                  ChoiceChip(
                    label: Text('${i + 1}. ${titles[i]}'),
                    selected: step == i,
                    onSelected: (_) => setState(() => step = i),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(titles[step], style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(descriptions[step]),
            const SizedBox(height: 20),
            CodeBlock(codes[step]),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: step == 0 ? null : () => setState(() => step--),
                  child: const Text('Previous step'),
                ),
                FilledButton(
                  onPressed: step == 4 ? null : () => setState(() => step++),
                  child: const Text('Next step'),
                ),
              ],
            ),
          ],
        ),
      ),
      DemoCard(
        title: 'Try a real ActiveView',
        code: 'CounterView(activeController: sharedController);',
        child: CounterView(activeController: GalleryScope.of(context).lab),
      ),
      const Guidance(
        doText:
            'Start with one owner and a few named fields. Extract feature controllers as the application grows.',
        dontText:
            'Do not register a different instance, recreate controllers on every build or manually dispose a mounted Flutter State.',
      ),
    ],
  );
}

class _TemporaryController extends ActiveController {
  final count = ActiveInt(0);
  final List<ActiveType> lateValues = [];
  @override
  Iterable<ActiveType> get activities => [count, ...lateValues];
}

class LifecyclePage extends StatefulWidget {
  const LifecyclePage({super.key});
  @override
  State<LifecyclePage> createState() => _LifecyclePageState();
}

class _LifecyclePageState extends State<LifecyclePage> {
  _TemporaryController controller = _TemporaryController();
  ActiveInt? lateValue;
  bool showConsumer = true;
  String status = 'One feature owner. Consumers subscribe independently.';
  @override
  void dispose() {
    unawaited(controller.dispose());
    super.dispose();
  }

  Future<void> close() async {
    final current = controller;
    final first = current.dispose(), second = current.dispose();
    setState(
      () => status =
          'Disposing. Same cleanup future: ${identical(first, second)}. New writes are rejected.',
    );
    await Future.wait([first, second]);
    if (mounted && identical(current, controller)) {
      setState(
        () => status =
            'Disposed. Same cleanup future: ${identical(first, second)}. New writes are rejected.',
      );
    }
  }

  Future<void> pending() async {
    final current = controller;
    final future = current.activeAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      return 'Result preserved after disposal';
    }, isRunningKey: 'pending');
    await current.dispose();
    if (mounted) setState(() => status = 'Disposed while work is in flight…');
    final result = await future;
    if (mounted && identical(current, controller)) {
      setState(() => status = result);
    }
  }

  @override
  Widget build(BuildContext context) => GalleryPage(
    'lifecycle',
    children: [
      DemoCard(
        title: 'Ownership, reset & terminal disposal',
        code:
            "controller.resetAllActiveTypes(); // Still usable\nfinal cleanup = controller.dispose(); // Terminal; idempotent\nawait cleanup;\n// In-flight work retains its result; new writes are rejected.",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Pill(
              controller.isDisposed ? 'Disposed controller' : 'Live controller',
              color: controller.isDisposed ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 16),
            Text(status),
            const SizedBox(height: 16),
            if (showConsumer && !controller.isDisposed)
              ActivitySelector<_TemporaryController, int>(
                controller: controller,
                select: (c) => c.count.value,
                builder: (_, value, child) => Text(
                  'Consumer sees count: $value',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: controller.isDisposed
                      ? null
                      : controller.count.increment,
                  child: const Text('Update count'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => showConsumer = !showConsumer),
                  child: Text(
                    showConsumer ? 'Unmount consumer' : 'Mount consumer',
                  ),
                ),
                OutlinedButton(
                  onPressed: controller.isDisposed
                      ? null
                      : controller.resetAllActiveTypes,
                  child: const Text('Reset values'),
                ),
                OutlinedButton(
                  onPressed: controller.isDisposed ? null : close,
                  child: const Text('Dispose twice'),
                ),
                OutlinedButton(
                  onPressed: controller.isDisposed ? null : pending,
                  child: const Text('Dispose during work'),
                ),
                TextButton(
                  onPressed: () {
                    unawaited(controller.dispose());
                    setState(() {
                      controller = _TemporaryController();
                      lateValue = null;
                      status = 'A fresh controller is ready.';
                    });
                  },
                  child: const Text('Create fresh controller'),
                ),
              ],
            ),
          ],
        ),
      ),
      DemoCard(
        title: 'Late registration',
        description:
            'Register a value created later and include it in activities if it must reset.',
        code:
            "final lateValue = ActiveInt(7);\ncontroller.lateValues.add(lateValue);\ncontroller.register(lateValue);\nlateValue.increment();",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lateValue == null
                  ? 'No late value registered.'
                  : 'Registered value: ${lateValue!.value}',
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: controller.isDisposed
                  ? null
                  : () => setState(() {
                      if (lateValue == null) {
                        lateValue = ActiveInt(7);
                        controller.lateValues.add(lateValue!);
                        controller.register(lateValue!);
                      } else {
                        lateValue!.increment();
                      }
                    }),
              child: Text(
                lateValue == null
                    ? 'Register a late value'
                    : 'Increment late value',
              ),
            ),
          ],
        ),
      ),
      const Guidance(
        doText:
            'Keep cleanup at the owner boundary. Shared controllers can outlive independently mounted consumers.',
        dontText:
            'Do not reuse a disposed controller, expect automatic cancellation, or call a mounted State’s dispose yourself.',
      ),
    ],
  );
}

const checklistItems = [
  'Create one owner for each controller and router.',
  'Register reactive fields and name important events.',
  'Use immutable models and copied collection updates.',
  'Select only the values each widget needs.',
  'Handle loading, failure and disposal after async work.',
  'Test direct links, back navigation and async guards.',
  'Provide stable restoration IDs and test a fresh router.',
  'Verify locale assets, plural rules and fallback behavior.',
  'Cancel event/error listeners with their consumers.',
  'Validate external inputs and configuration.',
  'Test narrow screens, keyboard navigation and both themes.',
  'Run analysis, host/browser tests and device checks.',
];

class GuidancePage extends StatelessWidget {
  const GuidancePage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = GalleryScope.of(context).lab;
    return ActivitySelector<PlaygroundController, List<int>>(
      controller: c,
      select: (c) => c.checklist.snapshotValue,
      builder: (context, checked, _) => GalleryPage(
        'guidance',
        children: [
          DemoCard(
            title: 'Your integration to-do list',
            description:
                'Session-only checklist progress. Checking a box does not execute the check.',
            code:
                "if (checked.contains(index)) {\n  checked.remove(index);\n} else {\n  checked.add(index);\n}\n// checked is an ActiveList<int>.",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${checked.length} of ${checklistItems.length} complete',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: () => c.checklist.clear(),
                      child: const Text('Reset checklist'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: checked.length / checklistItems.length,
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < checklistItems.length; i++)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    title: Text(checklistItems[i]),
                    value: checked.contains(i),
                    onChanged: (_) {
                      if (checked.contains(i)) {
                        c.checklist.remove(i);
                      } else {
                        c.checklist.add(i);
                      }
                    },
                  ),
              ],
            ),
          ),
          const SectionTitle("Patterns to do — and not to do"),
          const Guidance(
            doText:
                'Create controllers once in State or an application service; dispose them from that owner.',
            dontText:
                'Do not allocate controllers in build or dispose a shared controller from a single consumer.',
          ),
          const Guidance(
            doText:
                'Use set, updateValue and collection helpers; compare .value or .equals for value equality.',
            dontText:
                'Do not mutate .value directly or expect equal-valued wrapper instances to be ==.',
          ),
          const Guidance(
            doText:
                'Use typed changeTo operations and immutable nested models.',
            dontText:
                'Do not assume batches roll back arbitrary setter side effects or deep-clone nested objects.',
          ),
          const Guidance(
            doText:
                'Keep guards idempotent and show recoverable errors; confirm exits when work is unsaved.',
            dontText:
                'Do not expose protected content before a guard resolves or rely on client guards for server authorization.',
          ),
          const Guidance(
            doText:
                'Use goBranch for independent histories and RestorableProperty for widget state.',
            dontText:
                'Do not confuse keeping a tab mounted with restoring a new process.',
          ),
          const Guidance(
            doText:
                'Translate full ICU messages with numeric arguments and other branches.',
            dontText:
                'Do not concatenate translated fragments or assume English plural rules apply everywhere.',
          ),
          const DemoCard(
            title: 'Know the boundaries',
            code: '// Use complementary application services for these needs.',
            child: Text(
              'Activity does not supply network transport, database persistence, cross-isolate event delivery, automatic request cancellation, or server authorization. ICU supports cardinal plural/select; ordinal and date/number skeletons need a separate formatter. Device restoration and browser history still need platform end-to-end checks.',
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final settings = GalleryScope.of(context).settings;
    return ActivitySelector<GallerySettings, (ThemeMode, int, Locale)>(
      controller: settings,
      select: (c) => (c.theme.value, c.accent.value, c.locale.value),
      builder: (context, state, child) => GalleryPage(
        'settings',
        children: [
          TextButton(
            onPressed: () =>
                ActivityRouter.of(context).goNamed('settings-privacy'),
            child: const Text('Support'),
          ),
          DemoCard(
            title: 'Material appearance',
            description:
                'Theme, accent and locale preferences use reactive values and restorable app properties.',
            code:
                "settings.theme(ThemeMode.dark);\nsettings.accent(1);\n// The app selector rebuilds MaterialApp with its ColorScheme.",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theme mode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: MediaQuery.sizeOf(context).width < 600
                          ? null
                          : const Icon(Icons.light_mode_outlined),
                      label: const Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: MediaQuery.sizeOf(context).width < 600
                          ? null
                          : const Icon(Icons.dark_mode_outlined),
                      label: const Text('Dark'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: MediaQuery.sizeOf(context).width < 600
                          ? null
                          : const Icon(Icons.brightness_auto_outlined),
                      label: const Text('System'),
                    ),
                  ],
                  selected: {settings.theme.value},
                  onSelectionChanged: (value) => settings.theme(value.first),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Accent color',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    for (var i = 0; i < accents.length; i++)
                      Tooltip(
                        message: [
                          'Ocean blue',
                          'Sky blue',
                          'Deep blue',
                          'Harbor',
                          'Midnight',
                        ][i],
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => settings.accent(i),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accents[i],
                              shape: BoxShape.circle,
                            ),
                            child: settings.accent.value == i
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 22,
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Locale preview',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
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
                            settings.locale.value.languageCode == entry.$1,
                        onSelected: (_) => settings.locale(Locale(entry.$1)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Gallery explanations stay in English. Localization examples and built-in Material controls follow the selected locale.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

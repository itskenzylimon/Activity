import 'dart:async';
import 'dart:convert';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import '../controllers.dart';
import '../widgets.dart';
import '../recipes/typed_values.dart';

class ValuesPage extends StatelessWidget {
  const ValuesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = GalleryScope.of(context).lab;
    return ActivitySelector<
      PlaygroundController,
      (int, double, bool, String?, String)
    >(
      controller: c,
      select: (c) => (
        c.count.value,
        c.progress.value,
        c.enabled.value,
        c.optional.value,
        c.text.value,
      ),
      builder: (context, values, _) => GalleryPage(
        'values',
        children: [
          DemoCard(
            title: 'Numbers that notify',
            description:
                'Increment, transform and clamp a value. The display rebuilds through a selector.',
            code:
                "final count = ActiveInt(0);\n// Register count in your controller's activities.\ncount.increment();\ncount.updateValue((n) => n + 5);\ncount.clampTo(0, 100);",
            child: ResponsivePair(
              first: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${values.$1}',
                    key: const ValueKey('counter-value'),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Integer · ${c.count.isEven ? 'even' : 'odd'} · ${c.count.isPositive
                        ? 'positive'
                        : c.count.isZero
                        ? 'zero'
                        : 'negative'}',
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        key: const ValueKey('increment'),
                        onPressed: c.count.increment,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Increment'),
                      ),
                      OutlinedButton(
                        onPressed: c.count.decrement,
                        child: const Text('−1'),
                      ),
                      OutlinedButton(
                        onPressed: () => c.count.updateValue((n) => n + 5),
                        child: const Text('+5'),
                      ),
                      TextButton(
                        onPressed: c.count.reset,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
              second: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${(values.$2 * 100).round()}%',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Slider(
                    value: values.$2,
                    onChanged: (value) => c.progress(value),
                  ),
                  const Text(
                    'ActiveDouble → a standard Material Slider',
                    style: TextStyle(fontSize: 12),
                  ),
                  TextButton(
                    onPressed: () => c.progress.clampTo(.25, .75),
                    child: const Text('Clamp between 25% and 75%'),
                  ),
                ],
              ),
            ),
          ),
          DemoCard(
            title: 'Booleans & nullable values',
            code:
                "enabled.toggle();\noptional.setIfNull(() => 'Initialized once');\nfinal label = optional.valueOr('No value');\noptional(null);",
            child: ResponsivePair(
              first: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable the example'),
                subtitle: Text('ActiveBool: ${values.$3}'),
                value: values.$3,
                onChanged: (_) => c.enabled.toggle(),
              ),
              second: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Pill(c.optional.isNull ? 'null' : 'String'),
                  const SizedBox(height: 10),
                  Text(c.optional.valueOr('No value yet')),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            c.optional.setIfNull(() => 'Initialized once'),
                        child: const Text('Initialize if null'),
                      ),
                      TextButton(
                        onPressed: () => c.optional(null),
                        child: const Text('Set null'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DemoCard(
            title: 'Reactive text transformations',
            code:
                "text.trimValue();\ntext.append('!');\ntext.prepend('Hello ');\ntext.replaceText('Activity', 'Flutter');\nfinal numeric = text.tryInt;",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  values.$5,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: () => c.text.append('!'),
                      child: const Text('Append !'),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          c.text.replaceText('Activity', 'Flutter'),
                      child: const Text('Replace text'),
                    ),
                    TextButton(
                      onPressed: c.text.reset,
                      child: const Text('Restore original'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const OptionalProfileDemo(),
          const Guidance(
            doText:
                'Register the exact wrapper instance and use typed setters or helpers so listeners receive changes.',
            dontText:
                'Do not create a new controller inside build, or expect a raw mutable value to notify automatically.',
          ),
        ],
      ),
    );
  }
}

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});
  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final input = TextEditingController();
  String filter = 'all';
  int page = 1;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = GalleryScope.of(context).lab;
    return ActivitySelector<
      PlaygroundController,
      (List<TaskItem>, Map<String, int>)
    >(
      controller: c,
      select: (c) => (c.tasks.snapshotValue, c.metrics.snapshotValue),
      builder: (context, values, _) {
        final filtered = values.$1
            .where(
              (task) =>
                  filter == 'all' ||
                  (filter == 'done' ? task.done : !task.done),
            )
            .toList();
        final total = (filtered.length / 4).ceil();
        final current = page.clamp(1, total < 1 ? 1 : total);
        final visible = ActiveList<TaskItem>(
          filtered,
        ).paginate(pageNumber: current, pageSize: 4);
        final done = c.tasks.groupBy((task) => task.done)[true]?.length ?? 0;
        return GalleryPage(
          'collections',
          children: [
            DemoCard(
              title: 'A reactive task list',
              description:
                  'These tasks live in ActiveList<TaskItem>. Toggle, add, filter, sort or remove a row.',
              code:
                  "tasks.add(TaskItem(id, title));\ntasks.replaceAt(index, task.copyWith(done: true));\ntasks.sort((a, b) => a.title.compareTo(b.title));\nfinal groups = tasks.groupBy((task) => task.done);\nfinal page = tasks.paginate(pageNumber: 1, pageSize: 4);",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const ValueKey('task-input'),
                          controller: input,
                          onSubmitted: (_) {
                            c.addTask(input.text);
                            input.clear();
                            setState(() => page = 1);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Add a task to this example',
                            labelText: 'New task',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: () {
                          c.addTask(input.text);
                          input.clear();
                          setState(() => page = 1);
                        },
                        child: const Text('Add task'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final entry in [
                        ('all', 'All'),
                        ('pending', 'Pending'),
                        ('done', 'Completed'),
                      ])
                        ChoiceChip(
                          label: Text(entry.$2),
                          selected: filter == entry.$1,
                          onSelected: (_) => setState(() {
                            filter = entry.$1;
                            page = 1;
                          }),
                        ),
                      const SizedBox(width: 6),
                      Pill('$done / ${values.$1.length} completed'),
                      TextButton.icon(
                        onPressed: () =>
                            c.tasks.sort((a, b) => a.title.compareTo(b.title)),
                        icon: const Icon(Icons.sort_by_alpha, size: 18),
                        label: const Text('Sort'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (visible.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(
                        child: Text(
                          'No tasks match this filter. Add one or choose All.',
                        ),
                      ),
                    ),
                  for (final task in visible)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Checkbox(
                        value: task.done,
                        onChanged: (_) => c.toggleTask(task),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text('Task #${task.id}'),
                      trailing: IconButton(
                        tooltip: 'Delete ${task.title}',
                        onPressed: () => c.tasks.remove(task),
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ),
                  const Divider(),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Page $current of ${total < 1 ? 1 : total}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      IconButton(
                        tooltip: 'Previous task page',
                        onPressed: current > 1
                            ? () => setState(() => page = current - 1)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        tooltip: 'Next task page',
                        onPressed: current < total
                            ? () => setState(() => page = current + 1)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                      TextButton(
                        onPressed: () {
                          c.tasks.reset();
                          setState(() {
                            filter = 'all';
                            page = 1;
                          });
                        },
                        child: const Text('Reset list'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            DemoCard(
              title: 'Map operations & snapshots',
              code:
                  "metrics.setEntry('builds', 5);\nmetrics.putIfAbsent('visits', () => 1);\nmetrics.update('updates', (value) => value + 1);\nfinal frozen = metrics.snapshotValue;",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final entry in values.$2.entries)
                        SizedBox(
                          width: 150,
                          child: ValueTile(entry.key, '${entry.value}'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () =>
                            c.metrics.update('updates', (value) => value + 1),
                        child: const Text('Record update'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            c.metrics.putIfAbsent('visits', () => 1),
                        child: const Text('Put if absent'),
                      ),
                      TextButton(
                        onPressed: c.metrics.reset,
                        child: const Text('Reset map'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Guidance(
              doText:
                  'Use immutable list items, wrapper mutation helpers and snapshotValue when exposing collection data.',
              dontText:
                  'Do not mutate tasks.value or nested fields directly. Shallow snapshots do not clone nested objects.',
            ),
          ],
        );
      },
    );
  }
}

class ModelsPage extends StatelessWidget {
  const ModelsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = GalleryScope.of(context).lab;
    return ActivitySelector<PlaygroundController, (Profile, int, String)>(
      controller: c,
      select: (c) => (c.profile.value, c.count.value, c.text.value),
      builder: (context, value, _) => GalleryPage(
        'models',
        children: [
          DemoCard(
            title: 'Immutable models with copyWith',
            code:
                "final profile = ActiveModel(const Profile('Kenzy', 'Developer', 120));\n// Include profile in activities.\nprofile.updateValue((user) => user.copyWith(points: user.points + 10));\nprofile.reset();",
            child: ResponsivePair(
              first: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      value.$1.name
                          .split(' ')
                          .map((word) => word[0])
                          .take(2)
                          .join(),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value.$1.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text('${value.$1.role} · ${value.$1.points} points'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilledButton(
                              onPressed: () => c.profile.updateValue(
                                (user) =>
                                    user.copyWith(points: user.points + 10),
                              ),
                              child: const Text('Award 10 points'),
                            ),
                            TextButton(
                              onPressed: c.profile.reset,
                              child: const Text('Reset model'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              second: CodeBlock(
                const JsonEncoder.withIndent('  ').convert(value.$1.toJson()),
              ),
            ),
          ),
          DemoCard(
            title: 'Typed batch updates',
            description:
                'One call commits multiple correctly typed assignments with one event list. Watch the console.',
            code:
                "controller.activate([\n  count.changeTo(10),\n  text.changeTo('Updated together'),\n  profile.changeTo(profile.value.copyWith(role: 'Maintainer')),\n]);",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ValueTile('Count', '${value.$2}'),
                    ValueTile('Text', value.$3),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => c.activate([
                        c.count.changeTo(10),
                        c.text.changeTo('Updated together'),
                        c.profile.changeTo(
                          c.profile.value.copyWith(role: 'Maintainer'),
                        ),
                      ]),
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Commit typed batch'),
                    ),
                    OutlinedButton(
                      onPressed: () => showConsole(context),
                      child: const Text('Inspect changes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Guidance(
            doText:
                'Replace a model with a new immutable instance. Use changeTo for compile-time typed batch values.',
            dontText:
                'Do not mutate model fields in place or expect arbitrary custom setter side effects to roll back as a database transaction.',
          ),
        ],
      ),
    );
  }
}

class ViewsPage extends StatelessWidget {
  const ViewsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = GalleryScope.of(context).lab;
    return GalleryPage(
      'views',
      children: [
        DemoCard(
          title: 'See selective rebuilding',
          description:
              'Change count or text and compare the independent selector build counters.',
          code:
              "ActivitySelector<PlaygroundController, int>(\n  controller: controller,\n  select: (c) => c.count.value,\n  builder: (_, value, child) => Text('\$value'),\n);",
          child: Column(
            children: [
              ResponsivePair(
                first: SelectorProbe(controller: c, count: true),
                second: SelectorProbe(controller: c, count: false),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: c.count.increment,
                    child: const Text('Change count'),
                  ),
                  OutlinedButton(
                    onPressed: () => c.text.append('!'),
                    child: const Text('Change text'),
                  ),
                ],
              ),
            ],
          ),
        ),
        DemoCard(
          title: 'ActiveView / ActiveState',
          description:
              'A full view listens to its controller and cancels only its own subscription.',
          code:
              "class CounterView extends ActiveView<PlaygroundController> {\n  CounterView({required super.activeController});\n  @override\n  ActiveState<CounterView, PlaygroundController> createActivity()\n    => CounterState(activeController);\n}\n// State builds from activeController.count.value.",
          child: CounterView(activeController: c),
        ),
        const Guidance(
          doText:
              'Select scalars or immutable Dart records. Share a controller by passing its existing instance through Activity or your view.',
          dontText:
              'Do not select a mutable list by reference and assume in-place changes will compare differently. Never manually dispose mounted State.',
        ),
      ],
    );
  }
}

class SelectorProbe extends StatefulWidget {
  final PlaygroundController controller;
  final bool count;
  const SelectorProbe({
    super.key,
    required this.controller,
    required this.count,
  });
  @override
  State<SelectorProbe> createState() => _SelectorProbeState();
}

class _SelectorProbeState extends State<SelectorProbe> {
  int builds = 0;
  @override
  Widget build(BuildContext context) =>
      ActivitySelector<PlaygroundController, Object>(
        controller: widget.controller,
        select: (c) => widget.count ? c.count.value : c.text.value,
        builder: (_, value, child) {
          builds++;
          return ValueTile(
            '${widget.count ? 'Count' : 'Text'} selector · $builds builds',
            '$value',
            icon: widget.count ? Icons.numbers : Icons.text_fields,
          );
        },
      );
}

class CounterView extends ActiveView<PlaygroundController> {
  const CounterView({super.key, required super.activeController});
  @override
  ActiveState<CounterView, PlaygroundController> createActivity() =>
      _CounterViewState(activeController);
}

class _CounterViewState extends ActiveState<CounterView, PlaygroundController> {
  _CounterViewState(super.activeController);
  int builds = 0;
  @override
  Widget build(BuildContext context) {
    builds++;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Whole-view builds: $builds · Count: ${activeController.count.value}',
          ),
        ),
        IconButton(
          tooltip: 'Increment from ActiveView',
          onPressed: activeController.count.increment,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class AsyncPage extends StatelessWidget {
  const AsyncPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = GalleryScope.of(context).lab;
    return ActivitySelector<
      PlaygroundController,
      (bool, List<String>, int, String)
    >(
      controller: c,
      select: (c) =>
          (c.actively, c.activeTasks, c.completed.value, c.asyncMessage.value),
      builder: (context, state, _) => GalleryPage(
        'async',
        children: [
          DemoCard(
            title: 'Concurrent work with correct busy state',
            description:
                'Run two operations with the same key. Completing one does not make the other idle.',
            code:
                "await controller.activeAsync(fetch, isRunningKey: 'load');\n// Overlapping 'load' calls are reference counted.\nif (controller.isDisposed) return;\nresult(awaitedValue);",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ValueTile(
                      'Status',
                      state.$1 ? 'Working' : 'Idle',
                      icon: state.$1
                          ? Icons.hourglass_top
                          : Icons.check_circle_outline,
                    ),
                    ValueTile('Completed operations', '${state.$3}'),
                  ],
                ),
                const SizedBox(height: 18),
                if (state.$1)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 18),
                    child: LinearProgressIndicator(),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () => unawaited(c.runTask('load')),
                      child: const Text('Run task'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        unawaited(c.runTask('shared', milliseconds: 700));
                        unawaited(c.runTask('shared', milliseconds: 1700));
                      },
                      child: const Text('Run two with shared key'),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          unawaited(c.runTask('failing', fail: true)),
                      child: const Text('Simulate failure'),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(state.$4),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (state.$2.isEmpty) const Pill('No running keys'),
                    for (final key in state.$2) Pill(key),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => showConsole(context),
                  icon: const Icon(Icons.terminal, size: 18),
                  label: const Text('Inspect state & error events'),
                ),
              ],
            ),
          ),
          const Guidance(
            doText:
                'Use try/finally task bookkeeping, show recovery states and check isDisposed after awaited work before updating values.',
            dontText:
                'Do not treat a single task key as a cancellation token. Disposing the controller does not cancel your network request.',
          ),
        ],
      ),
    );
  }
}

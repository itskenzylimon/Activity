import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter/material.dart';
import '../console.dart';
import '../widgets.dart';
import '../result_terminal.dart';
import 'workbench_controller.dart';

/// Stateful shell keeps this feature mounted between sections. The feature owns
/// and disposes its controller, while the console is borrowed from the app.
class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key, required this.console});
  final GalleryConsole console;
  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  late final controller = WorkbenchController(widget.console);
  final draft = TextEditingController();
  @override
  void dispose() {
    draft.dispose();
    unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GalleryPage(
    'recipes',
    children: [
      const Text(
        'One contextual workbench combines form validation, preserved drafts, derived filtering, sorting and paginated asynchronous work. Data is simulated and in memory; the database recipe uses real SQLite.',
      ),
      DemoCard(
        title: 'Reactive form + derived search + asynchronous pages',
        description:
            'Run competing loads, cancel a result, fail then retry. Existing rows and draft survive failure and navigation.',
        code: '''import 'package:activity/activity.dart';
// Full working controller and widget are in the source tabs.
await controller.load();
await controller.load(next: true);
controller.query('record 1'); // Derived locally; no independent cached list.
controller.cancel();          // Invalidates late results, not transport I/O.
await controller.retry();
// Feature owner: await controller.dispose();''',
        child:
            ActivitySelector<
              WorkbenchController,
              (String, String, List<String>, bool, bool, Duration?)
            >(
              controller: controller,
              select: (c) => (
                c.draft.value,
                c.status.value,
                c.visible,
                c.busy.value,
                c.descending.value,
                c.elapsed.value,
              ),
              builder: (context, state, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const ValueKey('recipe-draft'),
                    controller: draft,
                    onChanged: controller.draft.call,
                    decoration: InputDecoration(
                      labelText: 'Preserved draft',
                      helperText: '3+ characters',
                      errorText: state.$1.isEmpty
                          ? null
                          : controller.validation,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: controller.validation == null
                        ? () {
                            controller.saveDraft();
                            draft.clear();
                          }
                        : null,
                    child: const Text('Add validated draft'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const ValueKey('recipe-search'),
                    onChanged: controller.query.call,
                    decoration: const InputDecoration(
                      labelText: 'Filter loaded records',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Descending sort'),
                    value: state.$5,
                    onChanged: controller.descending.call,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () => controller.load(),
                        child: const Text('Load first page'),
                      ),
                      OutlinedButton(
                        onPressed: state.$4
                            ? null
                            : () => controller.load(next: true),
                        child: const Text('Load next page'),
                      ),
                      OutlinedButton(
                        onPressed: () => controller.load(fail: true),
                        child: const Text('Simulate request error'),
                      ),
                      OutlinedButton(
                        onPressed: state.$4 ? controller.cancel : null,
                        child: const Text('Cancel pending result'),
                      ),
                      OutlinedButton(
                        onPressed: controller.canRetry
                            ? controller.retry
                            : null,
                        child: const Text('Retry request'),
                      ),
                    ],
                  ),
                  if (state.$4) const LinearProgressIndicator(),
                  ResultTerminal(
                    status: state.$2,
                    elapsed: state.$6,
                    output: {
                      'page': controller.page.value,
                      'rows': state.$3,
                      'draftRetained': state.$1.isNotEmpty,
                      'runningKeys': controller.activeTasks,
                    },
                  ),
                ],
              ),
            ),
      ),
      const Guidance(
        doText:
            'Keep the query and rows as source state; derive filtered results. Invalidate stale responses after cancellation or newer work and check disposal after awaits.',
        dontText:
            'Do not assume activeAsync cancels I/O or persistence happens automatically. A view must not close a controller borrowed from another owner.',
      ),
      const SectionTitle('Related complete recipes'),
      const Text(
        'Events & replay owns and cancels every subscription. Navigation & guards shows asynchronous authentication and typed detail results. Appearance includes nested privacy settings; Localization & ICU combines plural and select. Their source tabs include the actual views and shared controllers. app.dart supplies routes, localization delegates and owner disposal.',
      ),
    ],
  );
}

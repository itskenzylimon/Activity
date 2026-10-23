import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String sourceForPage(String id) => switch (id) {
  'recipes' => 'lib/gallery/recipes/workbench.dart',
  'database' => 'lib/gallery/recipes/database_page.dart',
  'values' ||
  'collections' ||
  'models' ||
  'views' ||
  'async' => 'lib/gallery/pages/state_pages.dart',
  'events' ||
  'navigation' ||
  'restoration' ||
  'localization' => 'lib/gallery/pages/service_pages.dart',
  'validation' ||
  'environment' ||
  'helpers' => 'lib/gallery/pages/utility_pages.dart',
  _ => 'lib/gallery/pages/learning_pages.dart',
};
String controllerForPage(String source) => source.contains('/recipes/')
    ? source
          .replaceAll('workbench.dart', 'workbench_controller.dart')
          .replaceAll('database_page.dart', 'database_controller.dart')
    : 'lib/gallery/controllers.dart';

class SourceLocation extends InheritedWidget {
  const SourceLocation({super.key, required this.page, required super.child});
  final String page;
  static String of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SourceLocation>()?.page ??
      'lib/gallery/app.dart';
  @override
  bool updateShouldNotify(SourceLocation oldWidget) => page != oldWidget.page;
}

/// Loads the actual shipped Dart file. No drift between displayed and compiled code.
class SourcePanel extends StatefulWidget {
  const SourcePanel(this.path, {super.key});
  final String path;
  @override
  State<SourcePanel> createState() => _SourcePanelState();
}

class _SourcePanelState extends State<SourcePanel> {
  late Future<String> source = rootBundle.loadString(widget.path);
  @override
  void didUpdateWidget(SourcePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      source = rootBundle.loadString(widget.path);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: source,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Source unavailable: ${snapshot.error}');
      }
      if (!snapshot.hasData) return const LinearProgressIndicator();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(widget.path)),
              IconButton(
                tooltip: 'Copy complete source',
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: snapshot.data!)),
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
          const Text(
            'Complete compiled file. Follow its relative imports in the linked gallery source; app.dart owns shared setup and disposal.',
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              child: SelectableText(
                snapshot.data!,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
        ],
      );
    },
  );
}

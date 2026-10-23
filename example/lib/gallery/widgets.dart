import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'catalog.dart';
import 'branding.dart';
import 'support_links.dart';
import 'source_panel.dart';

const accents = [
  activityBlue,
  activitySky,
  activityDeep,
  Color(0xFF126B8C),
  Color(0xFF123F52),
];

class GalleryPage extends StatelessWidget {
  final String id;
  final List<Widget> children;
  const GalleryPage(this.id, {super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    final item = destinationFor(id);
    return SourceLocation(
      page: sourceForPage(id),
      child: SelectionArea(
        child: ListView(
          key: PageStorageKey(id),
          padding: EdgeInsets.all(
            MediaQuery.sizeOf(context).width < 700 ? 20 : 36,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity gallery  /  ${item.group.toLowerCase()}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1,
                              ),
                        ),
                        Pill(item.api),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.summary,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ...children.expand(
                      (child) => [child, const SizedBox(height: 22)],
                    ),
                    const SupportLinks(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color? color;
  const Pill(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) {
    final ink = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ink.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: ink, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class DemoCard extends StatefulWidget {
  final String title, description, code;
  final Widget child;
  const DemoCard({
    super.key,
    required this.title,
    required this.code,
    required this.child,
    this.description = '',
  });
  @override
  State<DemoCard> createState() => _DemoCardState();
}

class _DemoCardState extends State<DemoCard> {
  bool source = false;
  String tab = 'Preview';
  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 12, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          widget.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: source ? 'Show preview' : 'Show source code',
                onPressed: () => setState(() {
                  source = !source;
                  tab = source ? 'API' : 'Preview';
                }),
                icon: Icon(
                  source ? Icons.visibility_outlined : Icons.code_rounded,
                  size: 20,
                ),
              ),
              IconButton(
                tooltip: 'Copy API fragment',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: widget.code));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Source code copied')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final label in [
                'Preview',
                'API',
                'View code',
                'Model / Controller',
                'App setup',
              ])
                TextButton(
                  onPressed: () => setState(() {
                    tab = label;
                    source = label != 'Preview';
                  }),
                  child: Text(label),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (tab == 'API') ...[
                const Text(
                  'API fragment · full imports, owner and lifecycle are in the source tabs.',
                ),
                CodeBlock(widget.code),
              ],
              if (tab == 'App setup') ...[
                const SourcePanel('lib/main.dart'),
                const SourcePanel('lib/gallery/app.dart'),
              ],
              if (tab == 'View code') SourcePanel(SourceLocation.of(context)),
              if (tab == 'Model / Controller')
                SourcePanel(controllerForPage(SourceLocation.of(context))),
              if (tab != 'Preview')
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Live example and result'),
                ),
              KeyedSubtree(
                key: const ValueKey('live-preview'),
                child: widget.child,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class CodeBlock extends StatelessWidget {
  final String code;
  const CodeBlock(this.code, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.all(18),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: SingleChildScrollView(
        child: SelectableText(
          code.trim(),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            height: 1.7,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 4),
    child: Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

class ResponsivePair extends StatelessWidget {
  final Widget first, second;
  const ResponsivePair({super.key, required this.first, required this.second});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) => constraints.maxWidth < 720
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [first, const SizedBox(height: 16), second],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 20),
              Expanded(child: second),
            ],
          ),
  );
}

class Guidance extends StatelessWidget {
  final String doText, dontText;
  const Guidance({super.key, required this.doText, required this.dontText});
  @override
  Widget build(BuildContext context) => ResponsivePair(
    first: _tile(context, true, doText),
    second: _tile(context, false, dontText),
  );
  Widget _tile(BuildContext context, bool positive, String message) {
    final color = positive ? const Color(0xFF087F5B) : const Color(0xFFBE344A);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positive
                ? Icons.check_circle_outline
                : Icons.do_not_disturb_on_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  positive ? 'Do' : "Don't",
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ValueTile extends StatelessWidget {
  final String label, value;
  final IconData? icon;
  const ValueTile(this.label, this.value, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

void showConsole(BuildContext context) {
  // Shell owns dock visibility; opening it never installs extra subscriptions.
  ConsoleDockRequest.of(context)?.call();
}

class ConsoleDockRequest extends InheritedWidget {
  const ConsoleDockRequest({
    super.key,
    required this.open,
    required super.child,
  });
  final VoidCallback open;
  static VoidCallback? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ConsoleDockRequest>()?.open;
  @override
  bool updateShouldNotify(ConsoleDockRequest oldWidget) => false;
}

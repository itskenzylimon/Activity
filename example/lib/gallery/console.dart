import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'branding.dart';
import 'package:flutter/services.dart';

const diagnosticsRequested = bool.fromEnvironment('ACTIVITY_DIAGNOSTICS');

class ConsoleEntry {
  ConsoleEntry(this.source, this.message, {this.error = false, this.elapsed})
    : time = DateTime.now();
  final DateTime time;
  final String source, message;
  final bool error;
  final Duration? elapsed;
  String get line =>
      '${time.toIso8601String()} [$source] $message'
      '${elapsed == null ? '' : ' (${elapsed!.inMicroseconds / 1000} ms)'}';
}

/// Example diagnostics only: never capture values, query strings or error payloads.
/// Release builds cannot enable this console with a dart-define.
class GalleryConsole extends ValueNotifier<List<ConsoleEntry>> {
  GalleryConsole({bool enabled = diagnosticsRequested})
    : enabled = kDebugMode && enabled,
      super(const []);
  bool enabled;
  bool _closed = false;
  final List<(ActiveController, StreamSubscription)> _subscriptions = [];
  void configure(bool value) {
    enabled = kDebugMode && value;
    if (!enabled) this.value = const [];
    notifyListeners();
  }

  void add(
    String source,
    Object message, {
    bool error = false,
    Duration? elapsed,
  }) {
    if (!kDebugMode || !enabled || _closed) return;
    value = List.unmodifiable(
      [
        ConsoleEntry(
          source,
          message.toString(),
          error: error,
          elapsed: elapsed,
        ),
        ...value,
      ].take(80),
    );
  }

  void watch(ActiveController controller, String source) {
    _subscriptions.add((
      controller,
      controller.addOnStateChangedListener((events) {
        add(
          'State',
          '$source: ${events.length} notification(s); payload omitted',
        );
      }),
    ));
    _subscriptions.add((
      controller,
      controller.onActiveErrorListener((event) {
        add(
          'Errors',
          '$source: operation failed; inspect the local example for recovery',
          error: true,
        );
      }),
    ));
  }

  @override
  void dispose() {
    _closed = true;
    for (final (controller, subscription) in _subscriptions) {
      unawaited(controller.cancelSubscription(subscription));
    }
    super.dispose();
  }
}

/// Bottom dock; actions and close remain outside the horizontal tab scroller.
class DeveloperConsole extends StatefulWidget {
  const DeveloperConsole({
    super.key,
    required this.console,
    required this.onClose,
  });
  final GalleryConsole console;
  final VoidCallback onClose;
  @override
  State<DeveloperConsole> createState() => _DeveloperConsoleState();
}

class _DeveloperConsoleState extends State<DeveloperConsole> {
  String category = 'All';
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xff111820),
    child: DefaultTextStyle(
      style: const TextStyle(
        color: Color(0xffd7e3ee),
        fontFamily: 'monospace',
        fontSize: 12,
      ),
      child: ValueListenableBuilder<List<ConsoleEntry>>(
        valueListenable: widget.console,
        builder: (context, entries, _) {
          final visible = entries
              .where((e) => category == 'All' || e.source == category)
              .toList();
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final tab in [
                            'All',
                            'State',
                            'Events',
                            'Navigation',
                            'Operations',
                            'Errors',
                          ])
                            TextButton(
                              onPressed: () => setState(() => category = tab),
                              child: Text(
                                tab,
                                style: TextStyle(
                                  color: category == tab
                                      ? activitySky
                                      : Colors.white70,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy console output',
                    color: Colors.white70,
                    onPressed: () => Clipboard.setData(
                      ClipboardData(
                        text: visible.map((e) => e.line).join('\n'),
                      ),
                    ),
                    icon: const Icon(Icons.copy, size: 18),
                  ),
                  IconButton(
                    tooltip: 'Clear console',
                    color: Colors.white70,
                    onPressed: () => widget.console.value = const [],
                    icon: const Icon(Icons.delete_outline, size: 18),
                  ),
                  IconButton(
                    tooltip: 'Close console',
                    color: Colors.white,
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              if (kDebugMode)
                SizedBox(
                  height: 32,
                  child: Row(
                    children: [
                      Checkbox(
                        value: widget.console.enabled,
                        onChanged: (v) => widget.console.configure(v ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'Opt-in diagnostics · metadata only · last 80 entries',
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Diagnostics disabled in release builds'),
                ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(
                        child: Text(
                          kDebugMode
                              ? 'Enable diagnostics, then run an example. Payloads are omitted.'
                              : 'Run a debug build to inspect development diagnostics.',
                        ),
                      )
                    : ListView.builder(
                        itemCount: visible.length,
                        padding: const EdgeInsets.all(12),
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: SelectableText(
                            visible[i].line,
                            style: TextStyle(
                              color: visible[i].error
                                  ? Colors.redAccent
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

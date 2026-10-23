import 'dart:async';
import 'package:activity/activity.dart';
import '../console.dart';

/// Feature-owned controller. A generation token rejects stale results; it does
/// not cancel transport I/O. Use your HTTP client's cancellation API as well.
class WorkbenchController extends ActiveController {
  WorkbenchController(this.console, {this.fetch = simulatedPage});
  final GalleryConsole console;
  final Future<List<String>> Function(String query, int page, bool fail) fetch;
  final draft = ActiveString('');
  final query = ActiveString('');
  final descending = ActiveBool(false);
  final rows = ActiveList<String>([]);
  final status = ActiveString('Empty · load the first page');
  final page = ActiveInt(0);
  final busy = ActiveBool(false);
  final elapsed = ActiveType<Duration?>(null);
  int _generation = 0;
  bool _lastFailure = false;
  @override
  Iterable<ActiveType> get activities => [
    draft,
    query,
    descending,
    rows,
    status,
    page,
    busy,
    elapsed,
  ];
  String? get validation =>
      draft.value.trim().length < 3 ? 'Enter at least 3 characters.' : null;
  List<String> get visible {
    final result =
        rows.value
            .where((s) => s.toLowerCase().contains(query.value.toLowerCase()))
            .toList()
          ..sort();
    return descending.value ? result.reversed.toList() : result;
  }

  static Future<List<String>> simulatedPage(
    String query,
    int page,
    bool fail,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (fail) throw StateError('Simulated service failure');
    // Three pages, then an empty page. Filtering is deliberately derived locally.
    return page > 3
        ? []
        : List.generate(5, (i) => 'Record ${(page - 1) * 5 + i + 1}');
  }

  Future<void> load({bool next = false, bool fail = false}) async {
    final token = ++_generation;
    final target = next ? page.value + 1 : 1;
    _lastFailure = fail;
    busy(true);
    status('Loading page $target');
    final watch = Stopwatch()..start();
    try {
      final incoming = await activeAsync(
        () => fetch(query.value, target, fail),
        isRunningKey: 'page',
      );
      if (isDisposed || token != _generation) return;
      if (next) {
        rows.addAll(incoming);
      } else {
        rows.replaceAll(incoming);
      }
      page(target);
      _lastFailure = false;
      status(incoming.isEmpty ? 'Empty page · no more results' : 'Ready');
      console.add(
        'Operations',
        'Page loaded (${incoming.length} records)',
        elapsed: watch.elapsed,
      );
    } catch (_) {
      if (isDisposed || token != _generation) return;
      _lastFailure = true;
      status('Error · existing rows and draft retained. Retry to recover.');
      console.add(
        'Errors',
        'Page failed; existing state retained',
        error: true,
        elapsed: watch.elapsed,
      );
    } finally {
      if (!isDisposed && token == _generation) {
        busy(false);
        elapsed(watch.elapsed);
      }
    }
  }

  Future<void> retry() => load(fail: false);
  bool get canRetry => _lastFailure && !busy.value;
  void cancel() {
    ++_generation;
    _lastFailure = false;
    busy(false);
    status('Canceled · late response ignored; transport may still finish');
    console.add('Operations', 'Pending result invalidated');
  }

  void saveDraft() {
    if (validation != null) {
      status(validation!);
      return;
    }
    rows.add(draft.value.trim());
    draft('');
    status('Draft added to the in-memory list');
  }

  @override
  Future<void> dispose() {
    ++_generation;
    return super.dispose();
  }
}

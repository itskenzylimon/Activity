import 'dart:async';
import 'package:activity/activity.dart';
import 'package:activity/core/src/errors.dart';
import 'package:flutter/material.dart';
import 'console.dart';
export 'console.dart';

class GallerySettings extends ActiveController {
  final theme = ActiveType<ThemeMode>(ThemeMode.light);
  final locale = ActiveType<Locale>(const Locale('en'));
  final accent = ActiveInt(0);
  final signedIn = ActiveBool(false);
  @override
  Iterable<ActiveType> get activities => [theme, locale, accent, signedIn];
}

class TaskItem {
  final int id;
  final String title;
  final bool done;
  const TaskItem(this.id, this.title, {this.done = false});
  TaskItem copyWith({String? title, bool? done}) =>
      TaskItem(id, title ?? this.title, done: done ?? this.done);
}

class Profile {
  final String name, role;
  final int points;
  const Profile(this.name, this.role, this.points);
  Profile copyWith({String? name, String? role, int? points}) =>
      Profile(name ?? this.name, role ?? this.role, points ?? this.points);
  Map<String, Object> toJson() => {
    'name': name,
    'role': role,
    'points': points,
  };
}

class PlaygroundController extends ActiveController {
  final count = ActiveInt(0, typeName: 'count');
  final progress = ActiveDouble(0.4, typeName: 'progress');
  final enabled = ActiveBool(true, typeName: 'enabled');
  final optional = ActiveType<String?>(null, typeName: 'optional');
  final text = ActiveString('Hello Activity', typeName: 'text');
  final date = ActiveDateTime(DateTime.utc(2026, 10, 19, 9), typeName: 'date');
  final tasks = ActiveList<TaskItem>([
    const TaskItem(1, 'Create a controller', done: true),
    const TaskItem(2, 'Register reactive values', done: true),
    const TaskItem(3, 'Connect a selective view'),
    const TaskItem(4, 'Try a nested route'),
    const TaskItem(5, 'Add ICU translations'),
    const TaskItem(6, 'Verify lifecycle cleanup'),
  ], typeName: 'tasks');
  final metrics = ActiveMap<String, int>({
    'builds': 4,
    'updates': 12,
    'listeners': 2,
  }, typeName: 'metrics');
  final profile = ActiveModel(
    const Profile('Kenzy Limon', 'Developer', 120),
    typeName: 'profile',
  );
  final asyncMessage = ActiveString(
    'Ready to run an example.',
    typeName: 'asyncMessage',
  );
  final completed = ActiveInt(0, typeName: 'completed');
  final draftDirty = ActiveBool(false, typeName: 'draftDirty');
  final result = ActiveString(
    'No result received yet.',
    typeName: 'routeResult',
  );
  final pluralCount = ActiveInt(3, typeName: 'pluralCount');
  final gender = ActiveString('female', typeName: 'gender');
  final checklist = ActiveList<int>([], typeName: 'checklist');
  int _nextTask = 7;
  @override
  Iterable<ActiveType> get activities => [
    count,
    progress,
    enabled,
    optional,
    text,
    date,
    tasks,
    metrics,
    profile,
    asyncMessage,
    completed,
    draftDirty,
    result,
    pluralCount,
    gender,
    checklist,
  ];

  void addTask(String title) {
    if (title.trim().isNotEmpty) tasks.add(TaskItem(_nextTask++, title.trim()));
  }

  void toggleTask(TaskItem task) => tasks.replaceAt(
    tasks.value.indexOf(task),
    task.copyWith(done: !task.done),
  );
  Future<void> runTask(
    String key, {
    bool fail = false,
    int milliseconds = 700,
  }) async {
    try {
      await activeAsync(() async {
        await Future<void>.delayed(Duration(milliseconds: milliseconds));
        if (fail) throw StateError('Example request failed. Try again.');
      }, isRunningKey: key);
      if (isDisposed) return;
      completed.increment();
      asyncMessage('Completed $key. Other work keeps its own busy status.');
    } catch (error, stack) {
      if (isDisposed) return;
      asyncMessage('Recovered: $error');
      onActiveError(
        ErrorEvent(error, stackTrace: stack, errorData: {'task': key}),
      );
    }
  }
}

class GalleryScope extends InheritedWidget {
  final GallerySettings settings;
  final PlaygroundController lab;
  final GalleryConsole console;
  const GalleryScope({
    super.key,
    required this.settings,
    required this.lab,
    required this.console,
    required super.child,
  });
  static GalleryScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<GalleryScope>()!;
  @override
  bool updateShouldNotify(GalleryScope oldWidget) =>
      settings != oldWidget.settings || lab != oldWidget.lab;
}

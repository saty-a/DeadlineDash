import 'dart:convert';
import 'dart:io' show Platform;
import 'package:hive_ce/hive.dart';
import 'package:home_widget/home_widget.dart';
import '../models/task.dart';

class TaskRepository {
  static const String _tasksBoxName = 'tasks_box';
  static const String _widgetTasksKey = 'tasks';
  static const String _widgetTaskListKey = 'task_list';
  static const String _androidWidgetProvider = 'HomeWidgetProvider';
  static const String _iOSWidgetName = 'DeadlineFlow';
  static const String _appGroupId = 'group.com.sun2.chessclock';

  /// Check if the current platform supports home_widget (iOS/Android only)
  bool get _isHomeWidgetSupported => Platform.isIOS || Platform.isAndroid;

  Future<void> initialize() async {
    if (_isHomeWidgetSupported) {
      await HomeWidget.setAppGroupId(_appGroupId);
    }
  }

  Future<Box<Task>> _getBox() async {
    if (!Hive.isBoxOpen(_tasksBoxName)) {
      return await Hive.openBox<Task>(_tasksBoxName);
    }
    return Hive.box<Task>(_tasksBoxName);
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final box = await _getBox();
    await box.clear();
    await box.addAll(tasks);

    // Sort tasks using custom logic
    sortTasks(tasks);

    // Filter out expired and completed tasks for the widget only
    final now = DateTime.now();
    final activeTasks =
        tasks.where((t) => !t.isCompleted && t.deadline.isAfter(now)).toList();

    // Sync to Widget (widget uses its own storage, so we still convert to JSON for it)
    if (_isHomeWidgetSupported) {
      final tasksJson = jsonEncode(activeTasks.map((t) => t.toJson()).toList());
      await HomeWidget.setAppGroupId(_appGroupId);
      await HomeWidget.saveWidgetData<String>(_widgetTasksKey, tasksJson);
      await updateHomeWidget(activeTasks);
    }
  }

  Future<List<Task>> loadTasks() async {
    final box = await _getBox();
    final tasks = box.values.toList();
    sortTasks(tasks);
    return tasks;
  }

  Future<void> updateHomeWidget(List<Task> tasks) async {
    if (!_isHomeWidgetSupported) return;

    String formatRemaining(DateTime deadline) {
      final d = deadline.difference(DateTime.now());
      if (d.isNegative) return 'Expired';
      int days = d.inDays;
      int hours = d.inHours % 24;
      int minutes = d.inMinutes % 60;
      int seconds = d.inSeconds % 60;
      return '${days}d:${hours.toString().padLeft(2, '0')}h:${minutes.toString().padLeft(2, '0')}m:${seconds.toString().padLeft(2, '0')}s';
    }

    final activeTasks = tasks.where((t) => !t.isCompleted).toList();

    final taskListString = activeTasks
        .map((t) => '${t.name}\n${formatRemaining(t.deadline)}')
        .join('\n\n');

    await HomeWidget.saveWidgetData<String>(_widgetTaskListKey, taskListString);

    // Find nearest future deadline for the ticker
    final now = DateTime.now();
    Task? nearestTask;
    Duration? smallestDiff;

    for (final task in activeTasks) {
      final diff = task.deadline.difference(now);
      if (!diff.isNegative) {
        if (smallestDiff == null || diff < smallestDiff) {
          smallestDiff = diff;
          nearestTask = task;
        }
      }
    }

    if (nearestTask != null) {
      await HomeWidget.saveWidgetData<String>(
        'nearest_task_name',
        nearestTask.name,
      );
      await HomeWidget.saveWidgetData<String>(
        'nearest_task_deadline_str',
        nearestTask.deadline.millisecondsSinceEpoch.toString(),
      );
    } else {
      await HomeWidget.saveWidgetData<String>(
        'nearest_task_name',
        'No Active Tasks',
      );
      await HomeWidget.saveWidgetData<int>(
        'nearest_task_deadline',
        0,
      ); // Keep old invalid key or just ignore? Best to use new key.
      await HomeWidget.saveWidgetData<String>('nearest_task_deadline_str', '0');
    }

    await HomeWidget.updateWidget(
      name: _androidWidgetProvider,
      iOSName: _iOSWidgetName,
    );
  }

  void sortTasks(List<Task> tasks) {
    final now = DateTime.now();
    tasks.sort((a, b) {
      int getRank(Task t) {
        if (!t.isCompleted && t.deadline.isAfter(now)) return 1; // Active
        if (t.isCompleted) return 2; // Completed
        return 3; // Expired
      }

      int rankA = getRank(a);
      int rankB = getRank(b);

      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return a.deadline.compareTo(b.deadline);
    });
  }
}

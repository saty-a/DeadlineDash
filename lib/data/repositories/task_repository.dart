import 'dart:convert';
import 'package:hive_ce/hive.dart';
import 'package:home_widget/home_widget.dart';
import '../models/task.dart';

class TaskRepository {
  static const String _tasksBoxName = 'tasks_box';
  static const String _widgetTasksKey = 'tasks';
  static const String _widgetTaskListKey = 'task_list';
  static const String _androidWidgetProvider = 'HomeWidgetProvider';
  static const String _iOSWidgetName = 'HomeWidgetExtension';

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

    // Sort tasks by deadline
    tasks.sort((a, b) => a.deadline.compareTo(b.deadline));

    // Filter out expired tasks for the widget only
    final now = DateTime.now();
    final activeTasks = tasks.where((t) => t.deadline.isAfter(now)).toList();

    // Sync to Widget (widget uses its own storage, so we still convert to JSON for it)
    final tasksJson = jsonEncode(activeTasks.map((t) => t.toJson()).toList());
    await HomeWidget.saveWidgetData<String>(_widgetTasksKey, tasksJson);
    await updateHomeWidget(activeTasks);
  }

  Future<List<Task>> loadTasks() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<void> updateHomeWidget(List<Task> tasks) async {
    String formatRemaining(DateTime deadline) {
      final d = deadline.difference(DateTime.now());
      if (d.isNegative) return 'Expired';
      int days = d.inDays;
      int hours = d.inHours % 24;
      int minutes = d.inMinutes % 60;
      int seconds = d.inSeconds % 60;
      return '${days}d:${hours.toString().padLeft(2, '0')}h:${minutes.toString().padLeft(2, '0')}m:${seconds.toString().padLeft(2, '0')}s';
    }

    final taskListString = tasks
        .map((t) => '${t.name}\n${formatRemaining(t.deadline)}')
        .join('\n\n');

    await HomeWidget.saveWidgetData<String>(_widgetTaskListKey, taskListString);

    // Find nearest future deadline for the ticker
    final now = DateTime.now();
    Task? nearestTask;
    Duration? smallestDiff;

    for (final task in tasks) {
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
}

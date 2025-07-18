import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'task.dart';
import 'task_event.dart';
import 'task_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:home_widget/home_widget.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  Timer? _timer;

  TaskBloc() : super(TaskState()) {
    on<AddTask>(_onAddTask);
    _startTicker();
    _loadTasksFromStorage();
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) {
    final updatedTasks = List<Task>.from(state.tasks)..add(event.task);
    emit(TaskState(tasks: updatedTasks));
    _saveTasksToStorage(updatedTasks);
    _updateHomeWidget(updatedTasks);
  }

  Future<void> _saveTasksToStorage(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', tasksJson);
    // Also save for the widget (native code reads from HomeWidgetPreferences)
    await HomeWidget.saveWidgetData<String>('tasks', tasksJson);
  }

  Future<void> _loadTasksFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      final loadedTasks = decoded.map((e) => Task.fromJson(e)).toList();
      emit(TaskState(tasks: loadedTasks.cast<Task>()));
      _updateHomeWidget(loadedTasks.cast<Task>());
    }
  }

  Future<void> _updateHomeWidget(List<Task> tasks) async {
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
    await HomeWidget.saveWidgetData<String>('task_list', taskListString);
    await HomeWidget.updateWidget(
      name: 'HomeWidgetProvider',
      iOSName: 'HomeWidgetExtension',
    );
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(_TickInternal());
    });
    on<_TickInternal>((event, emit) {
      emit(TaskState(tasks: List.from(state.tasks), timestamp: DateTime.now()));
    });
  }

  void refreshHomeWidget() {
    _updateHomeWidget(state.tasks);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

class _TickInternal extends TaskEvent {
  @override
  List<Object?> get props => [];
}

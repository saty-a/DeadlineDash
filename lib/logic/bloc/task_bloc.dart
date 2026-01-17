import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task.dart';
import '../../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;
  Timer? _timer;

  TaskBloc({required TaskRepository repository})
    : _repository = repository,
      super(TaskState()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<_TickInternal>(_onTick);

    _startTicker();
    add(LoadTasks());
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    final tasks = await _repository.loadTasks();
    emit(TaskState(tasks: tasks, timestamp: DateTime.now()));
    await _repository.updateHomeWidget(tasks);
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    final updatedTasks = List<Task>.from(state.tasks)..add(event.task);
    emit(TaskState(tasks: updatedTasks, timestamp: DateTime.now()));
    await _repository.saveTasks(updatedTasks);
  }

  void _onTick(_TickInternal event, Emitter<TaskState> emit) {
    emit(TaskState(tasks: state.tasks, timestamp: DateTime.now()));
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(_TickInternal());
    });
  }

  void refreshHomeWidget() {
    _repository.updateHomeWidget(state.tasks);
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

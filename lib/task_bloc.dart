import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  Timer? _timer;

  TaskBloc() : super(const TaskState()) {
    on<AddTask>(_onAddTask);
    _startTicker();
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) {
    final updatedTasks = List<Task>.from(state.tasks)..add(event.task);
    emit(TaskState(tasks: updatedTasks));
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(_TickInternal());
    });
    on<_TickInternal>((event, emit) {
      emit(TaskState(tasks: List.from(state.tasks)));
    });
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

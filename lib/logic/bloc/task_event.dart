import 'package:equatable/equatable.dart';
import '../../data/models/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  const AddTask(this.task);

  @override
  List<Object?> get props => [task];
}

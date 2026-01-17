import 'package:equatable/equatable.dart';
import '../../data/models/task.dart';

class TaskState extends Equatable {
  final List<Task> tasks;
  final DateTime timestamp;
  TaskState({this.tasks = const [], DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  @override
  List<Object?> get props => [tasks, timestamp];
}

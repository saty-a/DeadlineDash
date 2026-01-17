import 'package:equatable/equatable.dart';
import '../../data/models/task.dart';

enum TaskStatus { initial, loading, success, error }

class TaskState extends Equatable {
  final List<Task> tasks;
  final DateTime timestamp;
  final TaskStatus status;
  final String? errorMessage;

  TaskState({
    this.tasks = const [],
    DateTime? timestamp,
    this.status = TaskStatus.initial,
    this.errorMessage,
  }) : timestamp = timestamp ?? DateTime.now();

  TaskState copyWith({
    List<Task>? tasks,
    DateTime? timestamp,
    TaskStatus? status,
    String? errorMessage,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [tasks, timestamp, status, errorMessage];
}
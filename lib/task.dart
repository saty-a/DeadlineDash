import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String name;
  final DateTime deadline;

  const Task({
    required this.id,
    required this.name,
    required this.deadline,
  });

  Task copyWith({
    String? id,
    String? name,
    DateTime? deadline,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      deadline: deadline ?? this.deadline,
    );
  }

  @override
  List<Object?> get props => [id, name, deadline];
} 
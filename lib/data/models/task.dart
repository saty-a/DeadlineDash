import 'package:equatable/equatable.dart';
import 'package:hive_ce/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime deadline;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? description;

  const Task({
    required this.id,
    required this.name,
    required this.deadline,
    this.isCompleted = false,
    DateTime? createdAt,
    this.description,
  }) : createdAt = createdAt ?? deadline;

  Task copyWith({
    String? id,
    String? name,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
    String? description,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [id, name, deadline, isCompleted, createdAt, description];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'deadline': '${deadline.toUtc().toIso8601String()}Z',
    'isCompleted': isCompleted,
    'createdAt': '${createdAt.toUtc().toIso8601String()}Z',
    'description': description,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    name: json['name'] as String,
    deadline: DateTime.parse(json['deadline'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    description: json['description'] as String?,
  );
}
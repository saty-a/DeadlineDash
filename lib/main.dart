import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'task_bloc.dart';
import 'task_event.dart';
import 'task_state.dart';
import 'task.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeadlineDash',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider(
        create: (_) => TaskBloc(),
        child: const TaskListScreen(),
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state.tasks.isEmpty) {
            return const Center(child: Text('No tasks yet.'));
          }
          return ListView.builder(
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              final remaining = task.deadline.difference(DateTime.now());
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(task.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deadline: ${task.deadline.toLocal().toString().split(' ')[0]}',
                      ),
                      Text(
                        'Remaining: ${_formatRemaining(remaining)}',
                        style: TextStyle(
                          color:
                              remaining.isNegative ? Colors.red : Colors.green,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatRemaining(Duration d) {
    if (d.isNegative) return 'Expired';
    int days = d.inDays;
    int hours = d.inHours % 24;
    int minutes = d.inMinutes % 60;
    int seconds = d.inSeconds % 60;
    String dayStr = '$days Day${days == 1 ? '' : 's'}';
    String hourStr =
        '${hours.toString().padLeft(2, '0')} Hour${hours == 1 ? '' : 's'}';
    String minStr =
        '${minutes.toString().padLeft(2, '0')} Minute${minutes == 1 ? '' : 's'}';
    String secStr =
        '${seconds.toString().padLeft(2, '0')} Second${seconds == 1 ? '' : 's'}';
    debugPrint('$dayStr:$hourStr:$minStr:$secStr');
    return '$dayStr $hourStr $minStr $secStr';
  }

  void _showAddTaskSheet(BuildContext context) {
    final taskBloc = context.read<TaskBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => BlocProvider.value(
            value: taskBloc,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: _AddTaskForm(),
            ),
          ),
    );
  }
}

class _AddTaskForm extends StatefulWidget {
  @override
  State<_AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<_AddTaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Task Name'),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Enter a task name' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDeadline == null
                      ? 'No deadline selected'
                      : 'Deadline: ${_selectedDeadline!.toLocal().toString().split(' ')[0]}',
                ),
              ),
              TextButton(
                onPressed: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: now,
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDeadline = picked;
                    });
                  }
                },
                child: const Text('Select Deadline'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate() &&
                  _selectedDeadline != null) {
                final id = UniqueKey().toString();
                final task = Task(
                  id: id,
                  name: _nameController.text,
                  deadline: _selectedDeadline!,
                );
                context.read<TaskBloc>().add(AddTask(task));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Create'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

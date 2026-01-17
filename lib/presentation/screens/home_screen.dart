import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/task_bloc.dart';
import '../../logic/bloc/task_state.dart';
import '../widgets/add_task_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Widget',
            onPressed: () {
              final bloc = context.read<TaskBloc>();
              bloc.refreshHomeWidget();
            },
          ),
        ],
      ),
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
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
    String dayStr = '$days d';
    String hourStr = '${hours.toString().padLeft(2, '0')} h';
    String minStr = '${minutes.toString().padLeft(2, '0')} m';
    String secStr = '${seconds.toString().padLeft(2, '0')} s';
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
              child: const AddTaskForm(),
            ),
          ),
    );
  }
}

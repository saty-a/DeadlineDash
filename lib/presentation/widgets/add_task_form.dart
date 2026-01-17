import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task.dart';
import '../../logic/bloc/task_bloc.dart';
import '../../logic/bloc/task_event.dart';

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({super.key});

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
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
                final bloc = context.read<TaskBloc>();
                bloc.add(AddTask(task));
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

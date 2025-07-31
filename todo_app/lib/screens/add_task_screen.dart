import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  String _selectedPriority = 'high';

  Future<void> _submitTask() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty')),
      );
      return;
    }

    final newTask = Task(
      id: 0, // The backend will assign the ID
      title: title,
      priority: _selectedPriority,
      completed: false,
    );

    await ApiService.addTask(newTask);
    Navigator.pop(context); // Go back to task list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: ['high', 'medium', 'low']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority[0].toUpperCase() + priority.substring(1)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitTask,
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}

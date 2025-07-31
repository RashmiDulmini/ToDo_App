import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late String _selectedPriority;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _selectedPriority = widget.task.priority;
    _isCompleted = widget.task.completed;
  }

  Future<void> _updateTask() async {
    final updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text.trim(),
      priority: _selectedPriority,
      completed: _isCompleted,
    );

    await ApiService.updateTask(updatedTask);
    Navigator.pop(context); // Go back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
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
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _isCompleted,
              title: const Text('Mark as Completed'),
              onChanged: (value) {
                setState(() {
                  _isCompleted = value ?? false;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _updateTask,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

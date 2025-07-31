import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen(this.task, {super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _controller;
  late String _priority;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.task.title);
    _priority = widget.task.priority;
    _completed = widget.task.completed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _controller, decoration: const InputDecoration(labelText: "Title")),
          DropdownButton<String>(
            value: _priority,
            items: ['high', 'medium', 'low']
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (value) => setState(() => _priority = value!),
          ),
          CheckboxListTile(
              title: const Text("Completed"),
              value: _completed,
              onChanged: (val) => setState(() => _completed = val ?? false)),
          ElevatedButton(
              onPressed: () async {
                await ApiService.updateTask(Task(
                    id: widget.task.id,
                    title: _controller.text,
                    priority: _priority,
                    completed: _completed));
                Navigator.pop(context);
              },
              child: const Text("Save"))
        ]),
      ),
    );
  }
}
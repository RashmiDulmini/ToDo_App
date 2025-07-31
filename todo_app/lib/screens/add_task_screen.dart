import 'package:flutter/material.dart';
import 'package:todo_app/services/api_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _controller = TextEditingController();
  String _priority = 'medium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Task")),
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
          ElevatedButton(
              onPressed: () async {
                await ApiService.createTask(_controller.text, _priority);
                Navigator.pop(context);
              },
              child: const Text("Add"))
        ]),
      ),
    );
  }
}

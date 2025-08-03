import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:todo_app/screens/add_task_screen.dart';
import 'package:todo_app/screens/edit_task_screen.dart';
import 'package:todo_app/screens/getstarted_screen.dart';
import 'package:todo_app/screens/add_people_screen.dart';  
import 'package:todo_app/services/api_service.dart';
import '../models/task.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      home: const GetStartedScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  String? selectedPriority;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final loadedTasks = await ApiService.fetchTasks();
    setState(() {
      tasks = loadedTasks;
    });
  }

  void filter(String? priority) {
    setState(() {
      selectedPriority = priority;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = selectedPriority == null
        ? tasks
        : tasks.where((t) => t.priority == selectedPriority).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          DropdownButton<String>(
            hint: const Text("Priority", style: TextStyle(color: Colors.white)),
            value: selectedPriority,
            items: ['high', 'medium', 'low']
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: filter,
            dropdownColor: Colors.white,
          ),
        ],
      ),
      body: ListView(
        children: filtered.map((task) {
          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                    task.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Priority: ${task.priority}"),
                if (task.assignedUser != null && task.assignedUser!.isNotEmpty)
                  Text("Assigned to: ${task.assignedUser!}"),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: task.completed,
                  onChanged: (val) async {
                    final updated = Task(
                      id: task.id,
                      title: task.title,
                      priority: task.priority,
                      completed: val ?? false,
                      notes: task.notes,
                      date: task.date,
                      time: task.time,
                      alarm: task.alarm,
                      assignedUser: task.assignedUser,
                    );
                    await ApiService.updateTask(updated);
                    loadTasks();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddPeopleScreen(task: task)),
                    );
                    loadTasks();  // Reload tasks after assignment
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await ApiService.deleteTask(task.id);
                    loadTasks();
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditTaskScreen(task)),
              );
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          loadTasks();
        },
      ),
    );
  }
}

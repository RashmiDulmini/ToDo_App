import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  String _selectedPriority = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await ApiService.getTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _deleteTask(int id) async {
    await ApiService.deleteTask(id);
    await _loadTasks();
  }

  List<Task> get _filteredTasks {
    if (_selectedPriority == 'All') return _tasks;
    return _tasks
        .where((task) => task.priority == _selectedPriority.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<String>(
              value: _selectedPriority,
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list, color: Colors.white),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black),
              items: ['All', 'High', 'Medium', 'Low']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
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
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredTasks.isEmpty
              ? const Center(child: Text("No tasks available"))
              : ListView.builder(
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.completed,
                          onChanged: (value) async {
                            task.completed = value ?? false;
                            await ApiService.updateTask(task);
                            _loadTasks();
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          'Priority: ${task.priority}',
                          style: TextStyle(
                            color: task.priority == 'high'
                                ? Colors.red
                                : task.priority == 'medium'
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(task.id),
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditTaskScreen(task: task),
                            ),
                          );
                          _loadTasks();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          _loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

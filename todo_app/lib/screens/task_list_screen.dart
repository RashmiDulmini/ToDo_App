import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'getstarted_screen.dart';

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
    try {
      final tasks = await ApiService.fetchTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching tasks: $e')),
      );
    }
  }

  Future<void> _deleteTask(int id) async {
    try {
      await ApiService.deleteTask(id);
      _loadTasks();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting task: $e')),
      );
    }
  }

  List<Task> get _filteredTasks {
    if (_selectedPriority == 'All') return _tasks;
    return _tasks
        .where((task) => task.priority.toLowerCase() == _selectedPriority.toLowerCase())
        .toList();
  }

  bool _isToday(String? date) {
    if (date == null || date.isEmpty) return false;
    try {
      final parsedDate = DateTime.parse(date);
      final now = DateTime.now();
      return parsedDate.year == now.year &&
          parsedDate.month == now.month &&
          parsedDate.day == now.day;
    } catch (_) {
      return false;
    }
  }

  String _getTimeRemaining(String? date, String? time) {
    if (date == null || date.isEmpty) return '';
    try {
      DateTime dueDate = DateTime.parse(date);
      if (time != null && time.isNotEmpty) {
        final parsedTime = DateFormat.jm().parse(time); // Example: 5:30 PM
        dueDate = DateTime(
          dueDate.year,
          dueDate.month,
          dueDate.day,
          parsedTime.hour,
          parsedTime.minute,
        );
      }

      final now = DateTime.now();
      final difference = dueDate.difference(now);

      if (difference.isNegative) {
        return 'Overdue';
      } else if (difference.inDays > 0) {
        return 'Due in ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'Due in ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'Due in ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'Due soon';
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final incompleteTasks = _filteredTasks.where((task) => !task.completed).toList();
    final completedTasks = _filteredTasks.where((task) => task.completed).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('My To-Do List', style: TextStyle(color: Colors.blue[900])),
        backgroundColor: Colors.blue[100],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const GetStartedScreen()),
            );
          },
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedPriority,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.black),
            items: ['All', 'High', 'Medium', 'Low']
                .map((priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedPriority = value);
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text("No tasks available"))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (incompleteTasks.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Pending Tasks",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...incompleteTasks.map((task) => _buildTaskCard(task)),
                            ],
                          ),
                        if (completedTasks.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          const Text(
                            "Completed Tasks",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...completedTasks.map((task) => _buildTaskCard(task)),
                        ],
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[800],
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          _loadTasks();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final isToday = _isToday(task.date);
    final timeRemaining = _getTimeRemaining(task.date, task.time);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.blueAccent,
            blurRadius: 5,
            offset: Offset(2, 3),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Checkbox(
          value: task.completed,
          onChanged: (value) async {
            setState(() => task.completed = value ?? false);
            await ApiService.updateTask(task);
            _loadTasks();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: task.completed ? TextDecoration.lineThrough : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if ((task.date ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  timeRemaining,
                  style: TextStyle(
                    fontSize: 12,
                    color: timeRemaining == 'Overdue' ? Colors.red : Colors.blue,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((task.notes ?? '').isNotEmpty)
              _buildRow(Icons.notes, task.notes!),
            if ((task.date ?? '').isNotEmpty)
              _buildRow(
                Icons.calendar_today,
                DateFormat.yMMMd().format(DateTime.parse(task.date!)),
                color: isToday ? Colors.red : Colors.black,
              ),
            if ((task.time ?? '').isNotEmpty)
              _buildRow(Icons.access_time, task.time!),
            _buildRow(
              Icons.alarm,
              (task.alarm ?? false) ? 'Alarm On' : 'Alarm Off',
              color: (task.alarm ?? false) ? Colors.deepPurple : Colors.grey.shade600,
            ),
            _buildRow(
              Icons.flag,
              task.priority.toUpperCase(),
              color: task.priority == 'high'
                  ? Colors.red
                  : task.priority == 'medium'
                      ? Colors.orange
                      : Colors.green,
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteTask(task.id),
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditTaskScreen(task)),
          );
          _loadTasks();
        },
      ),
    );
  }

  Widget _buildRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.black87),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

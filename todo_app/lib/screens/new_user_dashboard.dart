import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class NewUserDashboard extends StatefulWidget {
  final String userName;
  final List<Task> tasks;

  const NewUserDashboard({
    Key? key,
    required this.userName,
    required this.tasks,
  }) : super(key: key);

  @override
  _NewUserDashboardState createState() => _NewUserDashboardState();
}

class _NewUserDashboardState extends State<NewUserDashboard> {
  late List<Task> _tasks;
  String _selectedCategory = 'All';
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _tasks = List.from(widget.tasks);
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {
        // Just trigger UI refresh every 30 seconds
      });
    });
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    setState(() {
      task.completed = !task.completed;
    });

    try {
      await ApiService.updateTask(task);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task marked as ${task.completed ? "completed" : "pending"}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task: $e')),
      );
    }
  }

  List<Task> _filterTasks() {
    if (_selectedCategory == 'All') {
      return _tasks;
    }
    return _tasks.where((task) => task.priority.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  String _calculateRemainingTime(Task task) {
    if (task.date == null || task.date!.isEmpty || task.time == null || task.time!.isEmpty) {
      return '';
    }

    try {
      final taskDate = DateTime.parse(task.date!);
      final timeParts = task.time!.split(':');
      final dueDateTime = DateTime(
        taskDate.year,
        taskDate.month,
        taskDate.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      final now = DateTime.now();
      final difference = dueDateTime.difference(now);

      if (difference.isNegative) return 'Overdue';

      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return '$hours h ${minutes} m left';
      } else {
        return '$minutes m left';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filterTasks();
    final pendingTasks = filteredTasks.where((task) => !task.completed).toList();
    final completedTasks = filteredTasks.where((task) => task.completed).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.userName}!'),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'High', 'Medium', 'Low'].map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: Colors.white,
                      backgroundColor: Colors.blue[700],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue[800] : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
      body: filteredTasks.isEmpty
          ? Center(
              child: Text(
                'No tasks found!',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pendingTasks.isNotEmpty) ...[
                    const Text(
                      'Pending Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...pendingTasks.map((task) => _buildTaskCard(task)),
                  ],
                  if (completedTasks.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    const Text(
                      'Completed Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...completedTasks.map((task) => _buildTaskCard(task)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final formattedDate = task.date != null && task.date!.isNotEmpty
        ? DateFormat('yyyy-MM-dd').format(DateTime.parse(task.date!))
        : '';

    final remainingTime = _calculateRemainingTime(task);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4), // X, Y offset of shadow
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: IconButton(
          icon: Icon(
            task.completed ? Icons.check_circle : Icons.circle_outlined,
            color: task.completed ? Colors.green : Colors.grey,
          ),
          onPressed: () => _toggleTaskCompletion(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority: ${task.priority}'),
            if (task.notes != null && task.notes!.isNotEmpty)
              Text('Notes: ${task.notes}'),
            if (formattedDate.isNotEmpty || (task.time != null && task.time!.isNotEmpty))
              Text('Due: $formattedDate ${task.time != null ? "at ${task.time}" : ""}'),
            if (remainingTime.isNotEmpty)
              Text('Time Left: $remainingTime', style: const TextStyle(color: Colors.red)),
          ],
        ),
        trailing: task.alarm == true
            ? const Icon(Icons.alarm, color: Colors.red)
            : null,
      ),
    );
  }
}




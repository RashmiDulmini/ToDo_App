import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/api_service.dart';
import 'package:todo_app/screens/task_list_screen.dart'; 

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String selectedPriority = 'medium';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool alarmEnabled = false;

  Future<void> _submitTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleController.text.trim(),
      priority: selectedPriority,
      completed: false,
      notes: _notesController.text.trim(),
      date: selectedDate.toIso8601String(),
      time: selectedTime.format(context),
      alarm: alarmEnabled,
    );

    await ApiService.addTask(task);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TaskListScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Create New Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSection("Title", TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter task title",
                    border: InputBorder.none,
                  ),
                )),

                _buildSection("Notes", TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Add extra details...",
                    border: InputBorder.none,
                  ),
                )),

                _buildSection("Date", ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(DateFormat.yMMMMd().format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDate,
                )),

                _buildSection("Time", ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: _pickTime,
                )),

                _buildSection("Priority", DropdownButtonFormField<String>(
                  value: selectedPriority,
                  decoration: const InputDecoration(border: InputBorder.none),
                  items: ['high', 'medium', 'low']
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedPriority = val);
                  },
                )),

                _buildSection("Alarm", SwitchListTile(
                  title: const Text("Enable Alarm"),
                  value: alarmEnabled,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setState(() => alarmEnabled = val),
                )),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _submitTask,
                    child: const Text(
                      "ADD TASK",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.blue,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: child,
          )
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/api_service.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen(this.task, {super.key});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;

  late String _priority;
  late bool _completed;
  late bool _alarm;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _priority = widget.task.priority;
    _completed = widget.task.completed;
    _alarm = widget.task.alarm ?? false;

    _selectedDate = widget.task.date != null
        ? DateTime.tryParse(widget.task.date!) ?? DateTime.now()
        : DateTime.now();

    _selectedTime = widget.task.time != null
        ? TimeOfDay(
            hour: int.tryParse(widget.task.time!.split(":")[0]) ?? 0,
            minute: int.tryParse(widget.task.time!.split(":")[1]) ?? 0)
        : TimeOfDay.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
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
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSection(
                  "Title",
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: "Edit task title",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                _buildSection(
                  "Notes",
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Edit notes...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                _buildSection(
                  "Date",
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(DateFormat.yMMMMd().format(_selectedDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _pickDate,
                  ),
                ),

                _buildSection(
                  "Time",
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_selectedTime.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: _pickTime,
                  ),
                ),

                _buildSection(
                  "Priority",
                  DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: ['high', 'medium', 'low']
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _priority = val);
                    },
                  ),
                ),

                _buildSection(
                  "Completed",
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Mark as Completed"),
                    value: _completed,
                    onChanged: (val) => setState(() => _completed = val),
                  ),
                ),

                _buildSection(
                  "Alarm",
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Enable Alarm"),
                    value: _alarm,
                    onChanged: (val) => setState(() => _alarm = val),
                  ),
                ),

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
                    onPressed: () async {
                      final updated = Task(
                        id: widget.task.id,
                        title: _titleController.text.trim(),
                        notes: _notesController.text.trim(),
                        date: _selectedDate.toIso8601String(),
                        time: _selectedTime.format(context),
                        priority: _priority,
                        completed: _completed,
                        alarm: _alarm,
                      );

                      await ApiService.updateTask(updated);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "SAVE CHANGES",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
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
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

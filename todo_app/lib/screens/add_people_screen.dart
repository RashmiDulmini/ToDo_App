import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class AddPeopleScreen extends StatefulWidget {
  final Task task;

  const AddPeopleScreen({Key? key, required this.task}) : super(key: key);

  @override
  _AddPeopleScreenState createState() => _AddPeopleScreenState();
}

class _AddPeopleScreenState extends State<AddPeopleScreen> {
  final TextEditingController _userController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _userController.text = widget.task.assignedUser ?? '';
  }

  Future<void> _assignUser() async {
    final username = _userController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a user name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      widget.task.assignedUser = username;
      await ApiService.updateTask(widget.task); // Reuse updateTask API
      Navigator.pop(context); // Go back to TaskListScreen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign user: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign People'),
        backgroundColor: Colors.blue[100],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: 'Enter User Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.save),
              label: const Text('Assign User'),
              onPressed: _isSaving ? null : _assignUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

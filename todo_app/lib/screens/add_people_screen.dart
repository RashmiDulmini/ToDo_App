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
      await ApiService.assignTaskToUser(widget.task.id, username);
      _showDialog('Success', 'User assigned successfully!', true);
    } catch (e) {
      _showDialog('Error', 'An error occurred: $e', false);
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showDialog(String title, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              if (isSuccess) {
                Navigator.of(context).pop(); // Go back to previous screen
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
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
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Assigning...' : 'Assign User'),
              onPressed: _isSaving ? null : _assignUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

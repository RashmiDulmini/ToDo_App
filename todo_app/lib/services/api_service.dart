import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Fetch Tasks
  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks (status: ${response.statusCode})');
    }
  }

  // Add Task
  static Future<Task> addTask(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task (status: ${response.statusCode})');
    }
  }

  // Delete Task
  static Future<void> deleteTask(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete task (status: ${response.statusCode})');
    }
  }

  // Update Task (Full update)
  static Future<void> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task (status: ${response.statusCode})');
    }
  }

  // --- Corrected assignTaskToUser method ---
  static Future<void> assignTaskToUser(int taskId, String username) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId/assign-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username}),
    );

    print('Assign user response: ${response.statusCode} - ${response.body}'); // Debug log

    if (response.statusCode != 200) {
      throw Exception('Failed to assign user to task (status: ${response.statusCode})');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

const String baseUrl = 'http://192.168.1.37:3000/api/tasks'; // Use ngrok/IP

class ApiService {
  static Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse(baseUrl));
    final List data = jsonDecode(response.body);
    return data.map((json) => Task.fromJson(json)).toList();
  }

  static Future<void> addTask(Task task) async {
    await http.post(Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()));
  }

  static Future<void> updateTask(Task task) async {
    await http.put(Uri.parse('$baseUrl/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(task.toJson()));
  }

  static Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
  }
}

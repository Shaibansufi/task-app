import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  // Replace with your local IP for mobile device access
  final String baseUrl = "http://192.168.31.24:8000"; 

  // Fetch all tasks
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/tasks"));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Task.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load tasks. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching tasks: $e");
      return [];
    }
  }

  // Create a new task
  Future<Task?> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/tasks"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(task.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        print("Failed to create task: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error creating task: $e");
      return null;
    }
  }

  // Update existing task
  Future<Task?> updateTask(Task task) async {
    if (task.id == null) return null;
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/tasks/${task.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(task.toJson()),
      );
      if (response.statusCode == 200) {
        return Task.fromJson(jsonDecode(response.body));
      } else {
        print("Failed to update task: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error updating task: $e");
      return null;
    }
  }

  // Delete task
  Future<bool> deleteTask(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/tasks/$id"));
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Failed to delete task: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error deleting task: $e");
      return false;
    }
  }
}
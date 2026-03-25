import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'create_task_screen.dart';

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final ApiService api = ApiService();
  List<Task> tasks = [];
  bool isLoading = true;

  String searchQuery = "";
  String selectedStatus = "All";

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void loadTasks() async {
    setState(() => isLoading = true);
    try {
      final data = await api.fetchTasks();
      setState(() {
        tasks = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching tasks: $e");
      setState(() => isLoading = false);
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = query.toLowerCase();
      });
    });
  }

  bool isBlocked(Task task) {
    if (task.blockedBy == null) return false;
    try {
      final blockingTask = tasks.firstWhere((t) => t.id == task.blockedBy);
      return blockingTask.status != "Done";
    } catch (e) {
      return false;
    }
  }

  List<TextSpan> highlightOccurrences(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];

    final matches = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index < 0) {
        matches.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        matches.add(TextSpan(text: text.substring(start, index)));
      }
      matches.add(TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(backgroundColor: Colors.yellow)));
      start = index + query.length;
    }
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(searchQuery);
      final matchesStatus = selectedStatus == "All" || task.status == selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Tasks")),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Loading tasks..."),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(labelText: "Search by Title"),
                        onChanged: onSearchChanged,
                      ),
                      SizedBox(height: 10),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: selectedStatus,
                        items: ["All", "To-Do", "In Progress", "Done"]
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedStatus = val!),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredTasks.isEmpty
                      ? Center(
                          child: Text(
                            "No tasks yet.\nTap + to add one!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            final blocked = isBlocked(task);

                            return Opacity(
                              opacity: blocked ? 0.5 : 1.0,
                              child: Card(
                                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(12),
                                  leading: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: blocked
                                        ? null
                                        : () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => CreateTaskScreen(task: task),
                                              ),
                                            ).then((_) => loadTasks());
                                          },
                                  ),
                                  title: RichText(
                                    text: TextSpan(
                                      children: highlightOccurrences(task.title, searchQuery),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5),
                                      Text(task.description),
                                      SizedBox(height: 5),
                                      Text(
                                        "Status: ${task.status}",
                                        style: TextStyle(
                                          color: task.status == "Done"
                                              ? Colors.green
                                              : task.status == "In Progress"
                                                  ? Colors.orange
                                                  : Colors.red,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: blocked
                                      ? Icon(Icons.lock, color: Colors.red)
                                      : IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            if (task.id != null) {
                                              await api.deleteTask(task.id!);
                                              loadTasks();
                                            }
                                          },
                                        ),
                                  enabled: !blocked,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateTaskScreen()),
          ).then((_) => loadTasks());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
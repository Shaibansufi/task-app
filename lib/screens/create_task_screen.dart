import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class CreateTaskScreen extends StatefulWidget {
  final Task? task;
  CreateTaskScreen({this.task});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final ApiService api = ApiService();
  final titleController = TextEditingController();
  final descController = TextEditingController();

  String status = "To-Do";
  bool isLoading = false;

  List<Task> existingTasks = [];
  String? blockedBy;

  @override
  void initState() {
    super.initState();
    loadTasks();
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descController.text = widget.task!.description;
      status = widget.task!.status;
      blockedBy = widget.task!.blockedBy;
    }
  }

  void loadTasks() async {
    final data = await api.fetchTasks();
    setState(() => existingTasks = data);
  }

  void saveTask() async {
    if (titleController.text.isEmpty) return;
    setState(() => isLoading = true);

    Task t = Task(
      id: widget.task?.id,
      title: titleController.text,
      description: descController.text,
      dueDate: DateTime.now().toString(),
      status: status,
      blockedBy: blockedBy,
    );

    if (widget.task == null) {
      await api.createTask(t);
    } else {
      await api.updateTask(t);
    }

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? "Create Task" : "Edit Task")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: descController, decoration: InputDecoration(labelText: "Description")),
            DropdownButton<String>(
              isExpanded: true,
              value: status,
              items: ["To-Do", "In Progress", "Done"]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => status = val!),
            ),
            DropdownButton<String>(
              isExpanded: true,
              hint: Text("Blocked By (Optional)"),
              value: blockedBy,
              items: existingTasks.map((task) => DropdownMenuItem(value: task.id, child: Text(task.title))).toList(),
              onChanged: (val) => setState(() => blockedBy = val),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: saveTask,
                    child: Text(widget.task == null ? "Save" : "Update"),
                  ),
          ],
        ),
      ),
    );
  }
}
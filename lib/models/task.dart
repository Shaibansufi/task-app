class Task {
  String? id;
  String title;
  String description;
  String dueDate;
  String status;
  String? blockedBy;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        dueDate: json['due_date'],
        status: json['status'],
        blockedBy: json['blocked_by'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'due_date': dueDate,
        'status': status,
        'blocked_by': blockedBy,
      };
}
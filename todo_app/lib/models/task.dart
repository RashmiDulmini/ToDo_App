class Task {
  int id;
  String title;
  String priority;
  bool completed;

  Task({required this.id, required this.title, required this.priority, required this.completed});

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    priority: json['priority'],
    completed: json['completed'],
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'priority': priority,
    'completed': completed,
  };
}

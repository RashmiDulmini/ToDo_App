class Task {
  int id;
  String title;
  String priority;
  bool completed;
  String? notes;
  String? date;
  String? time;
  bool? alarm;
  String? assignedUser;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    required this.completed,
    this.notes,
    this.date,
    this.time,
    this.alarm,
    this.assignedUser,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      completed: json['completed'],
      notes: json['notes'],
      date: json['date'],
      time: json['time'],
      alarm: json['alarm'],
      assignedUser: json['assigned_user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'completed': completed,
      'notes': notes,
      'date': date,
      'time': time,
      'alarm': alarm,
      'assigned_user': assignedUser, 
    };
  }
}

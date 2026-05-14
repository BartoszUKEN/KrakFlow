class Task {
  final int id;
  final String title;
  final String deadline;
  bool done;
  final String priority;

  Task({
    required this.id,
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "deadline": deadline,
      "priority": priority,
      "done": done,
    };
  }

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map["id"] ?? 0,
      title: map["title"] ?? '',
      deadline: map["deadline"] ?? '',
      priority: map["priority"] ?? 'niski',
      done: map["done"] ?? false,
    );
  }
}

class TaskRepository {
  static List<Task> tasks = [
    Task(
      id: 1,
      title: "Zrobić zadanie z HTML",
      deadline: "jutro",
      done: false,
      priority: "wysoki",
    ),
    Task(
      id: 2,
      title: "Wstać wcześnie",
      deadline: "dzisiaj",
      done: false,
      priority: "niski",
    ),
    Task(
      id: 3,
      title: "Przeczytać o widgetach",
      deadline: "w tym tygodniu",
      done: true,
      priority: "średni",
    ),
    Task(
      id: 4,
      title: "Nauczyć się na test",
      deadline: "dwie godziny",
      done: false,
      priority: "wysoki",
    ),
  ];
}
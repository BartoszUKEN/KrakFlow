class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title, 
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskRepository {
  static List<Task> tasks = [
    Task(
      title: "Zrobić zadanie z HTML", 
      deadline: "jutro", 
      done: false, 
      priority: "wysoki"
    ),
    Task(
      title: "Wstać wcześnie", 
      deadline: "dzisiaj",
      done: false, 
      priority: "niski"
    ),
    Task(
      title: "Przeczytać o widgetach", 
      deadline: "w tym tygodniu", 
      done: true, 
      priority: "średni"
    ),
    Task(
      title: "Nauczyć się na test", 
      deadline: "dwie godziny", 
      done: false, 
      priority: "wysoki"
    ),
  ];
}
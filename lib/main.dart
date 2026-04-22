import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  List<Task> tasks = [
    Task(title: "Zrobić zadanie z HTML", deadline: "jutro", done: false, priority: "wysoki"),
    Task(title: "Wstać wcześnie", deadline: "dzisiaj", done: false, priority: "niski"),
    Task(title: "Przeczytać o widgetach", deadline: "w tym tygodniu", done: true, priority: "średni"),
    Task(title: "Nauczyć się na test", deadline: "dwie godziny", done: false, priority: "wysoki"),
  ];

  @override
  Widget build(BuildContext context) {

    int completedTasks = tasks.where((zadanie) => zadanie.done).length;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("KrakFlow"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column (
            children: [
              Text("Masz dziś ${tasks.length} zadania, z czego wykonano: $completedTasks"),
              SizedBox(height: 16),
              Text(
                "Dzisiejsze zadania nad listą: ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

            SizedBox(height: 20),

            Expanded (
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                    title: tasks[index].title,
                    subtitle: tasks[index].deadline,
                    icon: Icons.check_circle_outline,
                    done: tasks[index].done,
                    priority: tasks[index].priority,
                  );
                }
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

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

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool done;
  final String priority;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.done,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? Colors.green : Colors.grey,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(priority),
    )
    );
  }
}
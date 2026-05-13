import 'package:flutter/material.dart';
import 'task_repository.dart';
import 'task_api_services.dart';

void main() {
  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "Wszystkie";
  late Future<List<Task>> tasksFuture;

  @override
  void initState() {
    super.initState();
    tasksFuture = TaskApiService().fetchTasks();
  }

  void _alertusuwania(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potwierdzenie"),
          content: const Text("Czy na pewno chcesz usunąć WSZYSTKIE lokalne zadania?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  TaskRepository.tasks.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Pomyślnie wyczyszczono listę lokalną"),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("Usuń"),
            ),
          ],
        );
      },
    );
  }

  Widget _filterButton(String label, Color color) {
    bool isSelected = selectedFilter == label;
    return TextButton(
      onPressed: () => setState(() => selectedFilter = label),
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : color,
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () {
              if (TaskRepository.tasks.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Lista lokalna jest pusta!")),
                );
              } else {
                _alertusuwania(context);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton("Wszystkie", Colors.blue),
                _filterButton("Do zrobienia", Colors.orange),
                _filterButton("Wykonane", Colors.green),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: tasksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Błąd API: ${snapshot.error}"));
                  }

                  final apiTasks = snapshot.data ?? [];
                  List<Task> combinedList = [...TaskRepository.tasks, ...apiTasks];

                  int total = combinedList.length;
                  int completed = combinedList.where((t) => t.done).length;

                  List<Task> displayList = combinedList;
                  if (selectedFilter == "Wykonane") {
                    displayList = combinedList.where((t) => t.done).toList();
                  } else if (selectedFilter == "Do zrobienia") {
                    displayList = combinedList.where((t) => !t.done).toList();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Masz dziś $total zadań, z czego wykonano: $completed",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Lista zadań:",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final task = displayList[index];
                            return TaskCard(
                              title: task.title,
                              subtitle: task.deadline,
                              icon: Icons.check_circle_outline,
                              done: task.done,
                              priority: task.priority,
                              onChanged: (value) {
                                setState(() {
                                  task.done = value!;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditTaskScreen(task: null)),
          );

          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool done;
  final String priority;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.done,
    required this.priority,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: done ? Colors.grey[100] : Colors.white,
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: done,
          onChanged: onChanged,
        ),
        title: Text(
          title,
          style: TextStyle(
            decoration: done
              ? TextDecoration.lineThrough 
              : TextDecoration.none,
            color: done 
              ? Colors.grey 
              : Colors.black,
            fontWeight: done 
              ? FontWeight.normal 
              : FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Text(priority),
      )
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text ("Nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: deadlineController,
              decoration: InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "niski/średni/wysoki",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            ElevatedButton(
                  onPressed: () {
                    final newTask = Task(
                      title: titleController.text,
                      deadline: deadlineController.text,
                      done: false,
                      priority: priorityController.text,
                    );
                    Navigator.pop(context, newTask);
                  },
                  child: Text ("Zapisz"),
                ),
          ],
        )
      )
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final Task? task;

  EditTaskScreen({super.key, this.task}) {
    if (task != null) {
      titleController.text = task!.title;
      deadlineController.text = task!.deadline;
      priorityController.text = task!.priority;
    }
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task == null ? "Nowe zadanie" : "Edytuj zadanie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final resultTask = Task(
                    title: titleController.text,
                    deadline: deadlineController.text,
                    done: task?.done ?? false,
                    priority: priorityController.text,
                  );
                  Navigator.pop(context, resultTask);
                },
                child: const Text("ZAPISZ"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
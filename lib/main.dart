import 'package:flutter/material.dart';
import 'task_repository.dart';

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

  String filter = "Wszystkie";
  String selectedFilter = "Wszystkie";

  void _alertusuwania (BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Potwierdzenie"),
        content: const Text("Czy na pewno chcesz usunąć WSZYSTKIE zadania?"),
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
                  content: Text("Pomyślnie wyczyszczono całą listę zadań"),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text("Usuń"),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {

    List<Task> filteredTasks = TaskRepository.tasks;
    if (selectedFilter == "Wykonane") {
      filteredTasks = TaskRepository.tasks
        .where((task) => task.done)
        .toList();
    } else if (selectedFilter == "Do zrobienia") {
      filteredTasks = TaskRepository.tasks
        .where((task) => !task.done)
        .toList();
    }

    int completedTasks = TaskRepository.tasks.where((zadanie) => zadanie.done).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () {
              if (TaskRepository.tasks.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Lista jest już pusta!"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                _alertusuwania(context);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column (
          children: [
            Text("Masz dziś ${TaskRepository.tasks.length} zadania, z czego wykonano: $completedTasks"),
            
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "Wszystkie";
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: selectedFilter == "Wszystkie" ? Colors.blue : Colors.transparent,
                    foregroundColor: selectedFilter == "Wszystkie" ? Colors.white : Colors.blue,
                  ),
                  child: Text("Wszystkie"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "Do zrobienia";
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: selectedFilter == "Do zrobienia" ? Colors.orange : Colors.transparent,
                    foregroundColor: selectedFilter == "Do zrobienia" ? Colors.white : Colors.orange,
                  ),
                  child: Text("Do zrobienia"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedFilter = "Wykonane";
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: selectedFilter == "Wykonane" ? Colors.green : Colors.transparent,
                    foregroundColor: selectedFilter == "Wykonane" ? Colors.white : Colors.green,
                  ),
                  child: Text("Wykonane"),
                ),
              ],
            ),

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
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final task = filteredTasks[index];

                return Dismissible(
                  key: ValueKey(task.title + index.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      TaskRepository.tasks.remove(task);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Usunięto zadanie: ${task.title}"),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating, // Wygląda nowocześniej
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: TaskCard(
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
                    onTap: () async {
                      final Task? updatedTask = await Navigator.push (
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(task: task),
                        ),
                      );
                      if (updatedTask != null) {
                        setState(() {
                          TaskRepository.tasks[index] = updatedTask;
                        });
                      }
                    },
                  ),
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
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(task: null),
            ),
          );

          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: Icon(Icons.add),
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
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'task_repository.dart';

class TaskApiService {
  static const String apiUrl = 'https://dummyjson.com/todos';

  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List todosList = data['todos'];

      return todosList.map((json) {
        return Task(
          id: json['id'],
          title: json['todo'],
          deadline: "Z serwera",
          done: json['completed'],
          priority: "średni",
        );
      }).toList();
    } else {
      throw Exception('Błąd pobierania danych');
    }
  }
}
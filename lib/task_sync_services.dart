import 'task_api_services.dart';
import 'task_local_database.dart';

class TaskSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
    if (Tasklocaldatabase.isEmpty()) {
      final apiService = TaskApiService();
      final tasks = await apiService.fetchTasks();
      await Tasklocaldatabase.saveTasks(tasks);
    }
  }
}
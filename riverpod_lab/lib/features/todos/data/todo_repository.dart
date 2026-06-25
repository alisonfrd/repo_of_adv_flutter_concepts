import 'package:riverpod_lab/features/todos/domain/todo.dart';

class TodoRepository {
  Future<List<Todo>> fechTodos() async {
    await Future<void>.delayed(const Duration(seconds: 2));

    return const [
      Todo(id: '1', title: 'Estudar Provider', completed: true),
      Todo(id: '2', title: 'Estudar FutrureProvider', completed: false),
      Todo(id: '3', title: 'Estudar AsyncNotifierProvider', completed: false),
    ];
  }

  Future<void> saveTodos(List<Todo> todo) async {
    await Future<void>.delayed(const Duration(seconds: 3));
  }
}

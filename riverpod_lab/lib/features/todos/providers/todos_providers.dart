import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_lab/features/todos/data/todo_repository.dart';
import 'package:riverpod_lab/features/todos/domain/todo.dart';
import 'package:uuid/uuid.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

class TodoNotifier extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() async {
    final repository = ref.watch(todoRepositoryProvider);
    return repository.fechTodos();
  }

  Future<void> addTodo(String title) async {
    final previousState = state;
    final currentTodos = state.value ?? [];

    final newTodo = Todo(id: const Uuid().v4(), title: title, completed: false);

    final updatedTodos = [...currentTodos, newTodo];

    state = AsyncData(updatedTodos);

    try {
      final repository = ref.read(todoRepositoryProvider);
      await repository.saveTodos(updatedTodos);
    } catch (error, stackTrace) {
      state = previousState;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> toogleTodo(String id) async {
    final previousState = state;
    final currentTodos = state.value ?? [];

    final updatedTodos = [
      for (final todo in currentTodos)
        if (todo.id == id) todo.copyWith(completed: !todo.completed) else todo,
    ];

    state = AsyncData(updatedTodos);

    try {
      final repository = ref.read(todoRepositoryProvider);
      await repository.saveTodos(updatedTodos);
    } catch (e, s) {
      state = previousState;
      state = AsyncError(e, s);
    }
  }

  Future<void> removeTodo(String id) async {
    final previousState = state;
    final currentTodos = state.value ?? [];

    final updatedTodos = [
      for (final todo in currentTodos)
        if (todo.id != id) todo,
    ];

    state = AsyncData(updatedTodos);

    try {
      final repository = ref.read(todoRepositoryProvider);
      await repository.saveTodos(updatedTodos);
    } catch (e, s) {
      state = previousState;
      state = AsyncError(e, s);
    }
  }
}

final todosProvider = AsyncNotifierProvider<TodoNotifier, List<Todo>>(
  TodoNotifier.new,
);

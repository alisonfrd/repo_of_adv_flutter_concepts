import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_lab/features/todos/providers/todos_providers.dart';

class TodosPage extends ConsumerWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos com AsyncNotifier'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(todosProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: switch (todos) {
        AsyncData(:final value) => ListView.builder(
          itemCount: value.length,
          itemBuilder: (context, index) {
            final todo = value[index];

            return CheckboxListTile(
              value: todo.completed,
              title: Text(todo.title),
              onChanged: (value) {
                ref.read(todosProvider.notifier).toogleTodo(todo.id);
              },
              secondary: IconButton(
                onPressed: () {
                  ref.read(todosProvider.notifier).removeTodo(todo.id);
                },
                icon: Icon(Icons.delete),
              ),
            );
          },
        ),
        AsyncError(:final error) => Center(child: Text('Erro: $error')),
        _ => const Center(child: CircularProgressIndicator()),
      },

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? title = await showDialog(
            context: context,
            builder: (context) {
              final controller = TextEditingController();

              return AlertDialog(
                title: const Text('Nova tarefa'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Difite a tarefa',
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          );

          if (title == null || title.trim().isEmpty) {
            return;
          }

          ref.read(todosProvider.notifier).addTodo(title.trim());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc/todo_state.dart';
import '../widgets/todo_item.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  @override
  void initState() {
    super.initState();
    // Load todos when page initializes
    Future.microtask(() => context.read<TodoProvider>().getTodos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App (ChangeNotifier + Provider)'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/address');
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Addresses'),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          final state = provider.state;

          // Show error snackbar
          if (state.error != null) {
            Future.microtask(() {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.error?.message}')),
              );
              provider.clearError();
            });
          }

          // Show success snackbar
          if (state.isSuccess) {
            Future.microtask(() {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Success!')));
              provider.clearSuccess();
            });
          }

          // Loading state
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty state
          if (state.todos.isEmpty) {
            return const Center(child: Text('No todos yet. Add one!'));
          }

          // Todos list
          return ListView.separated(
            itemCount: state.todos.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final todo = state.todos[index];
              return TodoItem(
                todo: todo,
                onToggle: () {
                  final updated = todo.copyWith(isCompleted: !todo.isCompleted);
                  context.read<TodoProvider>().updateTodo(updated);
                },
                onDelete: () =>
                    context.read<TodoProvider>().deleteTodo(todo.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TodoProvider>().addTodo(
                titleController.text,
                descriptionController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

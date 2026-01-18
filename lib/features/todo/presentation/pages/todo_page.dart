import 'package:enterprise_architecture_with_flutter/features/todo/presentation/notifiers/todo_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/todo_providers.dart';
import '../bloc/todo_state.dart';
import '../widgets/todo_item.dart';

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  @override
  void initState() {
    super.initState();
    // Load todos when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(todoNotifierProvider.notifier).loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the todo state from the notifier
    final todoState = ref.watch(todoNotifierProvider);
    final notifier = ref.read(todoNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TODO (Riverpod + StateNotifier + Clean Architecture)',
        ),
      ),
      body: _buildBody(todoState, notifier),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, notifier),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(TodoState state, TodoNotifier notifier) {
    return switch (state) {
      TodoInitial() => const Center(child: Text('Initializing...')),
      TodoLoading() => const Center(child: CircularProgressIndicator()),
      TodoLoaded(todos: final todos) => _buildLoadedState(todos, notifier),
      TodoError(failure: final failure) => _buildErrorState(failure, notifier),
    };
  }

  Widget _buildLoadedState(List todos, TodoNotifier notifier) {
    if (todos.isEmpty) {
      return const Center(child: Text('No TODOs. Add one!'));
    }
    return ListView.separated(
      itemCount: todos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) => TodoItem(
        todo: todos[index],
        onToggle: () => notifier.toggleTodo(id: todos[index].id),
      ),
    );
  }

  Widget _buildErrorState(dynamic failure, TodoNotifier notifier) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: ${failure.message}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => notifier.retry(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, TodoNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => _TodoDialog(
        onAdd: (title, description) {
          notifier.addTodo(title: title, description: description);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _TodoDialog extends StatefulWidget {
  final Function(String title, String description) onAdd;

  const _TodoDialog({required this.onAdd});

  @override
  State<_TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<_TodoDialog> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add TODO'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('todo_title_field'),
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            key: const Key('todo_description_field'),
            controller: _desc,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _title.text.trim();
            if (title.isEmpty) {
              setState(() => _error = 'Title is required');
              return;
            }
            widget.onAdd(title, _desc.text.trim());
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

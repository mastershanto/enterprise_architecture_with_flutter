import 'package:flutter/material.dart';

import '../../domain/entities/todo.dart';

class TodoItem extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TodoItem({super.key, required this.todo, this.onToggle, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.isCompleted,
        onChanged: (_) => onToggle?.call(),
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: todo.description.isEmpty ? null : Text(todo.description),
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    );
  }
}

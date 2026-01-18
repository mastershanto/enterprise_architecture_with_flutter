import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/add_todo_uc.dart';
import '../../domain/usecases/get_todos_uc.dart';
import '../../domain/usecases/toggle_todo_uc.dart';
import '../bloc/todo_state.dart';


/// This replaces the BLoC pattern with a simpler state management approach
class TodoNotifier extends StateNotifier<TodoState> {
  final GetTodosUseCase getTodosUseCase;
  final AddTodoUseCase addTodoUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;

  TodoNotifier({
    required this.getTodosUseCase,
    required this.addTodoUseCase,
    required this.toggleTodoUseCase,
  }) : super(const TodoInitial());

  /// Load all todos from the repository
  Future<void> loadTodos() async {
    state = const TodoLoading();
    final result = await getTodosUseCase(const NoParams());

    result.fold(
      (failure) => state = TodoError(failure: failure),
      (todos) => state = TodoLoaded(todos: todos),
    );
  }

  /// Add a new todo
  Future<void> addTodo({
    required String title,
    required String description,
  }) async {
    state = const TodoLoading();

    final result = await addTodoUseCase(
      AddTodoParams(title: title, description: description),
    );

    // After adding, reload the list to ensure consistency
    result.fold(
      (failure) => state = TodoError(failure: failure),
      (_) => loadTodos(),
    );
  }

  /// Toggle a todo's completion status
  Future<void> toggleTodo({required String id}) async {
    final result = await toggleTodoUseCase(ToggleTodoParams(id: id));

    // After toggling, reload the list to ensure consistency
    result.fold(
      (failure) => state = TodoError(failure: failure),
      (_) => loadTodos(),
    );
  }

  /// Retry loading after an error
  Future<void> retry() => loadTodos();
}

import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/todo.dart';
import '../../domain/usecases/add_todo_uc.dart';
import '../../domain/usecases/get_todos_uc.dart';
import '../../domain/usecases/toggle_todo_uc.dart';

// State class
class TodoState extends Equatable {
  final List<TodoEntity> todos;
  final bool isLoading;
  final Failure? error;
  final bool isSuccess;

  const TodoState({
    this.todos = const [],
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  TodoState copyWith({
    List<TodoEntity>? todos,
    bool? isLoading,
    Failure? error,
    bool? isSuccess,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }

  @override
  List<Object?> get props => [todos, isLoading, error, isSuccess];
}

// ChangeNotifier Provider
class TodoProvider extends ChangeNotifier {
  final GetTodosUseCase getTodosUsecase;
  final AddTodoUseCase addTodoUsecase;
  final ToggleTodoUseCase toggleTodoUsecase;

  TodoState _state = const TodoState();

  TodoState get state => _state;

  TodoProvider({
    required this.getTodosUsecase,
    required this.addTodoUsecase,
    required this.toggleTodoUsecase,
  });

  // Get all todos
  Future<void> getTodos() async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    final result = await getTodosUsecase.call(const NoParams());

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, error: failure));
      },
      (todos) {
        _updateState(
          _state.copyWith(isLoading: false, todos: todos, isSuccess: true),
        );
      },
    );
  }

  // Add todo
  Future<void> addTodo(String title, String description) async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    final result = await addTodoUsecase.call(
      AddTodoParams(title: title, description: description),
    );

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, error: failure));
      },
      (todo) {
        final updatedTodos = [..._state.todos, todo];
        _updateState(
          _state.copyWith(
            isLoading: false,
            todos: updatedTodos,
            isSuccess: true,
          ),
        );
      },
    );
  }

  // Update todo
  Future<void> updateTodo(TodoEntity todo) async {
    _updateState(_state.copyWith(isLoading: true, error: null));

    final result = await toggleTodoUsecase.call(ToggleTodoParams(id: todo.id));

    result.fold(
      (failure) {
        _updateState(_state.copyWith(isLoading: false, error: failure));
      },
      (updatedTodo) {
        final updatedTodos = _state.todos.map((t) {
          return t.id == updatedTodo.id ? updatedTodo : t;
        }).toList();
        _updateState(
          _state.copyWith(
            isLoading: false,
            todos: updatedTodos,
            isSuccess: true,
          ),
        );
      },
    );
  }

  // Delete todo
  Future<void> deleteTodo(String id) async {
    // Since there's no delete use case, just remove from local state
    final updatedTodos = _state.todos.where((t) => t.id != id).toList();
    _updateState(_state.copyWith(todos: updatedTodos, isSuccess: true));
  }

  // Reset error
  void clearError() {
    _updateState(_state.copyWith(error: null));
  }

  // Reset success
  void clearSuccess() {
    _updateState(_state.copyWith(isSuccess: false));
  }

  void _updateState(TodoState newState) {
    _state = newState;
    notifyListeners();
  }
}

# 🚀 State Management Migration - Providers with Equatable

## Overview

The app's state management has been **completely refactored** from BLoC pattern with Freezed to **Riverpod StateNotifier with Equatable**. This provides:

- ✅ Simpler state management (no build_runner needed)
- ✅ Better code readability and understanding
- ✅ Pure Dart equality checking with Equatable
- ✅ Cleaner architecture with fewer dependencies
- ✅ Easier to test and debug
- ✅ Full clean architecture compliance maintained

---

## What Changed

### 1. **Removed Dependencies**

```yaml
# REMOVED (no longer needed):
- freezed_annotation: ^2.4.4
- freezed: ^2.5.2
- json_serializable: ^6.8.0
- build_runner: ^2.4.8
- drift, drift_flutter, sqlite3_flutter_libs (database stuff)
- json_annotation: ^4.9.0
```

**Why?** Freezed required build_runner to generate code. Equatable provides equality checking without code generation.

### 2. **Model Layer Updates**

#### Before (Freezed)
```dart
@freezed
class TodoModel with _$TodoModel {
  const factory TodoModel({
    required String id,
    required String title,
    @Default('') String description,
    @Default(false) bool isCompleted,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _TodoModel;
  factory TodoModel.fromJson(...) => _$TodoModelFromJson(json);
}
```

#### After (Equatable)
```dart
class TodoModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TodoModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  // Manual copyWith implementation
  TodoModel copyWith({...}) { ... }

  // Manual fromJson/toJson
  factory TodoModel.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }

  @override
  List<Object?> get props => [id, title, description, ...];
}
```

**Benefits:**
- No generated code files
- Clearer what's happening
- Easy to understand and modify

### 3. **Entity Layer Updates**

```dart
class TodoEntity extends Equatable {
  final String id;
  final String title;
  // ... fields ...

  @override
  List<Object?> get props => [id, title, description, ...];
}
```

**Change:** Added `Equatable` for proper equality comparison.

### 4. **State Management Architecture**

#### Before (BLoC Pattern)
```
TodoPage
  ↓
ref.read(todoBlocProvider).add(TodoLoadRequested())
  ↓
TodoBloc (handles events, emits states)
  ↓
StateNotifierProvider wrapping TodoBloc
```

#### After (StateNotifier Pattern)
```
TodoPage
  ↓
ref.read(todoNotifierProvider.notifier).loadTodos()
  ↓
TodoNotifier (directly manages state)
  ↓
StateNotifierProvider<TodoNotifier, TodoState>
```

### 5. **New TodoNotifier Class**

**File:** `lib/features/todo/presentation/notifiers/todo_notifier.dart`

```dart
class TodoNotifier extends StateNotifier<TodoState> {
  final GetTodosUseCase getTodosUseCase;
  final AddTodoUseCase addTodoUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;

  TodoNotifier({...}) : super(const TodoInitial());

  Future<void> loadTodos() async {
    state = const TodoLoading();
    final result = await getTodosUseCase(const NoParams());
    result.fold(
      (failure) => state = TodoError(failure: failure),
      (todos) => state = TodoLoaded(todos: todos),
    );
  }

  Future<void> addTodo({required String title, required String description}) { ... }
  Future<void> toggleTodo({required String id}) { ... }
  Future<void> retry() => loadTodos();
}
```

**Features:**
- Direct state management (no events)
- Clean method-based API
- Integrated use cases
- Automatic state updates

### 6. **Updated Providers**

**File:** `lib/features/todo/providers/todo_providers.dart`

```dart
// Repository Provider
final todoRepositoryProvider = Provider<TodoRepository>((ref) { ... });

// Use Case Providers
final getTodosUseCaseProvider = Provider<GetTodosUseCase>((ref) { ... });
final addTodoUseCaseProvider = Provider<AddTodoUseCase>((ref) { ... });
final toggleTodoUseCaseProvider = Provider<ToggleTodoUseCase>((ref) { ... });

// Main State Provider
final todoNotifierProvider = 
    StateNotifierProvider.autoDispose<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(
    getTodosUseCase: ref.watch(getTodosUseCaseProvider),
    addTodoUseCase: ref.watch(addTodoUseCaseProvider),
    toggleTodoUseCase: ref.watch(toggleTodoUseCaseProvider),
  );
});
```

**No BLoC provider anymore!**

### 7. **Simplified UI Layer**

**Before:**
```dart
class TodoPage extends ConsumerStatefulWidget {
  @override
  void initState() {
    ref.read(todoBlocProvider).add(const TodoLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final bloc = ref.watch(todoBlocProvider);
    
    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          switch (state) {
            case TodoLoaded(:final todos):
              return TodoItem(
                onToggle: () => bloc.add(TodoToggleRequested(...))
              );
          }
        },
      ),
    );
  }
}
```

**After:**
```dart
class TodoPage extends ConsumerStatefulWidget {
  @override
  void initState() {
    ref.read(todoNotifierProvider.notifier).loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    final todoState = ref.watch(todoNotifierProvider);
    final notifier = ref.read(todoNotifierProvider.notifier);

    return Scaffold(
      body: switch (todoState) {
        TodoLoaded(todos: final todos) => ListView(...),
        TodoError(:final failure) => _buildErrorState(failure, notifier),
        TodoLoading() => const CircularProgressIndicator(),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () => notifier.addTodo(title: '...', description: '...'),
      ),
    );
  }
}
```

**Benefits:**
- No BlocProvider wrapper needed
- No BlocBuilder needed
- Direct method calls to notifier
- Cleaner, more intuitive code

---

## File Structure Changes

### Removed Files
```
❌ lib/features/todo/presentation/bloc/todo_bloc.dart
❌ lib/features/todo/presentation/bloc/todo_event.dart
❌ lib/features/todo/data/models/todo_model.freezed.dart (generated)
❌ lib/features/todo/data/models/todo_model.g.dart (generated)
```

### New Files
```
✅ lib/features/todo/presentation/notifiers/todo_notifier.dart
   └─ Contains TodoNotifier class managing state
```

### Modified Files
```
📝 lib/pubspec.yaml (removed freezed, build_runner)
📝 lib/features/todo/data/models/todo_model.dart (Equatable instead of Freezed)
📝 lib/features/todo/domain/entities/todo.dart (added Equatable)
📝 lib/features/todo/presentation/bloc/todo_state.dart (unchanged - already Equatable)
📝 lib/features/todo/providers/todo_providers.dart (removed BLoC provider)
📝 lib/features/todo/presentation/pages/todo_page.dart (simplified, StateNotifier)
```

---

## How to Use the New System

### Loading Data

```dart
final notifier = ref.read(todoNotifierProvider.notifier);
await notifier.loadTodos();
```

### Adding a TODO

```dart
final notifier = ref.read(todoNotifierProvider.notifier);
await notifier.addTodo(title: 'Buy milk', description: 'Whole milk');
```

### Toggling a TODO

```dart
final notifier = ref.read(todoNotifierProvider.notifier);
await notifier.toggleTodo(id: 'todo_id_123');
```

### Watching State

```dart
final todoState = ref.watch(todoNotifierProvider);

switch (todoState) {
  case TodoLoaded(todos: final todos):
    // Show list
  case TodoLoading():
    // Show spinner
  case TodoError(failure: final failure):
    // Show error
  case TodoInitial():
    // Show initial state
}
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│              PRESENTATION LAYER (UI)                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  TodoPage (Consumer Widget)                              │
│  ├─ Watches: todoNotifierProvider                        │
│  ├─ Reads: todoNotifierProvider.notifier                │
│  └─ Calls: notifier.loadTodos(), addTodo(), etc.        │
│                                                          │
│  ┌──────────────────────────────────────────────┐      │
│  │ TodoNotifier (StateNotifier)                 │      │
│  ├─ Manages: TodoState                          │      │
│  ├─ Methods: loadTodos, addTodo, toggleTodo    │      │
│  └─ Uses: Use Cases from Domain                │      │
│  └──────────────────────────────────────────────┘      │
│                                                          │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│               DOMAIN LAYER (Business Logic)              │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Use Cases:                                              │
│  ├─ GetTodosUseCase                                     │
│  ├─ AddTodoUseCase                                      │
│  └─ ToggleTodoUseCase                                   │
│                                                          │
└──────────────────────────────────────────────────────────┘
                          ↓
┌──────────────────────────────────────────────────────────┐
│                DATA LAYER (Implementation)               │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  TodoRepository (Implementation)                         │
│  ├─ Uses: LocalDataSource                              │
│  ├─ Uses: RemoteDataSource                             │
│  └─ Returns: Either<Failure, Result>                   │
│                                                          │
│  Models:                                                │
│  ├─ TodoModel (with Equatable)                         │
│  └─ JSON serialization (manual)                        │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Key Advantages

### 1. **No Code Generation**
- ✅ No build_runner needed
- ✅ Faster project builds
- ✅ Less complexity

### 2. **Easier to Understand**
- ✅ Code is explicit and visible
- ✅ No "magic" generated code
- ✅ Better for learning

### 3. **Better State Management**
- ✅ StateNotifier is simpler than BLoC
- ✅ Riverpod is more powerful than Provider
- ✅ Direct method calls instead of events

### 4. **Cleaner Clean Architecture**
- ✅ All layers remain separated
- ✅ Domain layer is pure business logic
- ✅ No framework dependency in domain

### 5. **Easier Testing**
- ✅ Mock TodoNotifier directly
- ✅ Test use cases independently
- ✅ No complex event handling

---

## Migration Checklist

- ✅ Removed freezed and build_runner from pubspec.yaml
- ✅ Converted TodoModel to Equatable
- ✅ Converted TodoEntity to Equatable
- ✅ Created TodoNotifier (StateNotifier)
- ✅ Updated todo_providers.dart
- ✅ Updated TodoPage to use new provider
- ✅ Removed BLoC files (todo_bloc.dart, todo_event.dart)
- ✅ Removed generated files (freezed.dart, g.dart)
- ✅ Maintained clean architecture structure
- ✅ Kept error handling and state management

---

## Running the App

```bash
flutter pub get
flutter run
```

**That's it!** No need for `flutter pub run build_runner build` anymore.

---

## Adding New Features

### Example: Add Delete Functionality

1. **Domain Layer** - Add DeleteTodoUseCase
```dart
class DeleteTodoUseCase extends UseCase<void, DeleteTodoParams> {
  // Implementation
}
```

2. **Presentation Layer** - Add method to TodoNotifier
```dart
Future<void> deleteTodo({required String id}) async {
  final result = await deleteTodoUseCase(DeleteTodoParams(id: id));
  result.fold(
    (failure) => state = TodoError(failure: failure),
    (_) => loadTodos(),
  );
}
```

3. **UI Layer** - Call the method
```dart
onPressed: () => notifier.deleteTodo(id: todo.id),
```

**That's it!** Clean, simple, and follows the architecture.

---

## Questions?

This setup follows **Clean Architecture** principles while using modern Riverpod state management. The code is explicit, testable, and maintainable.

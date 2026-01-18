# 🎯 Quick Start Guide - New State Management System

## What You Need to Know

Your app now uses **Riverpod StateNotifier + Equatable** instead of BLoC + Freezed.

## Key Differences

### Before (BLoC)
```dart
// UI sending events
bloc.add(TodoLoadRequested());

// UI receiving state via BlocBuilder
BlocBuilder<TodoBloc, TodoState>(
  builder: (context, state) { ... }
)
```

### After (StateNotifier)
```dart
// UI calling methods directly
notifier.loadTodos();

// UI watching state via ref.watch
final todoState = ref.watch(todoNotifierProvider);
```

---

## Common Operations

### Initialize and Load Data
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(todoNotifierProvider.notifier).loadTodos();
  });
}
```

### Watch State in UI
```dart
@override
Widget build(BuildContext context) {
  final todoState = ref.watch(todoNotifierProvider);
  
  return switch (todoState) {
    TodoLoading() => CircularProgressIndicator(),
    TodoLoaded(todos: final todos) => TodoList(todos),
    TodoError(failure: final f) => ErrorWidget(f),
    TodoInitial() => InitialWidget(),
  };
}
```

### Add a Todo
```dart
final notifier = ref.read(todoNotifierProvider.notifier);
notifier.addTodo(
  title: 'My Task',
  description: 'Do this today',
);
```

### Toggle a Todo
```dart
final notifier = ref.read(todoNotifierProvider.notifier);
notifier.toggleTodo(id: 'todo_123');
```

### Handle Errors
```dart
switch (todoState) {
  case TodoError(failure: final failure):
    // failure is a Failure object with message property
    Text(failure.message)
    
    // Retry button
    ElevatedButton(
      onPressed: () => notifier.retry(),
      child: Text('Retry'),
    )
}
```

---

## File Structure

```
lib/features/todo/
├── data/
│   ├── datasources/
│   ├── models/
│   │   └── todo_model.dart        ← Uses Equatable now
│   └── repositories/
│
├── domain/
│   ├── entities/
│   │   └── todo.dart              ← Uses Equatable now
│   ├── repositories/
│   └── usecases/
│
├── presentation/
│   ├── pages/
│   │   └── todo_page.dart         ← Simplified UI
│   ├── notifiers/
│   │   └── todo_notifier.dart     ← New! Manages state
│   ├── widgets/
│   └── bloc/
│       └── todo_state.dart        ← Only states now
│
└── providers/
    └── todo_providers.dart        ← StateNotifierProvider
```

---

## State Types

```dart
sealed class TodoState extends Equatable {
  const TodoState();
}

class TodoInitial extends TodoState { }           // First load
class TodoLoading extends TodoState { }           // Loading data
class TodoLoaded extends TodoState {              // Got data
  final List<TodoEntity> todos;
}
class TodoError extends TodoState {               // Error occurred
  final Failure failure;
}
```

---

## Notifier Methods

All methods in `TodoNotifier`:

```dart
class TodoNotifier extends StateNotifier<TodoState> {
  // Load all todos
  Future<void> loadTodos()
  
  // Add a new todo
  Future<void> addTodo({
    required String title,
    required String description,
  })
  
  // Toggle completion status
  Future<void> toggleTodo({required String id})
  
  // Retry after error
  Future<void> retry()
}
```

---

## No More...

❌ **BLoC classes** - Events and Bloc logic  
❌ **Freezed classes** - Code generation  
❌ **build_runner** - Building generated code  
❌ **Complex event handling** - Just call methods  
❌ **BlocProvider wrapper** - Direct Riverpod watching  
❌ **BlocBuilder** - Use ref.watch() instead  

---

## Useful Tips

### Tip 1: Get Notifier Reference
```dart
final notifier = ref.read(todoNotifierProvider.notifier);
```

### Tip 2: Watch State
```dart
final state = ref.watch(todoNotifierProvider);
```

### Tip 3: Manual Null Check
```dart
if (todoState is TodoLoaded) {
  final todos = todoState.todos;
  // Use todos
}
```

### Tip 4: Access All Information
```dart
// State tells you everything
todoState.runtimeType  // Which state?
if (todoState is TodoError) {
  print(todoState.failure.message);
}
```

---

## Testing Example

```dart
test('loadTodos updates state', () async {
  final notifier = TodoNotifier(
    getTodosUseCase: mockGetTodos,
    addTodoUseCase: mockAddTodo,
    toggleTodoUseCase: mockToggleTodo,
  );
  
  await notifier.loadTodos();
  
  expect(notifier.state, isA<TodoLoaded>());
  final loaded = notifier.state as TodoLoaded;
  expect(loaded.todos.length, greaterThan(0));
});
```

---

## Comparison Chart

| Feature | BLoC | StateNotifier |
|---------|------|---------------|
| **Code Generation** | Yes (Freezed) | No |
| **Events** | Yes | No |
| **State Classes** | Sealed | Sealed |
| **Method Calls** | No (events) | Yes |
| **Learning Curve** | Steep | Gentle |
| **Setup** | Complex | Simple |
| **Build Time** | Slow | Fast |

---

## Next Steps

1. ✅ Remove freezed/build_runner from pubspec.yaml
2. ✅ Convert models to Equatable
3. ✅ Create StateNotifier
4. ✅ Update providers
5. ✅ Update UI to use new provider
6. ✅ Delete BLoC files

**All done!** Your app is now using modern Riverpod state management.

---

## Questions?

Q: **Why StateNotifier instead of BLoC?**  
A: StateNotifier is simpler, faster, and doesn't need code generation.

Q: **Do I have to use Equatable?**  
A: No, but it's recommended for proper equality checking.

Q: **Can I still use BLoC?**  
A: Yes, domain and data layers don't care. But StateNotifier is simpler.

Q: **Is this production-ready?**  
A: Absolutely! Riverpod is used in many production apps.

Q: **How do I add more features?**  
A: Add use cases in domain, add methods to notifier, call from UI.

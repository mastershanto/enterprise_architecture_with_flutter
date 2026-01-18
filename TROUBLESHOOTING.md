# 🔧 Troubleshooting Guide - State Management Migration

## Common Issues and Solutions

---

## Issue 1: "todoNotifierProvider is not defined"

### Error
```
Error: The getter 'todoNotifierProvider' isn't defined for the class 'BuildContext'.
```

### Solution
Make sure you've updated `todo_providers.dart`:

```dart
// ✅ CORRECT
import '../presentation/notifiers/todo_notifier.dart';

final todoNotifierProvider =
    StateNotifierProvider.autoDispose<TodoNotifier, TodoState>((ref) {
  return TodoNotifier(...);
});
```

Check that the file is saved and run:
```bash
flutter pub get
flutter run
```

---

## Issue 2: "Cannot find todo_notifier.dart"

### Error
```
Error: Cannot find file 'lib/features/todo/presentation/notifiers/todo_notifier.dart'
```

### Solution
The file might not have been created. Create it manually:

1. Create the directory:
   ```bash
   mkdir -p lib/features/todo/presentation/notifiers
   ```

2. Create the file `todo_notifier.dart` with the full content from `MIGRATION_COMPLETE.md`

Or copy the content from the example in this guide.

---

## Issue 3: "BLoC is no longer working"

### Error
```
Unhandled Exception: type 'Null' is not a subtype of type 'TodoBloc'
```

### Solution
You still have BLoC code somewhere. Remove all BLoC references:

**In UI:**
```dart
// ❌ WRONG
bloc.add(TodoLoadRequested());
BlocBuilder<TodoBloc, TodoState>(...)

// ✅ CORRECT
notifier.loadTodos();
ref.watch(todoNotifierProvider);
```

**In providers:**
```dart
// ❌ REMOVE THIS
final todoBlocProvider = Provider.autoDispose<TodoBloc>((ref) {
  // ...
});

// ✅ USE THIS INSTEAD
final todoNotifierProvider = StateNotifierProvider.autoDispose<TodoNotifier, TodoState>((ref) {
  // ...
});
```

---

## Issue 4: "Freezed model not found"

### Error
```
Error: Cannot find file 'todo_model.freezed.dart'
```

### Solution
Delete the import or delete any existing freezed files:

```bash
rm lib/features/todo/data/models/todo_model.freezed.dart
rm lib/features/todo/data/models/todo_model.g.dart
```

Update `todo_model.dart` to NOT import freezed:

```dart
// ❌ REMOVE THESE
// part 'todo_model.freezed.dart';
// part 'todo_model.g.dart';

// ✅ JUST KEEP THIS
import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  // ...
}
```

---

## Issue 5: "Cannot cast TodoBloc to TodoNotifier"

### Error
```
type 'TodoBloc' is not a subtype of type 'TodoNotifier'
```

### Solution
You're mixing old and new systems. Replace all BLoC code:

**Step 1:** Delete BLoC files
```bash
rm lib/features/todo/presentation/bloc/todo_bloc.dart
rm lib/features/todo/presentation/bloc/todo_event.dart
```

**Step 2:** Keep only `todo_state.dart`
```bash
# Keep this - it's still used
lib/features/todo/presentation/bloc/todo_state.dart
```

**Step 3:** Update UI completely
```dart
// OLD WAY - REMOVE
final bloc = ref.watch(todoBlocProvider);
bloc.add(TodoLoadRequested());
BlocBuilder<TodoBloc, TodoState>(...)

// NEW WAY - USE THIS
final notifier = ref.read(todoNotifierProvider.notifier);
notifier.loadTodos();
final todoState = ref.watch(todoNotifierProvider);
```

---

## Issue 6: "Hot reload not working"

### Error
```
Hot reload shows old state/behavior
```

### Solution
Do a full restart instead:

```bash
# Stop the app (Ctrl+C)
# Then run:
flutter run
# Or press 'r' to hot reload, 's' to hot restart
```

If that doesn't work:
```bash
flutter clean
flutter pub get
flutter run
```

---

## Issue 7: "Equatable not comparing correctly"

### Error
```
Two identical TodoModels don't compare as equal
```

### Solution
Make sure you've added the `props` getter:

```dart
class TodoModel extends Equatable {
  final String id;
  final String title;
  // ... other fields ...

  // ✅ ADD THIS
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isCompleted,
    createdAt,
    updatedAt,
  ];
}
```

Include ALL fields in `props`.

---

## Issue 8: "import of BloC still showing errors"

### Error
```
import 'package:flutter_bloc/flutter_bloc.dart'; is still in the file
```

### Solution
Remove flutter_bloc imports:

**In todo_page.dart:**
```dart
// ❌ REMOVE THESE
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';

// ✅ KEEP THIS
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/todo_providers.dart';
import '../bloc/todo_state.dart';
```

---

## Issue 9: "State not updating in UI"

### Error
```
UI doesn't show new data after adding/toggling todo
```

### Solution
Make sure you're watching the provider:

```dart
// ❌ WRONG - Not watching
final notifier = ref.read(todoNotifierProvider.notifier);

// ✅ CORRECT - Watching state
final todoState = ref.watch(todoNotifierProvider);
final notifier = ref.read(todoNotifierProvider.notifier);
```

Or check if state is being updated in notifier:

```dart
Future<void> addTodo({required String title, required String description}) async {
  state = const TodoLoading();  // ✅ Update state
  final result = await addTodoUseCase(...);
  result.fold(
    (f) => state = TodoError(failure: f),  // ✅ Update state
    (_) => loadTodos(),  // ✅ This calls loadTodos() which updates state
  );
}
```

---

## Issue 10: "Cannot read property of null"

### Error
```
NoSuchMethodError: The getter 'notifier' was called on null.
```

### Solution
You're reading the provider outside of a ConsumerWidget context:

```dart
// ❌ WRONG - outside ConsumerWidget
final notifier = ref.read(todoNotifierProvider.notifier);

// ✅ CORRECT - inside ConsumerWidget.build
class TodoPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(todoNotifierProvider.notifier);
    // Now it works
  }
}
```

Or use `ConsumerStatefulWidget`:
```dart
class TodoPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends ConsumerState<TodoPage> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(todoNotifierProvider.notifier);
    // Works here too
  }
}
```

---

## Issue 11: "Duplicate 'part' directive"

### Error
```
Duplicate 'part' directive 'part of'
```

### Solution
Remove any remaining freezed directives:

**In todo_model.dart:**
```dart
// ❌ REMOVE THESE
part 'todo_model.freezed.dart';
part 'todo_model.g.dart';
```

Keep only:
```dart
import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  // ...
}
```

---

## Issue 12: "build_runner is still being used"

### Error
```
Command 'flutter pub run build_runner build' still works?
```

### Solution
You can remove it from dev_dependencies, but it won't hurt to keep it:

```yaml
# OPTIONAL - Remove these
dev_dependencies:
  build_runner: ^2.4.8        # ❌ Can remove
  freezed: ^2.5.2             # ❌ Can remove
  json_serializable: ^6.8.0   # ❌ Can remove
```

Just don't run `flutter pub run build_runner build` anymore!

---

## Issue 13: "TodoState not found"

### Error
```
Error: The name 'TodoState' is not defined.
```

### Solution
Make sure you're importing it:

```dart
import '../bloc/todo_state.dart';  // ✅ This should still exist
```

Don't delete `todo_state.dart`! It defines all the state classes.

---

## Issue 14: "Need to reload to see changes"

### Error
```
Hot reload not picking up new code
```

### Solution
Do a hot restart:
```bash
# In terminal where flutter run is active:
r    # Hot reload
R    # Hot restart
```

Or stop and restart:
```bash
# Ctrl+C to stop
flutter run
```

If still not working:
```bash
flutter clean
flutter pub get
flutter run
```

---

## Issue 15: "Comparison of models failing"

### Error
```
Two todos from same data don't compare equal
```

### Solution
Verify Equatable implementation in all models:

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

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isCompleted,
    createdAt,
    updatedAt,
  ];
}
```

Same for `TodoEntity`:
```dart
class TodoEntity extends Equatable {
  // ... fields ...

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isCompleted,
    createdAt,
    updatedAt,
  ];
}
```

---

## Quick Debugging Checklist

Before asking for help, verify:

- [ ] `todoBlocProvider` removed from `todo_providers.dart`
- [ ] `todoNotifierProvider` added to `todo_providers.dart`
- [ ] `todo_notifier.dart` created and contains `TodoNotifier` class
- [ ] `TodoPage` uses `ref.watch(todoNotifierProvider)`
- [ ] `TodoPage` calls `notifier.loadTodos()` not `bloc.add(...)`
- [ ] No imports of `todo_bloc.dart` or `todo_event.dart`
- [ ] No imports of `todo_model.freezed.dart` or `todo_model.g.dart`
- [ ] `TodoModel` extends `Equatable` with `props`
- [ ] `TodoEntity` extends `Equatable` with `props`
- [ ] `pubspec.yaml` doesn't have freezed/build_runner in dependencies
- [ ] `flutter pub get` ran successfully
- [ ] No orphaned BLoC files in the project

---

## Still Having Issues?

### Step 1: Read the Docs
Check these files in order:
1. `QUICK_START_STATE_MANAGEMENT.md` - For quick answers
2. `STATE_MANAGEMENT_MIGRATION.md` - For detailed info
3. `ARCHITECTURE_COMPARISON.md` - For before/after details

### Step 2: Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Step 3: Check Git Status
```bash
git status
```

Look for:
- Deleted BLoC files (good)
- Deleted generated files (good)
- Modified provider files (expected)
- New notifier file (good)

### Step 4: Review the Code
The implementation is explicit and well-commented. Read through:
- `lib/features/todo/presentation/notifiers/todo_notifier.dart`
- `lib/features/todo/providers/todo_providers.dart`
- `lib/features/todo/presentation/pages/todo_page.dart`

### Step 5: Start Fresh
If everything fails, create new files:
1. Create `todo_notifier.dart` from scratch
2. Update `todo_providers.dart` from scratch
3. Update `todo_page.dart` from scratch
4. Delete old files

---

## Common Fix Patterns

### Pattern 1: Replace All BLoC Calls
```bash
# Search for and replace in your editor
Find: bloc.add(
Replace: notifier.
```

### Pattern 2: Update State Watching
```bash
Find: BlocBuilder<TodoBloc, TodoState>(
Replace: (
  final todoState = ref.watch(todoNotifierProvider);
  switch (todoState)
)
```

### Pattern 3: Remove Event Imports
```bash
Find: import '../bloc/todo_event.dart';
Replace: (delete the line)
```

### Pattern 4: Add Notifier Provider Imports
```bash
Find: import '../bloc/todo_bloc.dart';
Replace: import '../../providers/todo_providers.dart';
```

---

## Performance Check

If your app is slow:

1. **Check state updates:**
   ```dart
   print('State changed to: ${todoState.runtimeType}');
   ```

2. **Verify no infinite loops:**
   - Make sure notifier doesn't call itself
   - Make sure UI doesn't trigger multiple state changes

3. **Check Equatable props:**
   - Verify all fields are in `props`
   - Missing fields = unnecessary rebuilds

4. **Monitor with Riverpod Inspector:**
   ```bash
   # Install Riverpod inspector
   # https://pub.dev/packages/riverpod_generator
   ```

---

## Success!

If you see:
- ✅ Todos loading on app start
- ✅ Can add new todos
- ✅ Can toggle todos
- ✅ Error handling works
- ✅ Retry button works

**You're done!** The migration is complete.

---

## Need More Help?

1. **For architecture questions:** Read `ARCHITECTURE_COMPARISON.md`
2. **For API questions:** Read `QUICK_START_STATE_MANAGEMENT.md`
3. **For implementation details:** Read `STATE_MANAGEMENT_MIGRATION.md`
4. **For code examples:** Look at the actual implementation files

Happy debugging! 🐛➡️✅

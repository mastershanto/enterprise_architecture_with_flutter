import 'package:get_it/get_it.dart';

import '../../features/todo/data/datasources/todo_local_datasource.dart';
import '../../features/todo/data/datasources/todo_remote_datasource.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/domain/usecases/add_todo_uc.dart';
import '../../features/todo/domain/usecases/get_todos_uc.dart';
import '../../features/todo/domain/usecases/toggle_todo_uc.dart';
import '../../features/todo/presentation/bloc/todo_state.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Data Sources
  getIt.registerSingleton<TodoLocalDataSource>(TodoLocalDataSourceInMemory());

  getIt.registerSingleton<TodoRemoteDataSource>(
    TodoRemoteDataSourceMock(latency: Duration.zero),
  );

  // Repository
  getIt.registerSingleton<TodoRepository>(
    TodoRepositoryImpl(
      localDataSource: getIt<TodoLocalDataSource>(),
      remoteDataSource: getIt<TodoRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<GetTodosUseCase>(
    GetTodosUseCase(repository: getIt<TodoRepository>()),
  );

  getIt.registerSingleton<AddTodoUseCase>(
    AddTodoUseCase(repository: getIt<TodoRepository>()),
  );

  getIt.registerSingleton<ToggleTodoUseCase>(
    ToggleTodoUseCase(repository: getIt<TodoRepository>()),
  );

  // Provider
  getIt.registerSingleton<TodoProvider>(
    TodoProvider(
      getTodosUsecase: getIt<GetTodosUseCase>(),
      addTodoUsecase: getIt<AddTodoUseCase>(),
      toggleTodoUsecase: getIt<ToggleTodoUseCase>(),
    ),
  );
}

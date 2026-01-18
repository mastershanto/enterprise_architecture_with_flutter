import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../features/address/data/datasources/address_local_datasource.dart';
import '../../features/address/data/datasources/address_remote_datasource.dart';
import '../../features/address/data/repositories/address_repository_impl.dart';
import '../../features/address/domain/repositories/address_repository.dart';
import '../../features/address/domain/usecases/delete_address_uc.dart';
import '../../features/address/domain/usecases/save_address_uc.dart';
import '../../features/address/presentation/bloc/address_state.dart';
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
  // HTTP Client
  getIt.registerSingleton<http.Client>(http.Client());

  // ============ TODO FEATURE ============
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

  // ============ ADDRESS FEATURE ============
  // Data Sources
  getIt.registerSingleton<AddressLocalDataSource>(
    AddressLocalDataSourceInMemory(),
  );

  getIt.registerSingleton<AddressRemoteDataSource>(
    AddressRemoteDataSourceImpl(httpClient: getIt<http.Client>()),
  );

  // Repository
  getIt.registerSingleton<AddressRepository>(
    AddressRepositoryImpl(
      remoteDataSource: getIt<AddressRemoteDataSource>(),
      localDataSource: getIt<AddressLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<SaveAddressUseCase>(
    SaveAddressUseCase(repository: getIt<AddressRepository>()),
  );

  getIt.registerSingleton<DeleteAddressUseCase>(
    DeleteAddressUseCase(repository: getIt<AddressRepository>()),
  );

  // Provider
  getIt.registerSingleton<AddressProvider>(
    AddressProvider(
      saveAddressUsecase: getIt<SaveAddressUseCase>(),
      deleteAddressUsecase: getIt<DeleteAddressUseCase>(),
    ),
  );
}

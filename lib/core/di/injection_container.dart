import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../features/address/data/datasources/address_local_datasource.dart';
import '../../features/address/data/datasources/address_remote_datasource.dart';
import '../../features/address/data/repositories/address_repository_impl.dart';
import '../../features/address/domain/repositories/address_repository.dart';
import '../../features/address/domain/usecases/delete_address_uc.dart';
import '../../features/address/domain/usecases/get_addresses_uc.dart';
import '../../features/address/domain/usecases/save_address_uc.dart';
import '../../features/address/presentation/bloc/address_state.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_cached_user_uc.dart';
import '../../features/auth/domain/usecases/login_uc.dart';
import '../../features/auth/domain/usecases/logout_uc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/todo/data/datasources/todo_local_datasource.dart';
import '../../features/todo/data/datasources/todo_remote_datasource.dart';
import '../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../features/todo/domain/repositories/todo_repository.dart';
import '../../features/todo/domain/usecases/add_todo_uc.dart';
import '../../features/todo/domain/usecases/get_todos_uc.dart';
import '../../features/todo/domain/usecases/toggle_todo_uc.dart';
import '../../features/todo/presentation/bloc/todo_state.dart';
import '../../features/vehicle/data/datasources/equipment_local_datasource.dart';
import '../../features/vehicle/data/datasources/equipment_remote_datasource.dart';
import '../../features/vehicle/data/repositories/equipment_repository_impl.dart';
import '../../features/vehicle/domain/repositories/equipment_repository.dart';
import '../../features/vehicle/domain/usecases/get_equipments_uc.dart';
import '../../features/vehicle/presentation/bloc/equipment_state.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // HTTP Clients
  final dio = Dio();

  // Add interceptor for auth token
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Get auth token from AuthProvider if available
        try {
          final authProvider = getIt<AuthProvider>();
          if (authProvider.user?.token != null) {
            options.headers['Authorization'] =
                'Bearer ${authProvider.user!.token}';
          }
        } catch (e) {
          // AuthProvider not yet registered, skip
        }
        return handler.next(options);
      },
    ),
  );

  getIt.registerSingleton<Dio>(dio);

  // ============ AUTH FEATURE ============
  // Data Sources
  getIt.registerSingleton<AuthLocalDataSource>(AuthLocalDataSourceInMemory());

  // Use MOCK for testing (accepts any credentials)
  getIt.registerSingleton<AuthRemoteDataSource>(AuthRemoteDataSourceMock());

  // Use REAL API (uncomment when backend is ready)
  // getIt.registerSingleton<AuthRemoteDataSource>(
  //   AuthRemoteDataSourceImpl(dioClient: getIt<Dio>()),
  // );

  // Repository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<LoginUseCase>(
    LoginUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerSingleton<LogoutUseCase>(
    LogoutUseCase(repository: getIt<AuthRepository>()),
  );

  getIt.registerSingleton<GetCachedUserUseCase>(
    GetCachedUserUseCase(repository: getIt<AuthRepository>()),
  );

  // Provider
  getIt.registerSingleton<AuthProvider>(
    AuthProvider(
      loginUsecase: getIt<LoginUseCase>(),
      logoutUsecase: getIt<LogoutUseCase>(),
      getCachedUserUsecase: getIt<GetCachedUserUseCase>(),
    ),
  );

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
    AddressRemoteDataSourceImpl(dioClient: getIt<Dio>()),
  );

  // Repository
  getIt.registerSingleton<AddressRepository>(
    AddressRepositoryImpl(
      remoteDataSource: getIt<AddressRemoteDataSource>(),
      localDataSource: getIt<AddressLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<GetAddressesUseCase>(
    GetAddressesUseCase(repository: getIt<AddressRepository>()),
  );

  getIt.registerSingleton<SaveAddressUseCase>(
    SaveAddressUseCase(repository: getIt<AddressRepository>()),
  );

  getIt.registerSingleton<DeleteAddressUseCase>(
    DeleteAddressUseCase(repository: getIt<AddressRepository>()),
  );

  // Provider
  getIt.registerSingleton<AddressProvider>(
    AddressProvider(
      getAddressesUsecase: getIt<GetAddressesUseCase>(),
      saveAddressUsecase: getIt<SaveAddressUseCase>(),
      deleteAddressUsecase: getIt<DeleteAddressUseCase>(),
    ),
  );

  // ============ VEHICLE EQUIPMENT FEATURE ============
  // Data Sources
  getIt.registerSingleton<EquipmentLocalDataSource>(
    EquipmentLocalDataSourceInMemory(),
  );

  // Use REAL API
  getIt.registerSingleton<EquipmentRemoteDataSource>(
    EquipmentRemoteDataSourceImpl(dioClient: getIt<Dio>()),
  );

  // Use MOCK for testing (uncomment if API not available)
  // getIt.registerSingleton<EquipmentRemoteDataSource>(
  //   EquipmentRemoteDataSourceMock(),
  // );

  // Repository
  getIt.registerSingleton<EquipmentRepository>(
    EquipmentRepositoryImpl(
      remoteDataSource: getIt<EquipmentRemoteDataSource>(),
      localDataSource: getIt<EquipmentLocalDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerSingleton<GetEquipmentsUseCase>(
    GetEquipmentsUseCase(repository: getIt<EquipmentRepository>()),
  );

  // Provider
  getIt.registerSingleton<EquipmentProvider>(
    EquipmentProvider(getEquipmentsUsecase: getIt<GetEquipmentsUseCase>()),
  );
}

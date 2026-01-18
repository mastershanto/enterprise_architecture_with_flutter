# Address Feature - Code Structure Reference

## Complete File Tree

```
lib/
├── features/
│   └── address/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── address_local_datasource.dart
│       │   │   │   └── AddressLocalDataSource (abstract)
│       │   │   │   └── AddressLocalDataSourceInMemory (impl)
│       │   │   │
│       │   │   └── address_remote_datasource.dart
│       │   │       ├── ApiException
│       │   │       ├── AddressRemoteDataSource (abstract)
│       │   │       └── AddressRemoteDataSourceImpl (impl)
│       │   │
│       │   ├── models/
│       │   │   └── address_model.dart
│       │   │       ├── AddressModel
│       │   │       └── toEntity() mapper
│       │   │
│       │   └── repositories/
│       │       └── address_repository_impl.dart
│       │           └── AddressRepositoryImpl (impl)
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── address.dart
│       │   │       └── AddressEntity
│       │   │
│       │   ├── repositories/
│       │   │   └── address_repository.dart
│       │   │       └── AddressRepository (abstract)
│       │   │
│       │   └── usecases/
│       │       ├── save_address_uc.dart
│       │       │   ├── SaveAddressUseCase
│       │       │   └── SaveAddressParams
│       │       │
│       │       └── delete_address_uc.dart
│       │           ├── DeleteAddressUseCase
│       │           └── DeleteAddressParams
│       │
│       └── presentation/
│           ├── bloc/
│           │   └── address_state.dart
│           │       ├── AddressState (immutable)
│           │       └── AddressProvider (ChangeNotifier)
│           │
│           └── pages/
│               └── address_page.dart
│                   └── AddressPage (example UI)
```

## Key Classes Summary

### Domain Layer

#### AddressEntity
```dart
class AddressEntity extends Equatable {
  final int id;
  final int userId;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double? latitude;
  final double? longitude;
  final String label;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // ... copyWith, props
}
```

#### SaveAddressUseCase
```dart
class SaveAddressUseCase extends UseCase<AddressEntity, SaveAddressParams> {
  @override
  Future<Either<Failure, AddressEntity>> call(SaveAddressParams params)
}

class SaveAddressParams extends Params {
  // Contains all address fields for input
}
```

#### DeleteAddressUseCase
```dart
class DeleteAddressUseCase extends UseCase<void, DeleteAddressParams> {
  @override
  Future<Either<Failure, void>> call(DeleteAddressParams params)
}

class DeleteAddressParams extends Params {
  final int id;
}
```

### Data Layer

#### AddressRemoteDataSourceImpl
```dart
class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  static const String baseUrl = 
    'https://nanaobiriyeboah.thewarriors.team/api';
  
  Future<AddressModel> saveAddress({...}) async
    // POST /address/save
  
  Future<void> deleteAddress({required int id}) async
    // DELETE /address/{id}
}
```

#### AddressRepositoryImpl
```dart
class AddressRepositoryImpl implements AddressRepository {
  // Validation
  // Remote call with fallback to local
  // Local caching
  // Error handling with Failure types
  
  Future<Either<Failure, AddressEntity>> saveAddress({...})
  Future<Either<Failure, void>> deleteAddress({required int id})
}
```

### Presentation Layer

#### AddressState
```dart
class AddressState extends Equatable {
  final AddressEntity? savedAddress;
  final bool isLoading;
  final Failure? error;
  final bool isSuccess;
  final bool isDeleted;
}
```

#### AddressProvider
```dart
class AddressProvider extends ChangeNotifier {
  AddressState _state = const AddressState();
  
  Future<void> saveAddress({...}) async
  Future<void> deleteAddress({required int id}) async
  void resetState()
  void clearError()
}
```

## Integration Points

### 1. Dependency Injection (injection_container.dart)
```dart
// HTTP Client
getIt.registerSingleton<http.Client>(http.Client());

// Data Sources
getIt.registerSingleton<AddressRemoteDataSource>(
  AddressRemoteDataSourceImpl(httpClient: getIt<http.Client>()),
);
getIt.registerSingleton<AddressLocalDataSource>(
  AddressLocalDataSourceInMemory(),
);

// Repository
getIt.registerSingleton<AddressRepository>(
  AddressRepositoryImpl(...),
);

// Use Cases
getIt.registerSingleton<SaveAddressUseCase>(...);
getIt.registerSingleton<DeleteAddressUseCase>(...);

// Provider
getIt.registerSingleton<AddressProvider>(...);
```

### 2. App Setup (main.dart)
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => getIt<AddressProvider>()),
    // ...other providers
  ],
  child: MaterialApp(...),
)
```

## Method Signatures

### Save Address
```dart
addressProvider.saveAddress(
  addressLine1: String,      // Required
  city: String,              // Required
  state: String,             // Required
  postalCode: String,        // Required
  country: String,           // Required
  label: String,             // Required (home, work, etc.)
  addressLine2: String?,     // Optional
  latitude: double?,         // Optional
  longitude: double?,        // Optional
)
```

### Delete Address
```dart
addressProvider.deleteAddress(
  id: int,  // Address ID from savedAddress.id
)
```

## Error Handling

All errors are wrapped in `Failure` types:
- `ServerFailure` - API/server errors
- `ValidationFailure` - Input validation
- `NetworkFailure` - Network issues
- `CacheFailure` - Cache issues

Access via: `state.error?.message`

## State Properties

```dart
state.savedAddress    // AddressEntity or null
state.isLoading       // true while processing
state.error           // Failure or null
state.isSuccess       // true after success
state.isDeleted       // true after deletion
```

---

This structure mirrors the Todo feature implementation, ensuring consistency across the codebase.

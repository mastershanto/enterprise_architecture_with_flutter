# Address Feature - Clean Architecture Implementation

This document describes the Address feature implementation following clean architecture principles.

## Overview

The Address feature provides functionality to save and delete user addresses through a REST API. It's built following the same enterprise architecture pattern as the Todo feature.

### API Details

- **Base URL**: `https://nanaobiriyeboah.thewarriors.team/api`
- **Save Endpoint**: `POST /address/save`
- **Delete Endpoint**: `DELETE /address/{id}`

## Architecture Layers

### 1. Domain Layer (`domain/`)

#### Entities
- **AddressEntity** (`entities/address.dart`): Core domain model representing an address with all properties

#### Repositories (Abstractions)
- **AddressRepository** (`repositories/address_repository.dart`): Abstract interface defining repository contract

#### Use Cases
- **SaveAddressUseCase** (`usecases/save_address_uc.dart`): Encapsulates business logic for saving addresses
  - Input: `SaveAddressParams` with all address fields
  - Output: `Either<Failure, AddressEntity>`
  
- **DeleteAddressUseCase** (`usecases/delete_address_uc.dart`): Encapsulates business logic for deleting addresses
  - Input: `DeleteAddressParams` with address ID
  - Output: `Either<Failure, void>`

### 2. Data Layer (`data/`)

#### Models
- **AddressModel** (`models/address_model.dart`): Data model with JSON serialization
  - `fromJson()`: Converts API response to model
  - `toJson()`: Converts model to JSON request
  - `toEntity()`: Maps data layer model to domain entity

#### Data Sources
- **AddressRemoteDataSource** (`datasources/address_remote_datasource.dart`): HTTP client implementation
  - Uses actual HTTP calls to the backend
  - Handles API communication and error handling
  
- **AddressLocalDataSource** (`datasources/address_local_datasource.dart`): In-memory caching
  - Provides offline-first capabilities
  - Caches recently saved/accessed addresses

#### Repository Implementation
- **AddressRepositoryImpl** (`repositories/address_repository_impl.dart`): Concrete repository
  - Coordinates between remote and local data sources
  - Implements validation logic
  - Provides error handling through Failure types

### 3. Presentation Layer (`presentation/`)

#### State Management
- **AddressState** (`bloc/address_state.dart`): Immutable state class
  - `savedAddress`: Currently saved address
  - `isLoading`: Loading status
  - `error`: Failure object if any
  - `isSuccess`: Success flag
  - `isDeleted`: Deletion status

#### Provider (ChangeNotifier)
- **AddressProvider** (`bloc/address_state.dart`): State management using Provider pattern
  - `saveAddress()`: Calls SaveAddressUseCase
  - `deleteAddress()`: Calls DeleteAddressUseCase
  - `resetState()`: Resets to initial state
  - `clearError()`: Clears error message

#### Pages
- **AddressPage** (`pages/address_page.dart`): Example UI showing how to use the feature
  - Form to input address details
  - Save and delete buttons
  - Error and success messages

## Usage Example

### In a Widget

```dart
import 'package:provider/provider.dart';
import 'features/address/presentation/bloc/address_state.dart';

class MyAddressWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        if (addressProvider.state.isLoading) {
          return const CircularProgressIndicator();
        }

        return Column(
          children: [
            // Save Address
            ElevatedButton(
              onPressed: () {
                addressProvider.saveAddress(
                  addressLine1: 'Dhaka',
                  city: 'Dhaka',
                  state: 'Dhaka',
                  postalCode: '12345',
                  country: 'bangladesh',
                  label: 'home',
                );
              },
              child: const Text('Save Address'),
            ),

            // Delete Address
            if (addressProvider.state.savedAddress != null)
              ElevatedButton(
                onPressed: () {
                  addressProvider.deleteAddress(
                    id: addressProvider.state.savedAddress!.id,
                  );
                },
                child: const Text('Delete Address'),
              ),

            // Show Error
            if (addressProvider.state.error != null)
              Text('Error: ${addressProvider.state.error!.message}'),

            // Show Saved Address
            if (addressProvider.state.savedAddress != null)
              Text('Saved: ${addressProvider.state.savedAddress!.label}'),
          ],
        );
      },
    );
  }
}
```

## API Response Format

### Save Address Response (201)

```json
{
  "status": true,
  "message": "Address saved successfully",
  "data": {
    "id": 43,
    "user_id": 3,
    "address_line1": "Dhaka",
    "address_line2": null,
    "city": "Dhaka",
    "state": "Dhaka",
    "postal_code": "12345",
    "country": "bangladesh",
    "latitude": null,
    "longitude": null,
    "label": "home",
    "created_at": "2026-01-18T13:46:46.000000Z",
    "updated_at": "2026-01-18T13:46:46.000000Z"
  },
  "code": 201
}
```

### Delete Address Response (200)

```json
{
  "status": true,
  "message": "Address deleted successfully",
  "data": null,
  "code": 200
}
```

## Error Handling

The feature uses domain-level Failure types for error handling:

- **ServerFailure**: API errors (invalid response, server errors)
- **ValidationFailure**: Input validation errors
- **NetworkFailure**: Network connectivity issues
- **CacheFailure**: Local cache issues

All errors are propagated through the `Either<Failure, T>` type using the `dartz` package.

## Dependency Injection

The address feature is registered in `core/di/injection_container.dart`:

```dart
// Data Sources
getIt.registerSingleton<AddressRemoteDataSource>(
  AddressRemoteDataSourceImpl(httpClient: getIt<http.Client>()),
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

## Integration Steps

1. The `AddressProvider` is already registered in `main.dart` with `MultiProvider`
2. Access it in any widget using `context.read<AddressProvider>()` or `Consumer<AddressProvider>`
3. Navigate to `AddressPage` to see a working example

## Testing

When testing this feature:

1. **Unit Tests**: Test use cases with mock repositories
2. **Repository Tests**: Test repository logic with mock data sources
3. **Widget Tests**: Test UI with mock providers

Use `mockito` package for mocking dependencies:

```dart
class MockAddressRepository extends Mock implements AddressRepository {}

test('SaveAddressUseCase calls repository', () async {
  final mockRepo = MockAddressRepository();
  final usecase = SaveAddressUseCase(repository: mockRepo);
  
  when(mockRepo.saveAddress(...)).thenAnswer((_) async => Right(address));
  
  final result = await usecase(params);
  
  verify(mockRepo.saveAddress(...)).called(1);
  expect(result.isSuccess, true);
});
```

## File Structure

```
features/address/
├── data/
│   ├── datasources/
│   │   ├── address_local_datasource.dart
│   │   └── address_remote_datasource.dart
│   ├── models/
│   │   └── address_model.dart
│   └── repositories/
│       └── address_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── address.dart
│   ├── repositories/
│   │   └── address_repository.dart
│   └── usecases/
│       ├── save_address_uc.dart
│       └── delete_address_uc.dart
└── presentation/
    ├── bloc/
    │   └── address_state.dart
    └── pages/
        └── address_page.dart
```

## Next Steps

1. Customize the `AddressPage` UI to match your design
2. Add validation rules specific to your business logic
3. Implement optimistic updates in the provider if needed
4. Add more address operations (get, list, update) following the same pattern
5. Write unit and widget tests for all layers

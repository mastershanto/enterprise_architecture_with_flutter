import 'package:dio/dio.dart';
import 'package:enterprise_architecture_with_flutter/features/address/data/datasources/address_remote_datasource.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dioClient;
  static const String baseUrl = 'https://nanaobiriyeboah.thewarriors.team/api';

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '$baseUrl/users/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'];
        return UserModel.fromJson(data);
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Login failed',
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      // Handle 401 and other error responses
      if (e.response != null) {
        final errorMessage = e.response?.data is Map
            ? e.response?.data['message'] ?? 'Invalid credentials'
            : 'Login error: Status ${e.response?.statusCode}';

        throw ApiException(
          message: errorMessage,
          statusCode: e.response?.statusCode ?? 500,
        );
      }

      // Network error
      throw ApiException(
        message: e.message ?? 'Network error occurred',
        statusCode: 500,
      );
    } catch (e) {
      throw ApiException(
        message: 'Unexpected error: ${e.toString()}',
        statusCode: 500,
      );
    }
  }
}

// Mock implementation for testing (no backend required)
class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock user data - accept any email/password for testing
    return UserModel(
      id: 3,
      name: 'Md Mizanur Rahman',
      email: email,
      address: '1 Parliament Sq, United Kingdom',
      latitude: '51.50092151117726',
      longitude: '-0.12617714703083838',
      emailVerifiedAt: '2026-01-14T12:29:25.000000Z',
      role: 'user',
      avatar: null,
      provider: null,
      providerId: null,
      token: '16|j8voZTEEjcRVhHaIrxUa5iVQvumzWqboe4ZM5a8leafd',
    );
  }
}

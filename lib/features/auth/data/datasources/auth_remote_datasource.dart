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
        options: Options(
          validateStatus: (status) {
            // Accept all status codes to handle them manually
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'];
        return UserModel.fromJson(data);
      } else {
        final errorMessage = response.data is Map
            ? response.data['message'] ?? 'Login failed: Invalid credentials'
            : 'Login failed: ${response.statusCode}';
        throw ApiException(
          message: errorMessage,
          statusCode: response.statusCode ?? 400,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response?.data is Map
            ? e.response?.data['message'] ?? 'Authentication failed'
            : 'Login error: ${e.response?.statusCode}';
        throw ApiException(
          message: errorMsg,
          statusCode: e.response?.statusCode ?? 500,
        );
      }
      throw ApiException(
        message: 'Network error: ${e.message}',
        statusCode: 500,
      );
    }
  }
}

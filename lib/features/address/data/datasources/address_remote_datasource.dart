import 'package:dio/dio.dart';

import '../models/address_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

abstract class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddresses();

  Future<AddressModel> saveAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    double? latitude,
    double? longitude,
    required String label,
  });

  Future<void> deleteAddress({required int id});
}

class AddressRemoteDataSourceImpl implements AddressRemoteDataSource {
  static const String baseUrl = 'https://nanaobiriyeboah.thewarriors.team/api';

  final Dio dioClient;
  String? _authToken;

  AddressRemoteDataSourceImpl({required this.dioClient});

  // Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, dynamic> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await dioClient.get(
        '$baseUrl/address/list',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        if (json['status'] == true && json['data'] != null) {
          final list = (json['data'] as List)
              .cast<Map<String, dynamic>>()
              .map((data) => AddressModel.fromJson(data))
              .toList();
          return list;
        } else {
          throw ApiException(
            message: json['message'] ?? 'Failed to fetch addresses',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ApiException(
          message: 'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to fetch addresses: $e');
    }
  }

  @override
  Future<AddressModel> saveAddress({
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    double? latitude,
    double? longitude,
    required String label,
  }) async {
    try {
      final response = await dioClient.post(
        '$baseUrl/address/save',
        data: {
          'address_line1': addressLine1,
          'address_line2': addressLine2,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
          'latitude': latitude,
          'longitude': longitude,
          'label': label,
        },
        options: Options(headers: _headers),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        if (json['status'] == true && json['data'] != null) {
          return AddressModel.fromJson(json['data'] as Map<String, dynamic>);
        } else {
          throw ApiException(
            message: json['message'] ?? 'Failed to save address',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ApiException(
          message: 'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to save address: $e');
    }
  }

  @override
  Future<void> deleteAddress({required int id}) async {
    try {
      final response = await dioClient.delete(
        '$baseUrl/address/$id',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final json = response.data as Map<String, dynamic>;
        if (json['status'] != true) {
          throw ApiException(
            message: json['message'] ?? 'Failed to delete address',
            statusCode: response.statusCode,
          );
        }
      } else {
        throw ApiException(
          message: 'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to delete address: $e');
    }
  }
}

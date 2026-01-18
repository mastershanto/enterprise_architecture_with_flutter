import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/address_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

abstract class AddressRemoteDataSource {
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

  final http.Client httpClient;

  AddressRemoteDataSourceImpl({required this.httpClient});

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
      final response = await httpClient.post(
        Uri.parse('$baseUrl/address/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'address_line1': addressLine1,
          'address_line2': addressLine2,
          'city': city,
          'state': state,
          'postal_code': postalCode,
          'country': country,
          'latitude': latitude,
          'longitude': longitude,
          'label': label,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
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
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to save address: $e',
      );
    }
  }

  @override
  Future<void> deleteAddress({required int id}) async {
    try {
      final response = await httpClient.delete(
        Uri.parse('$baseUrl/address/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
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
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'Failed to delete address: $e',
      );
    }
  }
}

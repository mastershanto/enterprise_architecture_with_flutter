import 'package:dio/dio.dart';
import 'package:enterprise_architecture_with_flutter/features/address/data/datasources/address_remote_datasource.dart';


import '../models/equipment_model.dart';

abstract class EquipmentRemoteDataSource {
  Future<List<EquipmentModel>> getEquipments();
}

class EquipmentRemoteDataSourceImpl implements EquipmentRemoteDataSource {
  final Dio dioClient;
  static const String baseUrl = 'https://automoto54.com/api';

  EquipmentRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<EquipmentModel>> getEquipments() async {
    try {
      final response = await dioClient.get('$baseUrl/vehicle/equipment');

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle if data is a list directly or nested in a 'data' key
        final List<dynamic> equipmentList = data is List
            ? data
            : (data['data'] as List? ?? data['equipments'] as List? ?? []);

        return equipmentList
            .map(
              (item) => EquipmentModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw ApiException(
          message: 'Failed to fetch equipments',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw ApiException(
          message: e.response?.data['message'] ?? 'Failed to fetch equipments',
          statusCode: e.response?.statusCode ?? 500,
        );
      }
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

class EquipmentRemoteDataSourceMock implements EquipmentRemoteDataSource {
  @override
  Future<List<EquipmentModel>> getEquipments() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      const EquipmentModel(
        id: 1,
        name: 'ABS',
        description: 'Anti-lock Braking System',
      ),
      const EquipmentModel(
        id: 2,
        name: 'Air Conditioning',
        description: 'Climate Control',
      ),
      const EquipmentModel(
        id: 3,
        name: 'Airbags',
        description: 'Safety Airbags',
      ),
      const EquipmentModel(
        id: 4,
        name: 'Cruise Control',
        description: 'Speed Control',
      ),
      const EquipmentModel(
        id: 5,
        name: 'GPS Navigation',
        description: 'Navigation System',
      ),
      const EquipmentModel(
        id: 6,
        name: 'Parking Sensors',
        description: 'Rear Parking Sensors',
      ),
      const EquipmentModel(
        id: 7,
        name: 'Bluetooth',
        description: 'Wireless Connectivity',
      ),
    ];
  }
}

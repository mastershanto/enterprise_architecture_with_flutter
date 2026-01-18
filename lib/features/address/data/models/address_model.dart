import 'package:equatable/equatable.dart';

import '../../domain/entities/address.dart';

class AddressModel extends Equatable {
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

  const AddressModel({
    required this.id,
    required this.userId,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.latitude,
    this.longitude,
    required this.label,
    required this.createdAt,
    required this.updatedAt,
  });

  AddressModel copyWith({
    int? id,
    int? userId,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    double? latitude,
    double? longitude,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      label: json['label'] as String,
      createdAt: json['created_at'] is DateTime
          ? json['created_at'] as DateTime
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] is DateTime
          ? json['updated_at'] as DateTime
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'address_line1': addressLine1,
    'address_line2': addressLine2,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'label': label,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    id,
    userId,
    addressLine1,
    addressLine2,
    city,
    state,
    postalCode,
    country,
    latitude,
    longitude,
    label,
    createdAt,
    updatedAt,
  ];
}

extension AddressModelMapping on AddressModel {
  AddressEntity toEntity() => AddressEntity(
    id: id,
    userId: userId,
    addressLine1: addressLine1,
    addressLine2: addressLine2,
    city: city,
    state: state,
    postalCode: postalCode,
    country: country,
    latitude: latitude,
    longitude: longitude,
    label: label,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

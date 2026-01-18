import 'package:equatable/equatable.dart';

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

  const AddressEntity({
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

  AddressEntity copyWith({
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
    return AddressEntity(
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

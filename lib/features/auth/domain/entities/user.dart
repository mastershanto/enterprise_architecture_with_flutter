import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? emailVerifiedAt;
  final String? role;
  final String? avatar;
  final String? provider;
  final String? providerId;
  final String token;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.address,
    this.latitude,
    this.longitude,
    this.emailVerifiedAt,
    this.role,
    this.avatar,
    this.provider,
    this.providerId,
    required this.token,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    address,
    latitude,
    longitude,
    emailVerifiedAt,
    role,
    avatar,
    provider,
    providerId,
    token,
  ];
}

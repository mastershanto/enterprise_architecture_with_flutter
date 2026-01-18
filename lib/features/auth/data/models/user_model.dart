import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.address,
    super.latitude,
    super.longitude,
    super.emailVerifiedAt,
    super.role,
    super.avatar,
    super.provider,
    super.providerId,
    required super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      address: json['address'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      role: json['role'] as String?,
      avatar: json['avatar'] as String?,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'email_verified_at': emailVerifiedAt,
      'role': role,
      'avatar': avatar,
      'provider': provider,
      'provider_id': providerId,
      'token': token,
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      address: address,
      latitude: latitude,
      longitude: longitude,
      emailVerifiedAt: emailVerifiedAt,
      role: role,
      avatar: avatar,
      provider: provider,
      providerId: providerId,
      token: token,
    );
  }
}

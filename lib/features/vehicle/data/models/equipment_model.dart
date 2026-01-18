import '../../domain/entities/equipment.dart';

class EquipmentModel extends Equipment {
  const EquipmentModel({
    required super.id,
    required super.name,
    super.description,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['id'] as int,
      name: json['title'] as String, // API uses 'title' not 'name'
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'description': description};
  }

  Equipment toEntity() {
    return Equipment(id: id, name: name, description: description);
  }
}

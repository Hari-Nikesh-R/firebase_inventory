import 'package:equatable/equatable.dart';

class InventoryCategory extends Equatable {
  final String id;
  final String name;
  final String? description;

  const InventoryCategory({
    required this.id,
    required this.name,
    this.description,
  });

  factory InventoryCategory.fromFirestore(String id, Map<String, dynamic> data) {
    return InventoryCategory(
      id: id,
      name: data['name'] ?? '',
      description: data['description'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'description': description,
  };

  @override
  List<Object?> get props => [id, name, description];
}
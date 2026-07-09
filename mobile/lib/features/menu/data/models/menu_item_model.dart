import '../../domain/entities/menu_item.dart';

class MenuItemModel extends MenuItem {
  final String restaurantId;
  final String category;
  final bool isAvailable;

  MenuItemModel({
    required super.id,
    required this.restaurantId,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required this.category,
    required this.isAvailable,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}
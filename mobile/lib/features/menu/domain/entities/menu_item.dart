class MenuItem {
  final String id;
  final String name;
  final String description;
  final int price; // in smallest currency unit
  final String imageUrl;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

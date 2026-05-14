class RestaurantPin {
  final String id;
  final String name;
  final double rating;
  final double distanceKm;
  final double offsetX;
  final double offsetY;
  final bool isOpen;
  final List<String> tags;
  final String imageUrl;

  const RestaurantPin({
    required this.id,
    required this.name,
    required this.rating,
    required this.distanceKm,
    required this.offsetX,
    required this.offsetY,
    required this.isOpen,
    required this.tags,
    required this.imageUrl,
  });
}

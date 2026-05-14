class LockerSize {
  final String id;
  final String size;
  final int price;
  final String dimensions;
  final bool isRecommended;

  const LockerSize({
    required this.id,
    required this.size,
    required this.price,
    required this.dimensions,
    this.isRecommended = false,
  });
}

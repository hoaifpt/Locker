class DeliveryPackageSize {
  final String id;
  final String size;
  final int price;
  final String description;
  final bool recommended;

  const DeliveryPackageSize({
    required this.id,
    required this.size,
    required this.price,
    required this.description,
    required this.recommended,
  });
}

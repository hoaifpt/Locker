/// Pure domain entity - không phụ thuộc framework hay data layer
class Locker {
  final String id;
  final String code;
  final bool isOccupied;
  final String location;

  const Locker({
    required this.id,
    required this.code,
    required this.isOccupied,
    this.location = '',
  });
}

class StorageDuration {
  final String id;
  final String label;
  final int durationHours;
  final bool isRecommended;

  const StorageDuration({
    required this.id,
    required this.label,
    required this.durationHours,
    this.isRecommended = false,
  });
}

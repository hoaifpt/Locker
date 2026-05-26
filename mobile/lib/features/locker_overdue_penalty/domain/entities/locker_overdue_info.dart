class LockerOverdueInfo {
  final String lockerId;
  final Duration overdue;
  final double dailyFee;
  final Duration freeHours;

  LockerOverdueInfo({
    required this.lockerId,
    required this.overdue,
    required this.dailyFee,
    required this.freeHours,
  });

  double get totalPenalty => (overdue.inDays * dailyFee).toDouble();
}

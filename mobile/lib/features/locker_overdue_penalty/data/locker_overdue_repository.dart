import '../domain/entities/locker_overdue_info.dart';
import '../domain/repositories/i_locker_overdue_repository.dart';

/// Simple concrete repository used for demo / wiring.
/// Replace with real network/local data source as needed.
class LockerOverdueRepository implements ILockerOverdueRepository {
  @override
  Future<LockerOverdueInfo> fetchOverdueInfo() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Sample data matching the original Figma design
    return LockerOverdueInfo(
      lockerId: 'A-102',
      overdue: const Duration(days: 2),
      dailyFee: 2.00,
      freeHours: const Duration(hours: 48),
    );
  }
}

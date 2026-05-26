import '../entities/locker_overdue_info.dart';
import '../repositories/i_locker_overdue_repository.dart';

class GetOverdueInfoUseCase {
  final ILockerOverdueRepository repository;

  GetOverdueInfoUseCase(this.repository);

  Future<LockerOverdueInfo> call() => repository.fetchOverdueInfo();
}

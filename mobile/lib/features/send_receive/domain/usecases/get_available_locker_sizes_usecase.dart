import '../entities/locker_size.dart';
import '../repositories/i_send_receive_repository.dart';

class GetAvailableLockerSizesUseCase {
  final ISendReceiveRepository repository;

  GetAvailableLockerSizesUseCase({required this.repository});

  Future<List<LockerSize>> call() {
    return repository.getAvailableLockerSizes();
  }
}

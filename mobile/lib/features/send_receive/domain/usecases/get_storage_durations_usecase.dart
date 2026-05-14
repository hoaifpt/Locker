import '../entities/storage_duration.dart';
import '../repositories/i_send_receive_repository.dart';

class GetStorageDurationsUseCase {
  final ISendReceiveRepository repository;

  GetStorageDurationsUseCase({required this.repository});

  Future<List<StorageDuration>> call() {
    return repository.getStorageDurations();
  }
}

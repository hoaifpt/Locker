import '../entities/delivery_package_size.dart';
import '../repositories/i_delivery_repository.dart';

class GetDeliveryPackageSizes {
  final IDeliveryRepository _repository;

  GetDeliveryPackageSizes(this._repository);

  Future<List<DeliveryPackageSize>> call() {
    return _repository.getPackageSizes();
  }
}

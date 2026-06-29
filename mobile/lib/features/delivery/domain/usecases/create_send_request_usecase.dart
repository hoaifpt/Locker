import '../entities/delivery_request.dart';
import '../repositories/i_delivery_repository.dart';

class CreateSendRequest {
  final IDeliveryRepository _repository;

  CreateSendRequest(this._repository);

  Future<String> call(SendDeliveryRequest request) {
    return _repository.createSendRequest(request);
  }
}
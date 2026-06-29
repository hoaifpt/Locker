import '../repositories/i_delivery_repository.dart';

class SubmitReceiveCode {
  final IDeliveryRepository _repository;

  SubmitReceiveCode(this._repository);

  Future<String> call(String code) {
    return _repository.submitReceiveCode(code);
  }
}
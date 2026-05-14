import '../entities/delivery_package_size.dart';
import '../entities/delivery_request.dart';

abstract class IDeliveryRepository {
  Future<List<DeliveryPackageSize>> getPackageSizes();
  Future<String> createSendRequest(SendDeliveryRequest request);
  Future<String> submitReceiveCode(String code);
}

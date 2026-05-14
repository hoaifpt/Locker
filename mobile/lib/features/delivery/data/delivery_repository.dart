import '../domain/entities/delivery_package_size.dart';
import '../domain/entities/delivery_request.dart';
import '../domain/repositories/i_delivery_repository.dart';
import 'models/delivery_package_size_model.dart';

class DeliveryRepository implements IDeliveryRepository {
  static const _packageSizes = <DeliveryPackageSizeModel>[
    DeliveryPackageSizeModel(
      id: 'size-s',
      size: 'S',
      price: 15000,
      description: 'Phù hợp kiện nhỏ',
      recommended: true,
    ),
    DeliveryPackageSizeModel(
      id: 'size-m',
      size: 'M',
      price: 25000,
      description: 'Phù hợp hộp vừa',
      recommended: false,
    ),
    DeliveryPackageSizeModel(
      id: 'size-l',
      size: 'L',
      price: 45000,
      description: 'Phù hợp hàng lớn',
      recommended: false,
    ),
  ];

  @override
  Future<List<DeliveryPackageSize>> getPackageSizes() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _packageSizes;
  }

  @override
  Future<String> createSendRequest(SendDeliveryRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return 'Đã tạo yêu cầu gửi hàng cho size ${request.packageSizeId}';
  }

  @override
  Future<String> submitReceiveCode(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return 'Đã xác nhận mã nhận hàng: $code';
  }
}

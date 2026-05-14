import '../domain/entities/locker_size.dart';
import '../domain/entities/send_receive_order.dart';
import '../domain/entities/storage_duration.dart';
import '../domain/repositories/i_send_receive_repository.dart';
import 'models/locker_size_model.dart';
import 'models/send_receive_order_model.dart';
import 'models/storage_duration_model.dart';

class SendReceiveRepository implements ISendReceiveRepository {
  static const _lockerSizes = <LockerSizeModel>[
    LockerSizeModel(
      id: 'size-s',
      size: 'S',
      price: 15000,
      dimensions: '30x25x15cm',
      isRecommended: false,
      imageAsset: 'assets/Container.png',
    ),
    LockerSizeModel(
      id: 'size-m',
      size: 'M',
      price: 25000,
      dimensions: '45x35x25cm',
      isRecommended: true,
      imageAsset: 'assets/Medium size locker compartment.png',
    ),
    LockerSizeModel(
      id: 'size-l',
      size: 'L',
      price: 45000,
      dimensions: '60x50x40cm',
      isRecommended: false,
      imageAsset: 'assets/Large size locker compartment.png',
    ),
  ];

  static const _storageDurations = <StorageDurationModel>[
    StorageDurationModel(
      id: 'duration-1h',
      label: '1 Giờ',
      durationHours: 1,
      isRecommended: false,
    ),
    StorageDurationModel(
      id: 'duration-4h',
      label: '4 Giờ',
      durationHours: 4,
      isRecommended: true,
    ),
    StorageDurationModel(
      id: 'duration-full-day',
      label: 'Trong ngày',
      durationHours: 24,
      isRecommended: false,
    ),
    StorageDurationModel(
      id: 'duration-long-term',
      label: 'Gửi lâu dài',
      durationHours: 720, // 30 days
      isRecommended: false,
    ),
  ];

  @override
  Future<List<LockerSize>> getAvailableLockerSizes() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _lockerSizes;
  }

  @override
  Future<List<StorageDuration>> getStorageDurations() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return _storageDurations;
  }

  @override
  Future<SendReceiveOrder> createSendReceiveOrder({
    required String lockerId,
    required String sizeId,
    required String durationId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final size = _lockerSizes.firstWhere((s) => s.id == sizeId);
    final duration = _storageDurations.firstWhere((d) => d.id == durationId);

    return SendReceiveOrderModel(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      lockerId: lockerId,
      lockerCode: 'Locker A-102',
      location: 'Khu vực Q1, TP.HCM',
      size: size,
      duration: duration,
      estimatedFee: size.price,
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<SendReceiveOrder> getOrderById(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));

    return SendReceiveOrderModel(
      id: orderId,
      lockerId: 'locker-001',
      lockerCode: 'Locker A-102',
      location: 'Khu vực Q1, TP.HCM',
      size: _lockerSizes.first,
      duration: _storageDurations[1],
      estimatedFee: _lockerSizes.first.price,
      status: 'active',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> confirmOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

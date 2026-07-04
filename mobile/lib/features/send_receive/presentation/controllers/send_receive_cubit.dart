import 'package:flutter_bloc/flutter_bloc.dart';

// Giả định các đường dẫn này là chính xác cho User repository và entity
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/i_user_repository.dart';
import '../../../locker/domain/entities/locker.dart';
import '../../../locker/domain/usecases/get_available_lockers_usecase.dart';
import '../../domain/entities/send_receive_order.dart';
import '../../domain/entities/locker_size.dart';
import '../../domain/entities/storage_duration.dart';
import '../../domain/usecases/create_send_receive_order_usecase.dart';
import '../../domain/usecases/get_available_locker_sizes_usecase.dart';
import '../../domain/usecases/get_storage_durations_usecase.dart';
import 'send_receive_state.dart';

class SendReceiveCubit extends Cubit<SendReceiveState> {
  final GetAvailableLockerSizesUseCase _getLockerSizes;
  final GetStorageDurationsUseCase _getStorageDurations;
  final GetAvailableLockersUseCase _getLockers;
  final CreateSendReceiveOrderUseCase _createOrder;
  final IUserRepository
  _userRepository; // Dependency để lấy thông tin người dùng

  SendReceiveCubit({
    required GetAvailableLockerSizesUseCase getLockerSizes,
    required GetStorageDurationsUseCase getStorageDurations,
    required GetAvailableLockersUseCase getLockers,
    required CreateSendReceiveOrderUseCase createOrder,
    required IUserRepository userRepository,
  }) : _getLockerSizes = getLockerSizes,
       _getStorageDurations = getStorageDurations,
       _getLockers = getLockers,
       _createOrder = createOrder,
       _userRepository = userRepository,
       super(SendReceiveState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true));
    try {
      // Tải song song để tăng tốc độ
      final results = await Future.wait([
        _getLockerSizes(),
        _getStorageDurations(),
        _getLockers(),
      ]);

      final sizes = results[0] as List<LockerSize>;
      final durations = results[1] as List<StorageDuration>;
      final lockers = results[2] as List<Locker>;

      emit(
        state.copyWith(
          isLoading: false,
          lockerSizes: sizes,
          storageDurations: durations,
          lockers: lockers,
          // Mặc định chọn size đầu tiên và thời gian thứ hai
          selectedSizeId: sizes.isNotEmpty ? sizes.first.id : null,
          selectedDurationId: durations.isNotEmpty ? durations[1].id : null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể tải dữ liệu cần thiết. Vui lòng thử lại.',
        ),
      );
    }
  }

  void selectSize(String sizeId) {
    // Khi người dùng thay đổi kích thước, cần reset lại lựa chọn ngăn tủ
    // vì danh sách các ngăn tủ hợp lệ sẽ thay đổi.
    emit(state.copyWith(selectedSizeId: sizeId, clearSelectedSlot: true));
  }

  void selectDuration(String durationId) {
    emit(state.copyWith(selectedDurationId: durationId));
  }

  void selectLocker(String lockerId) {
    emit(state.copyWith(selectedLockerId: lockerId, clearSelectedSlot: true));
  }

  void selectSlot(int? slotIndex) {
    emit(state.copyWith(selectedSlotIndex: slotIndex));
  }

  Future<void> createOrder() async {
    final selectedLockerId = state.selectedLockerId;
    final selectedSlotIndex = state.selectedSlotIndex;
    final selectedSizeId = state.selectedSizeId;
    final selectedDurationId = state.selectedDurationId;

    if (!state.canProceed) {
      emit(
        state.copyWith(
          errorMessage: 'Vui lòng chọn trạm tủ, kích thước và thời gian gửi',
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true));
    try {
      // Giả định StorageDuration entity có thuộc tính `hours`
      final duration = state.storageDurations.firstWhere(
        (d) => d.id == selectedDurationId,
      );
      final durationHours = duration.durationHours;

      // Lấy số điện thoại của người dùng hiện tại
      final User currentUser = await _userRepository.getCurrentUser();
      final String mobileNumber = currentUser.phoneNumber;

      final reservationData = await _createOrder(
        lockerId: selectedLockerId!,
        slotIndex: selectedSlotIndex!,
        packageId: selectedSizeId!,
        durationHours: durationHours,
        mobileNumber: mobileNumber,
        // Backend có thể có validation không cho phép thời gian trong quá khứ.
        // DateTime.now() có thể trở thành quá khứ do độ trễ mạng.
        // Thêm một khoảng đệm nhỏ để đảm bảo thời gian luôn hợp lệ.
        checkInTime: DateTime.now().add(const Duration(seconds: 10)),
        notes: 'Gửi hàng qua App',
      );

      // Construct the full order object for the UI using the reservation result
      // and the data already in the state.
      final totalAmount = (reservationData['totalAmount'] as num).toInt();
      final finalOrder = SendReceiveOrder(
        id: reservationData['orderId'] as String,
        lockerId: selectedLockerId,
        lockerCode: 'Ngăn ${state.selectedSlotIndex}',
        location: state.selectedLocker!.location,
        size: state.selectedSize!,
        duration: duration,
        estimatedFee: totalAmount,
        status:
            'pending_payment', // The API returns a status code, can be mapped here.
        createdAt: DateTime.parse(reservationData['checkInTime'] as String),
      );

      emit(state.copyWith(isLoading: false, currentOrder: finalOrder));
    } catch (e) {
      // Hiển thị lỗi cụ thể hơn từ exception, thay vì chỉ là một chuỗi chung chung.
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không thể tạo đơn hàng: $e',
        ),
      );
    }
  }

  void clearError() {
    emit(state.copyWith(clearErrorMessage: true));
  }
}

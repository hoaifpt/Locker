import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/photo_confirmation_repository.dart';
import '../../domain/usecases/get_photo_confirmation_data_usecase.dart';
import '../../../send_success/domain/entities/send_success_info.dart';
import 'photo_confirmation_state.dart';

class PhotoConfirmationCubit extends Cubit<PhotoConfirmationState> {
  final GetPhotoConfirmationDataUsecase _getData;

  PhotoConfirmationCubit({GetPhotoConfirmationDataUsecase? getData})
      : _getData = getData ??
            GetPhotoConfirmationDataUsecase(PhotoConfirmationRepository()),
        super(PhotoConfirmationState.initial());

  Future<void> load(String? lockerId) async {
    emit(
        state.copyWith(isLoading: true, clearError: true, clearFeedback: true));

    try {
      final data = await _getData(lockerId);
      emit(state.copyWith(isLoading: false, data: data));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Khong tai duoc du lieu chup anh xac nhan',
        ),
      );
    }
  }

  void toggleFlash() {
    emit(state.copyWith(flashOn: !state.flashOn));
  }

  void retake() {
    emit(state.copyWith(
      feedbackMessage: 'San sang chup lai',
      clearError: true,
    ));
  }

  void capture() {
    // when capture succeeds, prepare a SendSuccessRequest and signal navigation
    final lockerHub = state.data?.lockerId;
    final sendReq = SendSuccessRequest(
      lockerHub: lockerHub,
      pin: '882109',
      orderCode: lockerHub != null ? 'EBOX-$lockerHub' : null,
      amount: null,
    );

    emit(state.copyWith(
      feedbackMessage: 'Da chup anh xac nhan',
      clearError: true,
      navigateToSendSuccess: sendReq,
    ));
  }

  void clearFeedback() {
    emit(state.copyWith(clearFeedback: true));
  }

  void clearNavigation() {
    emit(state.copyWith(clearNavigation: true));
  }
}

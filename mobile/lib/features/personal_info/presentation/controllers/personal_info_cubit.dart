import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/personal_info_overview.dart';
import '../../domain/repositories/i_personal_info_repository.dart';
import '../../domain/usecases/get_personal_info_overview_usecase.dart';
import 'personal_info_state.dart';

class PersonalInfoCubit extends Cubit<PersonalInfoState> {
  final GetPersonalInfoOverviewUseCase _getOverview;
  final IPersonalInfoRepository _repository;

  PersonalInfoCubit({
    required GetPersonalInfoOverviewUseCase getOverview,
    required IPersonalInfoRepository repository,
  }) : _getOverview = getOverview,
       _repository = repository,
       super(PersonalInfoState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final overview = await _getOverview();
      emit(state.copyWith(isLoading: false, overview: overview));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Không tải được thông tin cá nhân: $e',
        ),
      );
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    emit(state.copyWith(isUpdating: true, clearError: true));
    try {
      await _repository.updateProfile(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );
      await load(); // Tải lại dữ liệu sau khi cập nhật thành công
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: 'Cập nhật thất bại: $e',
        ),
      );
    }
  }
}

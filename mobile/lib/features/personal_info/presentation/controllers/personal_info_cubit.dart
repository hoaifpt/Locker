import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_personal_info_overview_usecase.dart';
import 'personal_info_state.dart';

class PersonalInfoCubit extends Cubit<PersonalInfoState> {
  final GetPersonalInfoOverviewUseCase _getOverview;

  PersonalInfoCubit({required GetPersonalInfoOverviewUseCase getOverview})
      : _getOverview = getOverview,
        super(PersonalInfoState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final overview = await _getOverview();
      emit(state.copyWith(isLoading: false, overview: overview));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không tải được thông tin cá nhân: $e',
      ));
    }
  }
}
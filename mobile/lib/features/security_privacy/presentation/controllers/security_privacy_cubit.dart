import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_security_privacy_overview_usecase.dart';
import 'security_privacy_state.dart';

class SecurityPrivacyCubit extends Cubit<SecurityPrivacyState> {
  final GetSecurityPrivacyOverviewUseCase _getOverview;

  SecurityPrivacyCubit({required GetSecurityPrivacyOverviewUseCase getOverview})
      : _getOverview = getOverview,
        super(SecurityPrivacyState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final overview = await _getOverview();
      emit(state.copyWith(isLoading: false, overview: overview));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Không tải được trang bảo mật: $e',
      ));
    }
  }
}

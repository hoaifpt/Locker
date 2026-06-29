import '../../domain/entities/personal_info_overview.dart';

class PersonalInfoState {
  final bool isLoading;
  final bool isUpdating;
  final PersonalInfoOverview? overview;
  final String? errorMessage;

  const PersonalInfoState({
    required this.isLoading,
    this.isUpdating = false,
    this.overview,
    this.errorMessage,
  });

  factory PersonalInfoState.initial() =>
      const PersonalInfoState(isLoading: true);

  PersonalInfoState copyWith({
    bool? isLoading,
    bool? isUpdating,
    PersonalInfoOverview? overview,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PersonalInfoState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      overview: overview ?? this.overview,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

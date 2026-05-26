import '../../domain/entities/personal_info_overview.dart';

class PersonalInfoState {
  final bool isLoading;
  final PersonalInfoOverview? overview;
  final String? errorMessage;

  const PersonalInfoState({
    required this.isLoading,
    this.overview,
    this.errorMessage,
  });

  factory PersonalInfoState.initial() => const PersonalInfoState(isLoading: true);

  PersonalInfoState copyWith({
    bool? isLoading,
    PersonalInfoOverview? overview,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PersonalInfoState(
      isLoading: isLoading ?? this.isLoading,
      overview: overview ?? this.overview,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
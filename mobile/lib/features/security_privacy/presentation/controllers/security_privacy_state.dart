import '../../domain/entities/security_privacy_overview.dart';

class SecurityPrivacyState {
  final bool isLoading;
  final SecurityPrivacyOverview? overview;
  final String? errorMessage;

  const SecurityPrivacyState({
    required this.isLoading,
    this.overview,
    this.errorMessage,
  });

  factory SecurityPrivacyState.initial() =>
      const SecurityPrivacyState(isLoading: true);

  SecurityPrivacyState copyWith({
    bool? isLoading,
    SecurityPrivacyOverview? overview,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SecurityPrivacyState(
      isLoading: isLoading ?? this.isLoading,
      overview: overview ?? this.overview,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

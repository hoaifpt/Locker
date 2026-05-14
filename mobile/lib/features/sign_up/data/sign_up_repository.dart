import '../domain/entities/sign_up_request.dart'
    show SignUpRequest, SignUpResponse;
import '../domain/repositories/i_sign_up_repository.dart';
import 'models/sign_up_model.dart';

class SignUpRepository implements ISignUpRepository {
  @override
  Future<SignUpResponse> signUp(SignUpRequest request) async {
    // TODO: Implement API call
    // For now, mock data
    await Future.delayed(const Duration(seconds: 1));

    return SignUpResponseModel(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: request.email,
      fullName: request.fullName,
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

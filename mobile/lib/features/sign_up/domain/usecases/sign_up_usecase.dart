import '../entities/sign_up_request.dart' show SignUpRequest, SignUpResponse;
import '../repositories/i_sign_up_repository.dart';

class SignUpUseCase {
  final ISignUpRepository repository;

  SignUpUseCase({required this.repository});

  Future<SignUpResponse> call(SignUpRequest request) async {
    return await repository.signUp(request);
  }
}

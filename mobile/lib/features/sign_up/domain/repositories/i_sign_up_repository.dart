import '../entities/sign_up_request.dart' show SignUpRequest, SignUpResponse;

abstract class ISignUpRepository {
  Future<SignUpResponse> signUp(SignUpRequest request);
}

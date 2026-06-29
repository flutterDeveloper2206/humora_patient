import '../../data/models/otp_models.dart';
import '../repositories/auth_repository.dart';

class VerifyTokenUseCase {
  final AuthRepository _repository;

  VerifyTokenUseCase(this._repository);

  Future<VerifyTokenResponse> call(String token) => _repository.verifyToken(token);
}

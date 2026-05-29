import '../repositories/auth_repository.dart';
import '../../data/models/otp_models.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<VerifyOtpResponse> call(VerifyOtpRequest request) =>
      _repository.verifyOtp(request);
}

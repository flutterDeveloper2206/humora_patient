import '../repositories/auth_repository.dart';
import '../../data/models/otp_models.dart';

class SendOtpUseCase {
  final AuthRepository _repository;

  SendOtpUseCase(this._repository);

  Future<SendOtpResponse> call(SendOtpRequest request) =>
      _repository.sendOtp(request);
}

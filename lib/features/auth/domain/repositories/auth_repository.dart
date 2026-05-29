import '../../data/models/otp_models.dart';
import '../../data/models/profile_models.dart';

abstract class AuthRepository {
  Future<SendOtpResponse> sendOtp(SendOtpRequest request);
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request);
  Future<SaveProfileResponse> saveProfile(
    SaveProfileRequest request,
    String token,
    String patientId,
  );
}

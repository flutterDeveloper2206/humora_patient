import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_api_service.dart';
import '../models/otp_models.dart';
import '../models/profile_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;

  AuthRepositoryImpl({AuthApiService? apiService})
      : _apiService = apiService ?? AuthApiService();

  @override
  Future<SendOtpResponse> sendOtp(SendOtpRequest request) =>
      _apiService.sendOtp(request);

  @override
  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) =>
      _apiService.verifyOtp(request);

  @override
  Future<VerifyTokenResponse> verifyToken(String token) =>
      _apiService.verifyToken(token);

  @override
  Future<SaveProfileResponse> saveProfile(
    SaveProfileRequest request,
    String token,
    String patientId,
  ) =>
      _apiService.saveProfile(request, token, patientId);
}

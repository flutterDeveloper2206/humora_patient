import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/auth_api_service.dart';
import '../data/models/otp_models.dart';
import '../data/models/profile_models.dart';
import '../../../core/utils/session_manager.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiService _apiService = AuthApiService();

  AuthBloc() : super(AuthInitial()) {
    on<SendOtpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _apiService.sendOtp(
          SendOtpRequest(mobile: event.mobile, countryCode: event.countryCode),
        );
        emit(OtpSentSuccess(response.message));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<VerifyOtpRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await _apiService.verifyOtp(
          VerifyOtpRequest(
            mobile: event.mobile,
            countryCode: event.countryCode,
            code: event.code,
            timeZone: 'Asia/Kolkata',
          ),
        );
        if (response.token.isNotEmpty) {
          await SessionManager.saveToken(response.token);
        }
        if (response.patientId.isNotEmpty) {
          await SessionManager.savePatientId(response.patientId);
        }
        if (response.currencyId.isNotEmpty) {
          await SessionManager.saveCurrencyId(response.currencyId);
        }
        emit(OtpVerificationSuccess(response.onboardingStep));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await Future.delayed(const Duration(seconds: 2));
        if (event.phoneNumber.length >= 10) {
          emit(const AuthAuthenticated("user_123"));
        } else {
          emit(const AuthError("Invalid phone number"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<EmailLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await Future.delayed(const Duration(seconds: 2));
        if (event.email.contains('@')) {
          await SessionManager.saveToken("mock_email_token");
          await SessionManager.savePatientId("email_user_123");
          emit(const AuthAuthenticated("email_user_123"));
        } else {
          emit(const AuthError("Invalid email address"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<GoogleLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await Future.delayed(const Duration(seconds: 1));
        await SessionManager.saveToken("mock_google_token");
        await SessionManager.savePatientId("google_user_123");
        emit(const AuthAuthenticated("google_user_123"));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AppleLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await Future.delayed(const Duration(seconds: 1));
        await SessionManager.saveToken("mock_apple_token");
        await SessionManager.savePatientId("apple_user_123");
        emit(const AuthAuthenticated("apple_user_123"));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<EmailSignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await Future.delayed(const Duration(seconds: 2));
        if (event.email.contains('@') && event.password.length >= 6) {
          await SessionManager.saveToken("mock_signup_token");
          await SessionManager.savePatientId("signup_user_123");
          emit(const AuthAuthenticated("signup_user_123"));
        } else {
          emit(const AuthError("Invalid email or password (min 6 chars)"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<FinishSignupRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await SessionManager.getToken();
        final patientId = await SessionManager.getPatientId();

        if (token == null ||
            token.isEmpty ||
            patientId == null ||
            patientId.isEmpty) {
          emit(const AuthError("Missing session data. Please login again."));
          return;
        }

        final request = SaveProfileRequest(
          firstName: event.firstName,
          lastName: event.lastName,
          email: event.email,
          gender: event.gender,
          birthDate: event.birthDate,
        );

        final response = await _apiService.saveProfile(
          request,
          token,
          patientId,
        );
        emit(AuthAuthenticated(patientId, message: response.message));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await SessionManager.clearSession();
      emit(AuthUnauthenticated());
    });

    on<ResetPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await Future.delayed(const Duration(seconds: 1));
        if (event.email.contains('@')) {
          emit(ResetPasswordLinkSent(event.email));
        } else {
          emit(const AuthError("Invalid email address"));
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<ResetPasswordLinkClosed>((event, emit) {
      emit(AuthInitial());
    });
  }
}

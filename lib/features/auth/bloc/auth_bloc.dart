import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
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
        emit(const AuthAuthenticated("google_user_123"));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AppleLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await Future.delayed(const Duration(seconds: 1));
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
        await Future.delayed(const Duration(seconds: 2));
        // In a real app, you would use event.firstName, event.lastName, etc.
        emit(const AuthAuthenticated("finished_user_123"));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) {
      emit(AuthUnauthenticated());
    });
  }
}

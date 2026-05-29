import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class OtpSentSuccess extends AuthState {
  final String message;
  const OtpSentSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpVerificationSuccess extends AuthState {
  final int onboardingStep;
  const OtpVerificationSuccess(this.onboardingStep);

  @override
  List<Object?> get props => [onboardingStep];
}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String userId;
  final String? message;
  const AuthAuthenticated(this.userId, {this.message});

  @override
  List<Object?> get props => [userId, message];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class ResetPasswordLinkSent extends AuthState {
  final String email;
  const ResetPasswordLinkSent(this.email);

  @override
  List<Object?> get props => [email];
}

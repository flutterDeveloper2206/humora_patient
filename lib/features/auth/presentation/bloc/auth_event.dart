import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String phoneNumber;
  const LoginRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class SendOtpRequested extends AuthEvent {
  final String mobile;
  final String countryCode;

  const SendOtpRequested({required this.mobile, required this.countryCode});

  @override
  List<Object> get props => [mobile, countryCode];
}

class VerifyOtpRequested extends AuthEvent {
  final String mobile;
  final String countryCode;
  final String code;

  const VerifyOtpRequested({
    required this.mobile,
    required this.countryCode,
    required this.code,
  });

  @override
  List<Object> get props => [mobile, countryCode, code];
}

class EmailLoginRequested extends AuthEvent {
  final String email;
  const EmailLoginRequested(this.email);

  @override
  List<Object> get props => [email];
}

class GoogleLoginRequested extends AuthEvent {}

class AppleLoginRequested extends AuthEvent {}

class EmailSignupRequested extends AuthEvent {
  final String email;
  final String password;
  const EmailSignupRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class FinishSignupRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final int gender;
  final String birthDate;
  final String? timeZone;

  const FinishSignupRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.birthDate,
    this.timeZone,
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    email,
    gender,
    birthDate,
    timeZone ?? '',
  ];
}

class LogoutRequested extends AuthEvent {}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  const ResetPasswordRequested(this.email);

  @override
  List<Object> get props => [email];
}

class ResetPasswordLinkClosed extends AuthEvent {}

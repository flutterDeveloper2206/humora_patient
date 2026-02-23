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
  final String gender;

  final String? country;
  final String? birthDate;
  final String? timeZone;

  const FinishSignupRequested({
    required this.firstName,
    required this.lastName,
    required this.gender,

    this.country,
    this.birthDate,
    this.timeZone,
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    gender,

    country ?? '',
    birthDate ?? '',
    timeZone ?? '',
  ];
}

class LogoutRequested extends AuthEvent {}

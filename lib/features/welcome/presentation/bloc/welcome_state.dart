import 'package:equatable/equatable.dart';

class WelcomeState extends Equatable {
  const WelcomeState();

  @override
  List<Object> get props => [];
}

class WelcomeInitial extends WelcomeState {}

class WelcomeNavigateToLogin extends WelcomeState {}

class WelcomeNavigateToSignup extends WelcomeState {}

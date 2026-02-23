import 'package:equatable/equatable.dart';

abstract class WelcomeEvent extends Equatable {
  const WelcomeEvent();

  @override
  List<Object> get props => [];
}

class WelcomeGetStartedTapped extends WelcomeEvent {}

class WelcomeSignInTapped extends WelcomeEvent {}

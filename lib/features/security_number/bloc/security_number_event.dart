import 'package:equatable/equatable.dart';

abstract class SecurityNumberEvent extends Equatable {
  const SecurityNumberEvent();

  @override
  List<Object?> get props => [];
}

class UpdateSSN extends SecurityNumberEvent {
  final String ssn;
  const UpdateSSN(this.ssn);

  @override
  List<Object?> get props => [ssn];
}

class SubmitSSN extends SecurityNumberEvent {}

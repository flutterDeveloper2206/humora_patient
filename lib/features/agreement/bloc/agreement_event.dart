import 'package:equatable/equatable.dart';

class AgreementEvent extends Equatable {
  const AgreementEvent();
  @override
  List<Object?> get props => [];
}

class ToggleTerms extends AgreementEvent {}

class ToggleEthics extends AgreementEvent {}

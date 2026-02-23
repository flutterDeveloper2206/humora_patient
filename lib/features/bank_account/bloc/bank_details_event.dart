import 'package:equatable/equatable.dart';

abstract class BankDetailsEvent extends Equatable {
  const BankDetailsEvent();

  @override
  List<Object?> get props => [];
}

class UpdateAccountHolderName extends BankDetailsEvent {
  final String name;
  const UpdateAccountHolderName(this.name);
  @override
  List<Object?> get props => [name];
}

class UpdateAccountNumber extends BankDetailsEvent {
  final String number;
  const UpdateAccountNumber(this.number);
  @override
  List<Object?> get props => [number];
}

class UpdateIFSCCode extends BankDetailsEvent {
  final String code;
  const UpdateIFSCCode(this.code);
  @override
  List<Object?> get props => [code];
}

class UpdateUPI extends BankDetailsEvent {
  final String upi;
  const UpdateUPI(this.upi);
  @override
  List<Object?> get props => [upi];
}

class UpdatePANNumber extends BankDetailsEvent {
  final String pan;
  const UpdatePANNumber(this.pan);
  @override
  List<Object?> get props => [pan];
}

class UpdateGSTNumber extends BankDetailsEvent {
  final String gst;
  const UpdateGSTNumber(this.gst);
  @override
  List<Object?> get props => [gst];
}

class SubmitBankDetails extends BankDetailsEvent {}

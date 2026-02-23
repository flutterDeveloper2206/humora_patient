import 'package:equatable/equatable.dart';

class AgreementState extends Equatable {
  final bool termsAccepted;
  final bool ethicsAccepted;

  const AgreementState({
    this.termsAccepted = false,
    this.ethicsAccepted = false,
  });

  AgreementState copyWith({bool? termsAccepted, bool? ethicsAccepted}) {
    return AgreementState(
      termsAccepted: termsAccepted ?? this.termsAccepted,
      ethicsAccepted: ethicsAccepted ?? this.ethicsAccepted,
    );
  }

  @override
  List<Object?> get props => [termsAccepted, ethicsAccepted];
}

import 'package:equatable/equatable.dart';

abstract class CertificationsEvent extends Equatable {
  const CertificationsEvent();

  @override
  List<Object?> get props => [];
}

class PickCertFile extends CertificationsEvent {}

class RemoveCertFile extends CertificationsEvent {}

class SubmitCertifications extends CertificationsEvent {}

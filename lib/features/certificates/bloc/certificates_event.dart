import 'package:equatable/equatable.dart';
import '../models/certificate_model.dart';

abstract class CertificatesEvent extends Equatable {
  const CertificatesEvent();
  @override
  List<Object?> get props => [];
}

class LoadCertificates extends CertificatesEvent {}

class ToggleCertificateSelection extends CertificatesEvent {
  final CertificateModel certificate;
  const ToggleCertificateSelection(this.certificate);
  @override
  List<Object?> get props => [certificate];
}

class SearchCertificates extends CertificatesEvent {
  final String query;
  const SearchCertificates(this.query);
  @override
  List<Object?> get props => [query];
}

class PickCertificateFile extends CertificatesEvent {}

class RemovePickedFile extends CertificatesEvent {}

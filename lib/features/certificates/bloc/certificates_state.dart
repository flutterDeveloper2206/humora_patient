import 'package:equatable/equatable.dart';
import '../models/certificate_model.dart';

abstract class CertificatesState extends Equatable {
  const CertificatesState();
  @override
  List<Object?> get props => [];
}

class CertificatesInitial extends CertificatesState {}

class CertificatesLoading extends CertificatesState {}

class CertificatesLoaded extends CertificatesState {
  final List<CertificateModel> allCertificates;
  final List<CertificateModel> filteredCertificates;
  final List<CertificateModel> selectedCertificates;
  final String searchQuery;
  final String? pickedFileName;
  final String? pickedFileSize;

  const CertificatesLoaded({
    required this.allCertificates,
    required this.filteredCertificates,
    required this.selectedCertificates,
    this.searchQuery = "",
    this.pickedFileName,
    this.pickedFileSize,
  });

  CertificatesLoaded copyWith({
    List<CertificateModel>? allCertificates,
    List<CertificateModel>? filteredCertificates,
    List<CertificateModel>? selectedCertificates,
    String? searchQuery,
    String? pickedFileName,
    String? pickedFileSize,
  }) {
    return CertificatesLoaded(
      allCertificates: allCertificates ?? this.allCertificates,
      filteredCertificates: filteredCertificates ?? this.filteredCertificates,
      selectedCertificates: selectedCertificates ?? this.selectedCertificates,
      searchQuery: searchQuery ?? this.searchQuery,
      pickedFileName: pickedFileName ?? this.pickedFileName,
      pickedFileSize: pickedFileSize ?? this.pickedFileSize,
    );
  }

  @override
  List<Object?> get props => [
    allCertificates,
    filteredCertificates,
    selectedCertificates,
    searchQuery,
    pickedFileName,
    pickedFileSize,
  ];
}

class CertificatesError extends CertificatesState {
  final String message;
  const CertificatesError(this.message);
  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

enum CertificationsStatus { initial, loading, success, error }

class CertificationsState extends Equatable {
  final String? fileName;
  final String? fileSize;
  final CertificationsStatus status;
  final String? errorMessage;

  const CertificationsState({
    this.fileName,
    this.fileSize,
    this.status = CertificationsStatus.initial,
    this.errorMessage,
  });

  bool get isFileUploaded => fileName != null;

  CertificationsState copyWith({
    String? fileName,
    String? fileSize,
    CertificationsStatus? status,
    String? errorMessage,
  }) {
    return CertificationsState(
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper to clear file
  CertificationsState clearFile() {
    return CertificationsState(status: status, errorMessage: errorMessage);
  }

  @override
  List<Object?> get props => [fileName, fileSize, status, errorMessage];
}

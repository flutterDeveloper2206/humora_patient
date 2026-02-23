import 'package:equatable/equatable.dart';

class DocumentationState extends Equatable {
  final bool selfDeclaration;
  final String? govIdFileName;
  final String? addressProofFileName;
  final bool isLoading;

  const DocumentationState({
    this.selfDeclaration = false,
    this.govIdFileName,
    this.addressProofFileName,
    this.isLoading = false,
  });

  DocumentationState copyWith({
    bool? selfDeclaration,
    String? govIdFileName,
    String? addressProofFileName,
    bool? isLoading,
    bool clearGovId = false,
    bool clearAddress = false,
  }) {
    return DocumentationState(
      selfDeclaration: selfDeclaration ?? this.selfDeclaration,
      govIdFileName: clearGovId ? null : (govIdFileName ?? this.govIdFileName),
      addressProofFileName: clearAddress
          ? null
          : (addressProofFileName ?? this.addressProofFileName),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    selfDeclaration,
    govIdFileName,
    addressProofFileName,
    isLoading,
  ];
}

import 'package:equatable/equatable.dart';

enum BankDetailsStatus { initial, loading, success, error }

class BankDetailsState extends Equatable {
  final String accountHolderName;
  final String accountNumber;
  final String ifscCode;
  final String upi;
  final String panNumber;
  final String gstNumber;
  final BankDetailsStatus status;
  final String? errorMessage;

  const BankDetailsState({
    this.accountHolderName = '',
    this.accountNumber = '',
    this.ifscCode = '',
    this.upi = '',
    this.panNumber = '',
    this.gstNumber = '',
    this.status = BankDetailsStatus.initial,
    this.errorMessage,
  });

  bool get isValid =>
      accountHolderName.isNotEmpty &&
      accountNumber.isNotEmpty &&
      ifscCode.isNotEmpty &&
      panNumber.isNotEmpty;

  BankDetailsState copyWith({
    String? accountHolderName,
    String? accountNumber,
    String? ifscCode,
    String? upi,
    String? panNumber,
    String? gstNumber,
    BankDetailsStatus? status,
    String? errorMessage,
  }) {
    return BankDetailsState(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      upi: upi ?? this.upi,
      panNumber: panNumber ?? this.panNumber,
      gstNumber: gstNumber ?? this.gstNumber,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    accountHolderName,
    accountNumber,
    ifscCode,
    upi,
    panNumber,
    gstNumber,
    status,
    errorMessage,
  ];
}

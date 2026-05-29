import 'package:equatable/equatable.dart';

enum SecurityNumberStatus { initial, loading, success, error }

class SecurityNumberState extends Equatable {
  final String ssn;
  final SecurityNumberStatus status;
  final String? errorMessage;

  const SecurityNumberState({
    this.ssn = '',
    this.status = SecurityNumberStatus.initial,
    this.errorMessage,
  });

  bool get isValid => ssn.length == 9;

  SecurityNumberState copyWith({
    String? ssn,
    SecurityNumberStatus? status,
    String? errorMessage,
  }) {
    return SecurityNumberState(
      ssn: ssn ?? this.ssn,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [ssn, status, errorMessage];
}

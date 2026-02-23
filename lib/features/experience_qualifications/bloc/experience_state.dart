import 'package:equatable/equatable.dart';

enum ExperienceStatus { initial, loading, success, error }

class ExperienceState extends Equatable {
  final String practiceMethod;
  final ExperienceStatus status;
  final String? errorMessage;

  const ExperienceState({
    this.practiceMethod = '',
    this.status = ExperienceStatus.initial,
    this.errorMessage,
  });

  bool get isValid => practiceMethod.trim().isNotEmpty;

  ExperienceState copyWith({
    String? practiceMethod,
    ExperienceStatus? status,
    String? errorMessage,
  }) {
    return ExperienceState(
      practiceMethod: practiceMethod ?? this.practiceMethod,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [practiceMethod, status, errorMessage];
}

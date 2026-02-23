import 'package:equatable/equatable.dart';
import '../models/expertise_model.dart';

abstract class ExpertiseSelectionState extends Equatable {
  const ExpertiseSelectionState();

  @override
  List<Object?> get props => [];
}

class ExpertiseInitial extends ExpertiseSelectionState {}

class ExpertiseLoading extends ExpertiseSelectionState {}

class ExpertiseLoaded extends ExpertiseSelectionState {
  final List<ExpertiseModel> options;
  final int? selectedId;

  const ExpertiseLoaded({required this.options, this.selectedId});

  ExpertiseLoaded copyWith({List<ExpertiseModel>? options, int? selectedId}) {
    return ExpertiseLoaded(
      options: options ?? this.options,
      selectedId: selectedId ?? this.selectedId,
    );
  }

  @override
  List<Object?> get props => [options, selectedId];
}

class ExpertiseError extends ExpertiseSelectionState {
  final String message;

  const ExpertiseError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import '../models/specialization_model.dart';

abstract class SpecializationState extends Equatable {
  const SpecializationState();

  @override
  List<Object?> get props => [];
}

class SpecializationInitial extends SpecializationState {}

class SpecializationLoading extends SpecializationState {}

class SpecializationLoaded extends SpecializationState {
  final List<SpecializationModel> options;
  final Set<int> selectedIds;

  const SpecializationLoaded({
    required this.options,
    required this.selectedIds,
  });

  SpecializationLoaded copyWith({
    List<SpecializationModel>? options,
    Set<int>? selectedIds,
  }) {
    return SpecializationLoaded(
      options: options ?? this.options,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  @override
  List<Object?> get props => [options, selectedIds];
}

class SpecializationError extends SpecializationState {
  final String message;

  const SpecializationError(this.message);

  @override
  List<Object?> get props => [message];
}

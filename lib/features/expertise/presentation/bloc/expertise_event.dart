import 'package:equatable/equatable.dart';

abstract class ExpertiseSelectionEvent extends Equatable {
  const ExpertiseSelectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpertiseOptions extends ExpertiseSelectionEvent {}

class SelectExpertise extends ExpertiseSelectionEvent {
  final int expertiseId;

  const SelectExpertise(this.expertiseId);

  @override
  List<Object?> get props => [expertiseId];
}

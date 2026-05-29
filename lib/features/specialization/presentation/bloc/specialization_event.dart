import 'package:equatable/equatable.dart';

abstract class SpecializationEvent extends Equatable {
  const SpecializationEvent();

  @override
  List<Object?> get props => [];
}

class LoadSpecializations extends SpecializationEvent {}

class ToggleSpecialization extends SpecializationEvent {
  final int id;

  const ToggleSpecialization(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearAllSpecializations extends SpecializationEvent {}

import 'package:equatable/equatable.dart';

abstract class HealingFocusEvent extends Equatable {
  const HealingFocusEvent();

  @override
  List<Object?> get props => [];
}

class LoadHealingFocusData extends HealingFocusEvent {}

class ToggleCategorySelection extends HealingFocusEvent {
  final String categoryId;
  const ToggleCategorySelection(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ToggleSpecializationSelection extends HealingFocusEvent {
  final String specializationId;
  const ToggleSpecializationSelection(this.specializationId);

  @override
  List<Object?> get props => [specializationId];
}

class SaveHealingFocus extends HealingFocusEvent {}

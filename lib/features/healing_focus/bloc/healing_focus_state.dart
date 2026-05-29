import 'package:equatable/equatable.dart';
import '../data/models/healing_focus_models.dart';

abstract class HealingFocusState extends Equatable {
  const HealingFocusState();

  @override
  List<Object?> get props => [];
}

class HealingFocusInitial extends HealingFocusState {}

class HealingFocusLoading extends HealingFocusState {}

class HealingFocusLoaded extends HealingFocusState {
  final List<HealingCategory> categories;
  final List<HealingSpecialization> specializations;
  final Set<String> selectedCategoryIds;
  final Set<String> selectedSpecializationIds;
  final bool isSaving;

  const HealingFocusLoaded({
    required this.categories,
    required this.specializations,
    required this.selectedCategoryIds,
    required this.selectedSpecializationIds,
    this.isSaving = false,
  });

  HealingFocusLoaded copyWith({
    List<HealingCategory>? categories,
    List<HealingSpecialization>? specializations,
    Set<String>? selectedCategoryIds,
    Set<String>? selectedSpecializationIds,
    bool? isSaving,
  }) {
    return HealingFocusLoaded(
      categories: categories ?? this.categories,
      specializations: specializations ?? this.specializations,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      selectedSpecializationIds: selectedSpecializationIds ?? this.selectedSpecializationIds,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        specializations,
        selectedCategoryIds,
        selectedSpecializationIds,
        isSaving,
      ];
}


class HealingFocusSaved extends HealingFocusState {
  final String message;
  const HealingFocusSaved(this.message);

  @override
  List<Object?> get props => [message];
}

class HealingFocusError extends HealingFocusState {
  final String message;
  const HealingFocusError(this.message);

  @override
  List<Object?> get props => [message];
}

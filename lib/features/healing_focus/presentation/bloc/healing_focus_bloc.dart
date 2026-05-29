import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/core/utils/session_manager.dart';
import 'package:humora_patient/features/healing_focus/data/models/healing_focus_models.dart';
import 'package:humora_patient/features/healing_focus/data/repositories/healing_focus_repository_impl.dart';
import 'package:humora_patient/features/healing_focus/domain/repositories/healing_focus_repository.dart';
import 'package:humora_patient/features/healing_focus/domain/usecases/load_healing_focus_usecase.dart';
import 'package:humora_patient/features/healing_focus/domain/usecases/save_healing_focus_usecase.dart';

import 'healing_focus_event.dart';
import 'healing_focus_state.dart';

class HealingFocusBloc extends Bloc<HealingFocusEvent, HealingFocusState> {
  final LoadHealingFocusUseCase _loadHealingFocus;
  final SaveHealingFocusUseCase _saveHealingFocus;

  HealingFocusBloc({HealingFocusRepository? repository})
      : _loadHealingFocus = LoadHealingFocusUseCase(
          repository ?? HealingFocusRepositoryImpl(),
        ),
        _saveHealingFocus = SaveHealingFocusUseCase(
          repository ?? HealingFocusRepositoryImpl(),
        ),
        super(HealingFocusInitial()) {
    on<LoadHealingFocusData>((event, emit) async {
      emit(HealingFocusLoading());
      try {
        final token = await SessionManager.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('Authentication token not found');
        }

        final response = await _loadHealingFocus(token);
        emit(
          HealingFocusLoaded(
            categories: response.categories,
            specializations: response.specializations,
            selectedCategoryIds: const {},
            selectedSpecializationIds: const {},
          ),
        );
      } catch (e) {
        emit(HealingFocusError(e.toString()));
      }
    });

    on<ToggleCategorySelection>((event, emit) {
      if (state is HealingFocusLoaded) {
        final currentState = state as HealingFocusLoaded;
        final newSelectedCategoryIds = Set<String>.from(currentState.selectedCategoryIds);

        if (newSelectedCategoryIds.contains(event.categoryId)) {
          newSelectedCategoryIds.remove(event.categoryId);
        } else {
          newSelectedCategoryIds.add(event.categoryId);
        }

        emit(currentState.copyWith(selectedCategoryIds: newSelectedCategoryIds));
      }
    });

    on<ToggleSpecializationSelection>((event, emit) {
      if (state is HealingFocusLoaded) {
        final currentState = state as HealingFocusLoaded;
        final newSelectedSpecializationIds = Set<String>.from(currentState.selectedSpecializationIds);

        if (newSelectedSpecializationIds.contains(event.specializationId)) {
          newSelectedSpecializationIds.remove(event.specializationId);
        } else {
          newSelectedSpecializationIds.add(event.specializationId);
        }

        emit(currentState.copyWith(selectedSpecializationIds: newSelectedSpecializationIds));
      }
    });

    on<SaveHealingFocus>((event, emit) async {
      if (state is HealingFocusLoaded) {
        final currentState = state as HealingFocusLoaded;
        final selectedCategoryIds = currentState.selectedCategoryIds.toList();
        final selectedSpecializationIds = currentState.selectedSpecializationIds.toList();
        
        emit(currentState.copyWith(isSaving: true));
        try {
          final token = await SessionManager.getToken();
          final patientId = await SessionManager.getPatientId();

          if (token == null || patientId == null) {
            throw Exception('Authentication data missing');
          }

          final request = SavePreferenceRequest(
            categoryIds: selectedCategoryIds,
            specializationIds: selectedSpecializationIds,
          );

          final response = await _saveHealingFocus(request, token, patientId);
          emit(HealingFocusSaved(response.message));
        } catch (e) {
          emit(HealingFocusError(e.toString()));
          emit(currentState.copyWith(isSaving: false));
        }
      }
    });
  }
}

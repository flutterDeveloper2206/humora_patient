import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/specialization/data/models/specialization_model.dart';
import 'specialization_event.dart';
import 'specialization_state.dart';

class SpecializationBloc
    extends Bloc<SpecializationEvent, SpecializationState> {
  SpecializationBloc() : super(SpecializationInitial()) {
    on<LoadSpecializations>(_onLoadSpecializations);
    on<ToggleSpecialization>(_onToggleSpecialization);
    on<ClearAllSpecializations>(_onClearAllSpecializations);
  }

  void _onLoadSpecializations(
    LoadSpecializations event,
    Emitter<SpecializationState> emit,
  ) {
    emit(SpecializationLoading());
    try {
      final List<Map<String, dynamic>> dummyData = [
        {"id": 1, "value": "Career"},
        {"id": 2, "value": "Love"},
        {"id": 3, "value": "Business"},
        {"id": 4, "value": "Marriage"},
        {"id": 5, "value": "Relationships"},
        {"id": 6, "value": "Health"},
        {"id": 7, "value": "Wealth"},
        {"id": 8, "value": "Education"},
        {"id": 9, "value": "Rituals"},
      ];

      final options = dummyData
          .map((e) => SpecializationModel.fromJson(e))
          .toList();
      emit(
        SpecializationLoaded(
          options: options,
          selectedIds: const {1, 2}, // Mock selection: Career and Love
        ),
      );
    } catch (e) {
      emit(SpecializationError(e.toString()));
    }
  }

  void _onToggleSpecialization(
    ToggleSpecialization event,
    Emitter<SpecializationState> emit,
  ) {
    if (state is SpecializationLoaded) {
      final currentState = state as SpecializationLoaded;
      final updatedSelectedIds = Set<int>.from(currentState.selectedIds);

      if (updatedSelectedIds.contains(event.id)) {
        updatedSelectedIds.remove(event.id);
      } else {
        updatedSelectedIds.add(event.id);
      }

      emit(currentState.copyWith(selectedIds: updatedSelectedIds));
    }
  }

  void _onClearAllSpecializations(
    ClearAllSpecializations event,
    Emitter<SpecializationState> emit,
  ) {
    if (state is SpecializationLoaded) {
      final currentState = state as SpecializationLoaded;
      emit(currentState.copyWith(selectedIds: {}));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/expertise/data/models/expertise_model.dart';
import 'expertise_event.dart';
import 'expertise_state.dart';

class ExpertiseSelectionBloc
    extends Bloc<ExpertiseSelectionEvent, ExpertiseSelectionState> {
  ExpertiseSelectionBloc() : super(ExpertiseInitial()) {
    on<LoadExpertiseOptions>(_onLoadExpertiseOptions);
    on<SelectExpertise>(_onSelectExpertise);
  }

  void _onLoadExpertiseOptions(
    LoadExpertiseOptions event,
    Emitter<ExpertiseSelectionState> emit,
  ) {
    emit(ExpertiseLoading());
    try {
      final List<Map<String, dynamic>> dummyData = [
        {
          "id": 1,
          "image": "assets/images/phs.png",
          "value": "Physical Healing",
        },
        {
          "id": 2,
          "image": "assets/images/emo.png",
          "value": "Emotional Healing",
        },
        {
          "id": 3,
          "image": "assets/images/phys.png",
          "value": "Psychological Healing",
        },
        {
          "id": 4,
          "image": "assets/images/rel.png",
          "value": "Relationship Healing",
        },
        {
          "id": 5,
          "image": "assets/images/pros.png",
          "value": "Prosperity Healing",
        },
        {
          "id": 6,
          "image": "assets/images/spi.png",
          "value": "Spiritual Growth",
        },
      ];

      final options = dummyData.map((e) => ExpertiseModel.fromJson(e)).toList();
      emit(
        ExpertiseLoaded(options: options, selectedId: 1),
      ); // Default selected 1
    } catch (e) {
      emit(ExpertiseError(e.toString()));
    }
  }

  void _onSelectExpertise(
    SelectExpertise event,
    Emitter<ExpertiseSelectionState> emit,
  ) {
    if (state is ExpertiseLoaded) {
      final currentState = state as ExpertiseLoaded;
      emit(currentState.copyWith(selectedId: event.expertiseId));
    }
  }
}

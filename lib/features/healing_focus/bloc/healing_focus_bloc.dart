import 'package:flutter_bloc/flutter_bloc.dart';
import 'healing_focus_event.dart';
import 'healing_focus_state.dart';

class HealingFocusBloc extends Bloc<HealingFocusEvent, HealingFocusState> {
  HealingFocusBloc() : super(const HealingFocusInitial()) {
    on<NextStep>((event, emit) {
      if (state.currentStep < 3) {
        emit(
          HealingFocusStepChange(
            currentStep: state.currentStep + 1,
            selections: state.selections,
          ),
        );
      } else {
        emit(
          HealingFocusCompleted(
            currentStep: state.currentStep,
            selections: state.selections,
          ),
        );
      }
    });

    on<PreviousStep>((event, emit) {
      if (state.currentStep > 1) {
        emit(
          HealingFocusStepChange(
            currentStep: state.currentStep - 1,
            selections: state.selections,
          ),
        );
      }
    });

    on<SelectOption>((event, emit) {
      final newSelections = Map<int, Map<String, String>>.from(
        state.selections,
      );
      final stepSelections = Map<String, String>.from(
        newSelections[event.step] ?? {},
      );
      stepSelections[event.category] = event.value;
      newSelections[event.step] = stepSelections;

      emit(
        HealingFocusStepChange(
          currentStep: state.currentStep,
          selections: newSelections,
        ),
      );
    });
  }
}

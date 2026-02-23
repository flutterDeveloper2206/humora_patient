import 'package:flutter_bloc/flutter_bloc.dart';
import 'experience_event.dart';
import 'experience_state.dart';

class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  ExperienceBloc() : super(const ExperienceState()) {
    on<UpdatePracticeMethod>((event, emit) {
      emit(state.copyWith(practiceMethod: event.method));
    });

    on<SubmitExperience>((event, emit) async {
      if (!state.isValid) return;
      emit(state.copyWith(status: ExperienceStatus.loading));
      try {
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(status: ExperienceStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: ExperienceStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}

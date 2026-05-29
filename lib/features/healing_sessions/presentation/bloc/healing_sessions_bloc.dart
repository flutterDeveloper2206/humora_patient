import 'package:flutter_bloc/flutter_bloc.dart';

part 'healing_sessions_event.dart';
part 'healing_sessions_state.dart';

class HealingSessionsBloc
    extends Bloc<HealingSessionsEvent, HealingSessionsState> {
  HealingSessionsBloc() : super(const HealingSessionsState()) {
    on<ToggleTab>((event, emit) {
      emit(state.copyWith(tab: event.tab));
    });

    on<UpdateMinPrice>((event, emit) {
      emit(state.copyWith(minPrice: event.price));
    });

    on<UpdateFixedTime>((event, emit) {
      emit(state.copyWith(fixedTime: event.time));
    });

    on<UpdateMaxCapacity>((event, emit) {
      emit(state.copyWith(maxCapacity: event.capacity));
    });

    on<UpdateSessionPrice>((event, emit) {
      emit(state.copyWith(sessionPrice: event.price));
    });

    on<UpdateSessionTime>((event, emit) {
      emit(state.copyWith(sessionTime: event.time));
    });

    on<SubmitHealingSessions>((event, emit) async {
      emit(state.copyWith(status: HealingSessionStatus.loading));
      try {
        // Mock API call
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(status: HealingSessionStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: HealingSessionStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}

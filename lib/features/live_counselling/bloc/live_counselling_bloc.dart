import 'package:flutter_bloc/flutter_bloc.dart';
import 'live_counselling_event.dart';
import 'live_counselling_state.dart';

class LiveCounsellingBloc
    extends Bloc<LiveCounsellingEvent, LiveCounsellingState> {
  LiveCounsellingBloc() : super(const LiveCounsellingState()) {
    on<UpdateMinPrice>((event, emit) {
      emit(state.copyWith(minPrice: event.price));
    });

    on<UpdateMaxPrice>((event, emit) {
      emit(state.copyWith(maxPrice: event.price));
    });

    on<UpdateChatPrice>((event, emit) {
      emit(state.copyWith(chatPrice: event.price));
    });

    on<UpdateAudioPrice>((event, emit) {
      emit(state.copyWith(audioPrice: event.price));
    });

    on<UpdateVideoPrice>((event, emit) {
      emit(state.copyWith(videoPrice: event.price));
    });

    on<ToggleFreeCall>((event, emit) {
      emit(state.copyWith(isFreeCallEnabled: !state.isFreeCallEnabled));
    });

    on<SubmitLiveCounselling>((event, emit) async {
      emit(state.copyWith(status: LiveCounsellingStatus.loading));
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(status: LiveCounsellingStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: LiveCounsellingStatus.error,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}

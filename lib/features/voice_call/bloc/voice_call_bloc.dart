import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'voice_call_event.dart';
import 'voice_call_state.dart';

class VoiceCallBloc extends Bloc<VoiceCallEvent, VoiceCallState> {
  Timer? _timer;

  VoiceCallBloc() : super(const VoiceCallState()) {
    on<StartTimer>(_onStartTimer);
    on<UpdateDuration>(_onUpdateDuration);
    on<ToggleMute>(_onToggleMute);
    on<EndCall>(_onEndCall);
  }

  void _onStartTimer(StartTimer event, Emitter<VoiceCallState> emit) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateDuration(Duration(seconds: timer.tick)));
    });
  }

  void _onUpdateDuration(UpdateDuration event, Emitter<VoiceCallState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onToggleMute(ToggleMute event, Emitter<VoiceCallState> emit) {
    emit(state.copyWith(isMuted: !state.isMuted));
  }

  void _onEndCall(EndCall event, Emitter<VoiceCallState> emit) {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

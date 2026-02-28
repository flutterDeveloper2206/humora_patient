import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'video_call_event.dart';
import 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  Timer? _timer;

  VideoCallBloc() : super(const VideoCallState()) {
    on<StartCall>(_onStartCall);
    on<ConnectCall>(_onConnectCall);
    on<UpdateTimer>(_onUpdateTimer);
    on<EndCall>(_onEndCall);
    on<ToggleMute>(_onToggleMute);
    on<ToggleCamera>(_onToggleCamera);
    on<ToggleSpeaker>(_onToggleSpeaker);
  }

  void _onStartCall(StartCall event, Emitter<VideoCallState> emit) {
    // Simulate connection delay
    Future.delayed(const Duration(seconds: 3), () {
      add(ConnectCall());
    });
  }

  void _onConnectCall(ConnectCall event, Emitter<VideoCallState> emit) {
    emit(state.copyWith(status: CallStatus.connected));
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateTimer(Duration(seconds: timer.tick)));
    });
  }

  void _onUpdateTimer(UpdateTimer event, Emitter<VideoCallState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onEndCall(EndCall event, Emitter<VideoCallState> emit) {
    _timer?.cancel();
    emit(state.copyWith(status: CallStatus.ended));
  }

  void _onToggleMute(ToggleMute event, Emitter<VideoCallState> emit) {
    emit(state.copyWith(isMuted: !state.isMuted));
  }

  void _onToggleCamera(ToggleCamera event, Emitter<VideoCallState> emit) {
    emit(state.copyWith(isCameraOff: !state.isCameraOff));
  }

  void _onToggleSpeaker(ToggleSpeaker event, Emitter<VideoCallState> emit) {
    emit(state.copyWith(isSpeakerOn: !state.isSpeakerOn));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

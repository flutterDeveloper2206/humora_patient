import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';

import '../../../agora/presentation/models/call_phase.dart';
import '../../../live_consultation/data/models/live_models.dart';

class VideoCallState extends Equatable {
  final CallPhase phase;
  final Duration duration;
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;
  final String healerName;
  final String healerImage;
  final String? errorMessage;
  final int? remoteUid;
  final RtcEngine? engine;
  final SessionEndedSummary? sessionSummary;

  const VideoCallState({
    this.phase = CallPhase.initial,
    this.duration = Duration.zero,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeakerOn = true,
    this.healerName = 'Healer',
    this.healerImage = 'assets/image/doctorprofile.png',
    this.errorMessage,
    this.remoteUid,
    this.engine,
    this.sessionSummary,
  });

  bool get isConnecting =>
      phase == CallPhase.loadingToken || phase == CallPhase.connecting;

  bool get isInCall => phase == CallPhase.inProgress;

  VideoCallState copyWith({
    CallPhase? phase,
    Duration? duration,
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeakerOn,
    String? healerName,
    String? healerImage,
    String? errorMessage,
    int? remoteUid,
    RtcEngine? engine,
    SessionEndedSummary? sessionSummary,
    bool clearError = false,
  }) {
    return VideoCallState(
      phase: phase ?? this.phase,
      duration: duration ?? this.duration,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      healerName: healerName ?? this.healerName,
      healerImage: healerImage ?? this.healerImage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      remoteUid: remoteUid ?? this.remoteUid,
      engine: engine ?? this.engine,
      sessionSummary: sessionSummary ?? this.sessionSummary,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        duration,
        isMuted,
        isCameraOff,
        isSpeakerOn,
        healerName,
        healerImage,
        errorMessage,
        remoteUid,
        engine,
        sessionSummary,
      ];
}

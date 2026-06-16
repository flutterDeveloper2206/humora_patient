import 'package:equatable/equatable.dart';

import '../../../agora/presentation/models/call_phase.dart';
import '../../../live_consultation/data/models/live_models.dart';

class VoiceCallState extends Equatable {
  final CallPhase phase;
  final Duration duration;
  final bool isMuted;
  final String callerName;
  final String callerImage;
  final String? errorMessage;
  final int? remoteUid;
  final SessionEndedSummary? sessionSummary;

  const VoiceCallState({
    this.phase = CallPhase.initial,
    this.duration = Duration.zero,
    this.isMuted = false,
    this.callerName = 'Healer',
    this.callerImage = 'assets/image/doctorprofile.png',
    this.errorMessage,
    this.remoteUid,
    this.sessionSummary,
  });

  bool get isLoading =>
      phase == CallPhase.loadingToken || phase == CallPhase.connecting;

  VoiceCallState copyWith({
    CallPhase? phase,
    Duration? duration,
    bool? isMuted,
    String? callerName,
    String? callerImage,
    String? errorMessage,
    int? remoteUid,
    SessionEndedSummary? sessionSummary,
    bool clearError = false,
  }) {
    return VoiceCallState(
      phase: phase ?? this.phase,
      duration: duration ?? this.duration,
      isMuted: isMuted ?? this.isMuted,
      callerName: callerName ?? this.callerName,
      callerImage: callerImage ?? this.callerImage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      remoteUid: remoteUid ?? this.remoteUid,
      sessionSummary: sessionSummary ?? this.sessionSummary,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        duration,
        isMuted,
        callerName,
        callerImage,
        errorMessage,
        remoteUid,
        sessionSummary,
      ];
}

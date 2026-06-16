import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';

import '../../../agora/presentation/models/call_phase.dart';

class GroupParticipant extends Equatable {
  final int agoraUid;
  final String name;
  final bool isMuted;
  final bool isMainSpeaker;

  const GroupParticipant({
    required this.agoraUid,
    required this.name,
    this.isMuted = false,
    this.isMainSpeaker = false,
  });

  @override
  List<Object?> get props => [agoraUid, name, isMuted, isMainSpeaker];
}

class GroupSessionState extends Equatable {
  final CallPhase phase;
  final List<GroupParticipant> participants;
  final Duration duration;
  final bool isMyMuted;
  final bool isMyVideoOff;
  final String sessionTitle;
  final String? errorMessage;
  final RtcEngine? engine;

  const GroupSessionState({
    this.phase = CallPhase.initial,
    this.participants = const [],
    this.duration = Duration.zero,
    this.isMyMuted = false,
    this.isMyVideoOff = false,
    this.sessionTitle = 'Group Session',
    this.errorMessage,
    this.engine,
  });

  bool get isLoading =>
      phase == CallPhase.loadingToken || phase == CallPhase.connecting;

  GroupSessionState copyWith({
    CallPhase? phase,
    List<GroupParticipant>? participants,
    Duration? duration,
    bool? isMyMuted,
    bool? isMyVideoOff,
    String? sessionTitle,
    String? errorMessage,
    RtcEngine? engine,
    bool clearError = false,
  }) {
    return GroupSessionState(
      phase: phase ?? this.phase,
      participants: participants ?? this.participants,
      duration: duration ?? this.duration,
      isMyMuted: isMyMuted ?? this.isMyMuted,
      isMyVideoOff: isMyVideoOff ?? this.isMyVideoOff,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      engine: engine ?? this.engine,
    );
  }

  @override
  List<Object?> get props => [
        phase,
        participants,
        duration,
        isMyMuted,
        isMyVideoOff,
        sessionTitle,
        errorMessage,
        engine,
      ];
}

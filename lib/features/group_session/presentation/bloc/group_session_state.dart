import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';

import '../../../agora/presentation/models/call_phase.dart';
import '../../data/models/group_session_hub_models.dart';

class GroupParticipant extends Equatable {
  final int agoraUid;
  final String name;
  final bool isMuted;
  final bool isMainSpeaker;
  final bool isLocal;
  final bool isHealer;

  const GroupParticipant({
    required this.agoraUid,
    required this.name,
    this.isMuted = false,
    this.isMainSpeaker = false,
    this.isLocal = false,
    this.isHealer = false,
  });

  GroupParticipant copyWith({
    int? agoraUid,
    String? name,
    bool? isMuted,
    bool? isMainSpeaker,
    bool? isLocal,
    bool? isHealer,
  }) {
    return GroupParticipant(
      agoraUid: agoraUid ?? this.agoraUid,
      name: name ?? this.name,
      isMuted: isMuted ?? this.isMuted,
      isMainSpeaker: isMainSpeaker ?? this.isMainSpeaker,
      isLocal: isLocal ?? this.isLocal,
      isHealer: isHealer ?? this.isHealer,
    );
  }

  @override
  List<Object?> get props =>
      [agoraUid, name, isMuted, isMainSpeaker, isLocal, isHealer];
}

class GroupSessionState extends Equatable {
  final CallPhase phase;
  final List<GroupParticipant> participants;
  final Duration duration;
  final bool isMyMuted;
  final bool isMyVideoOff;
  final String sessionTitle;
  final String healerImage;
  final String? errorMessage;
  final RtcEngine? engine;
  final GroupSessionEndedPayload? endSummary;
  final bool sessionAutoDisconnected;
  final bool sessionEndedByHealer;

  const GroupSessionState({
    this.phase = CallPhase.initial,
    this.participants = const [],
    this.duration = Duration.zero,
    this.isMyMuted = false,
    this.isMyVideoOff = false,
    this.sessionTitle = 'Group Session',
    this.healerImage = 'assets/image/doctorprofile.png',
    this.errorMessage,
    this.engine,
    this.endSummary,
    this.sessionAutoDisconnected = false,
    this.sessionEndedByHealer = false,
  });

  bool get isLoading =>
      phase == CallPhase.loadingToken || phase == CallPhase.connecting;

  bool get hasRemoteParticipants =>
      participants.any((participant) => !participant.isLocal);

  /// Patient is in the channel but healer (or any remote) has not joined yet.
  bool get isWaitingForHealer =>
      phase == CallPhase.inProgress && !hasRemoteParticipants;

  GroupSessionState copyWith({
    CallPhase? phase,
    List<GroupParticipant>? participants,
    Duration? duration,
    bool? isMyMuted,
    bool? isMyVideoOff,
    String? sessionTitle,
    String? healerImage,
    String? errorMessage,
    RtcEngine? engine,
    GroupSessionEndedPayload? endSummary,
    bool? sessionAutoDisconnected,
    bool? sessionEndedByHealer,
    bool clearError = false,
    bool clearEngine = false,
  }) {
    return GroupSessionState(
      phase: phase ?? this.phase,
      participants: participants ?? this.participants,
      duration: duration ?? this.duration,
      isMyMuted: isMyMuted ?? this.isMyMuted,
      isMyVideoOff: isMyVideoOff ?? this.isMyVideoOff,
      sessionTitle: sessionTitle ?? this.sessionTitle,
      healerImage: healerImage ?? this.healerImage,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      engine: clearEngine ? null : (engine ?? this.engine),
      endSummary: endSummary ?? this.endSummary,
      sessionAutoDisconnected:
          sessionAutoDisconnected ?? this.sessionAutoDisconnected,
      sessionEndedByHealer:
          sessionEndedByHealer ?? this.sessionEndedByHealer,
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
        healerImage,
        errorMessage,
        engine,
        endSummary,
        sessionAutoDisconnected,
        sessionEndedByHealer,
      ];
}

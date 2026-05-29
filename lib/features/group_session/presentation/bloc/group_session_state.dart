import 'package:equatable/equatable.dart';

class GroupParticipant extends Equatable {
  final String id;
  final String name;
  final String role;
  final String imageUrl;
  final bool isMuted;
  final bool isHandRaised;
  final bool isMainSpeaker;

  const GroupParticipant({
    required this.id,
    required this.name,
    required this.role,
    required this.imageUrl,
    this.isMuted = false,
    this.isHandRaised = false,
    this.isMainSpeaker = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    role,
    imageUrl,
    isMuted,
    isHandRaised,
    isMainSpeaker,
  ];
}

class GroupSessionState extends Equatable {
  final List<GroupParticipant> participants;
  final Duration duration;
  final double walletBalance;
  final bool isMyMuted;
  final bool isMyVideoOff;

  const GroupSessionState({
    this.participants = const [],
    this.duration = const Duration(minutes: 24, seconds: 56),
    this.walletBalance = 150.0,
    this.isMyMuted = false,
    this.isMyVideoOff = false,
  });

  GroupSessionState copyWith({
    List<GroupParticipant>? participants,
    Duration? duration,
    double? walletBalance,
    bool? isMyMuted,
    bool? isMyVideoOff,
  }) {
    return GroupSessionState(
      participants: participants ?? this.participants,
      duration: duration ?? this.duration,
      walletBalance: walletBalance ?? this.walletBalance,
      isMyMuted: isMyMuted ?? this.isMyMuted,
      isMyVideoOff: isMyVideoOff ?? this.isMyVideoOff,
    );
  }

  @override
  List<Object?> get props => [
    participants,
    duration,
    walletBalance,
    isMyMuted,
    isMyVideoOff,
  ];
}

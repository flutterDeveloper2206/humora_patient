import 'package:equatable/equatable.dart';

enum CallStatus { connecting, connected, ended }

class VideoCallState extends Equatable {
  final CallStatus status;
  final Duration duration;
  final bool isMuted;
  final bool isCameraOff;
  final bool isSpeakerOn;

  const VideoCallState({
    this.status = CallStatus.connecting,
    this.duration = Duration.zero,
    this.isMuted = false,
    this.isCameraOff = false,
    this.isSpeakerOn = true,
  });

  VideoCallState copyWith({
    CallStatus? status,
    Duration? duration,
    bool? isMuted,
    bool? isCameraOff,
    bool? isSpeakerOn,
  }) {
    return VideoCallState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      isMuted: isMuted ?? this.isMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }

  @override
  List<Object?> get props => [
    status,
    duration,
    isMuted,
    isCameraOff,
    isSpeakerOn,
  ];
}

import 'package:equatable/equatable.dart';

class VoiceCallState extends Equatable {
  final Duration duration;
  final bool isMuted;
  final String callerName;
  final String callerImage;
  final double walletBalance;

  const VoiceCallState({
    this.duration = Duration.zero,
    this.isMuted = false,
    this.callerName = 'Lord Justin',
    this.callerImage = 'assets/image/doctorprofile.png',
    this.walletBalance = 55.0,
  });

  VoiceCallState copyWith({
    Duration? duration,
    bool? isMuted,
    String? callerName,
    String? callerImage,
    double? walletBalance,
  }) {
    return VoiceCallState(
      duration: duration ?? this.duration,
      isMuted: isMuted ?? this.isMuted,
      callerName: callerName ?? this.callerName,
      callerImage: callerImage ?? this.callerImage,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }

  @override
  List<Object?> get props => [
    duration,
    isMuted,
    callerName,
    callerImage,
    walletBalance,
  ];
}

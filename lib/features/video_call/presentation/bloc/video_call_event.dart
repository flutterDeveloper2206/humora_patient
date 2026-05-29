import 'package:equatable/equatable.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();

  @override
  List<Object?> get props => [];
}

class StartCall extends VideoCallEvent {}

class ConnectCall extends VideoCallEvent {}

class EndCall extends VideoCallEvent {}

class UpdateTimer extends VideoCallEvent {
  final Duration duration;
  const UpdateTimer(this.duration);

  @override
  List<Object?> get props => [duration];
}

class ToggleMute extends VideoCallEvent {}

class ToggleCamera extends VideoCallEvent {}

class ToggleSpeaker extends VideoCallEvent {}

class SwitchCamera extends VideoCallEvent {}

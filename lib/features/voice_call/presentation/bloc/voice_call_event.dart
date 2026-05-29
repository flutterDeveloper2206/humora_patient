import 'package:equatable/equatable.dart';

abstract class VoiceCallEvent extends Equatable {
  const VoiceCallEvent();

  @override
  List<Object?> get props => [];
}

class StartTimer extends VoiceCallEvent {}

class UpdateDuration extends VoiceCallEvent {
  final Duration duration;
  const UpdateDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class ToggleMute extends VoiceCallEvent {}

class EndCall extends VoiceCallEvent {}

import 'package:equatable/equatable.dart';

import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/services/agora_rtc_service.dart';

abstract class VoiceCallEvent extends Equatable {
  const VoiceCallEvent();

  @override
  List<Object?> get props => [];
}

class LoadCall extends VoiceCallEvent {
  final CallRouteArgs args;
  const LoadCall(this.args);

  @override
  List<Object?> get props => [args];
}

class RetryCall extends VoiceCallEvent {}

class AgoraEngineEvent extends VoiceCallEvent {
  final AgoraCallEvent event;
  const AgoraEngineEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateDuration extends VoiceCallEvent {
  final Duration duration;
  const UpdateDuration(this.duration);

  @override
  List<Object?> get props => [duration];
}

class ToggleMute extends VoiceCallEvent {}

class ToggleSpeaker extends VoiceCallEvent {}

class EndCall extends VoiceCallEvent {}

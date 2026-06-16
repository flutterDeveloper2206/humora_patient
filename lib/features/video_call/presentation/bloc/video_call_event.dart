import 'package:equatable/equatable.dart';

import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/services/agora_rtc_service.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();

  @override
  List<Object?> get props => [];
}

class LoadCall extends VideoCallEvent {
  final CallRouteArgs args;
  const LoadCall(this.args);

  @override
  List<Object?> get props => [args];
}

class RetryCall extends VideoCallEvent {}

class AgoraEngineEvent extends VideoCallEvent {
  final AgoraCallEvent event;
  const AgoraEngineEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateTimer extends VideoCallEvent {
  final Duration duration;
  const UpdateTimer(this.duration);

  @override
  List<Object?> get props => [duration];
}

class EndCall extends VideoCallEvent {}

class ToggleMute extends VideoCallEvent {}

class ToggleCamera extends VideoCallEvent {}

class ToggleSpeaker extends VideoCallEvent {}

class SwitchCamera extends VideoCallEvent {}

import 'package:equatable/equatable.dart';

import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/services/agora_rtc_service.dart';

abstract class GroupSessionEvent extends Equatable {
  const GroupSessionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSession extends GroupSessionEvent {
  final CallRouteArgs args;
  const LoadSession(this.args);

  @override
  List<Object?> get props => [args];
}

class RetrySession extends GroupSessionEvent {}

class AgoraEngineEvent extends GroupSessionEvent {
  final AgoraCallEvent event;
  const AgoraEngineEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class ToggleMyMute extends GroupSessionEvent {}

class ToggleMyVideo extends GroupSessionEvent {}

class EndSession extends GroupSessionEvent {}

class UpdateSessionTimer extends GroupSessionEvent {
  final Duration duration;
  const UpdateSessionTimer(this.duration);

  @override
  List<Object?> get props => [duration];
}

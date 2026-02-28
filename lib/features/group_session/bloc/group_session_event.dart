import 'package:equatable/equatable.dart';

abstract class GroupSessionEvent extends Equatable {
  const GroupSessionEvent();
  @override
  List<Object?> get props => [];
}

class LoadSession extends GroupSessionEvent {}

class ToggleMyMute extends GroupSessionEvent {}

class ToggleMyVideo extends GroupSessionEvent {}

class EndSession extends GroupSessionEvent {}

class UpdateSessionTimer extends GroupSessionEvent {
  final Duration duration;
  const UpdateSessionTimer(this.duration);
  @override
  List<Object?> get props => [duration];
}

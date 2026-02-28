import 'package:equatable/equatable.dart';

abstract class LiveCounsellingSessionEvent extends Equatable {
  const LiveCounsellingSessionEvent();

  @override
  List<Object?> get props => [];
}

class LoadLiveCounsellingSessionOptions extends LiveCounsellingSessionEvent {}

class SelectLiveCounsellingSession extends LiveCounsellingSessionEvent {
  final int sessionId;

  const SelectLiveCounsellingSession(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

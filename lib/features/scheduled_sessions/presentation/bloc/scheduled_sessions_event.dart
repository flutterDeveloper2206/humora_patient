import 'package:equatable/equatable.dart';

abstract class ScheduledSessionsEvent extends Equatable {
  const ScheduledSessionsEvent();
  @override
  List<Object?> get props => [];
}

class LoadCalendar extends ScheduledSessionsEvent {
  const LoadCalendar();
}

class RefreshCalendar extends ScheduledSessionsEvent {
  const RefreshCalendar();
}

class SelectDate extends ScheduledSessionsEvent {
  final DateTime date;
  const SelectDate(this.date);
  @override
  List<Object?> get props => [date];
}

class CancelSession extends ScheduledSessionsEvent {
  final String sessionId;
  const CancelSession(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

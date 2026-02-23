part of 'sessions_bloc.dart';

abstract class SessionsEvent {
  const SessionsEvent();
}

class ToggleAllDays extends SessionsEvent {
  final bool value;
  const ToggleAllDays(this.value);
}

class ToggleWeekDays extends SessionsEvent {
  final bool value;
  const ToggleWeekDays(this.value);
}

class SelectDate extends SessionsEvent {
  final DateTime date;
  const SelectDate(this.date);
}

class ShiftWeek extends SessionsEvent {
  final int offsetWeeks;
  const ShiftWeek(this.offsetWeeks);
}

class SetBaseCalendarDate extends SessionsEvent {
  final DateTime date;
  const SetBaseCalendarDate(this.date);
}

class SelectWeekDay extends SessionsEvent {
  final String day;
  const SelectWeekDay(this.day);
}

class AddTimeSlot extends SessionsEvent {
  final String sessionType;
  const AddTimeSlot(this.sessionType);
}

class RemoveTimeSlot extends SessionsEvent {
  final String sessionType;
  final int index;
  const RemoveTimeSlot(this.sessionType, this.index);
}

class UpdateTempStartTime extends SessionsEvent {
  final String time;
  const UpdateTempStartTime(this.time);
}

class UpdateTempEndTime extends SessionsEvent {
  final String time;
  const UpdateTempEndTime(this.time);
}

class SubmitSessions extends SessionsEvent {
  const SubmitSessions();
}

part of 'sessions_bloc.dart';

enum SessionsStatus { initial, loading, success, failure }

class SessionsState {
  final bool isAllDaysEnabled;
  final bool isWeekDaysEnabled;
  final DateTime selectedDate;
  final String selectedWeekDay;

  // Data storage: Maps selection to session type to slots
  // Key for dateSlots is the date without time components
  final Map<DateTime, Map<String, List<String>>> dateSlots;
  final Map<String, Map<String, List<String>>> weekDaySlots;

  final DateTime? baseCalendarDate;

  final String startTime;
  final String endTime;
  final SessionsStatus status;
  final String? errorMessage;

  const SessionsState({
    this.isAllDaysEnabled = true,
    this.isWeekDaysEnabled = false,
    required this.selectedDate,
    this.selectedWeekDay = "Wed",
    this.dateSlots = const {},
    this.weekDaySlots = const {},
    this.baseCalendarDate,
    this.startTime = "10:00",
    this.endTime = "16:00",
    this.status = SessionsStatus.initial,
    this.errorMessage,
  });

  // Helper to get sessions for current selection
  Map<String, List<String>> get currentSlots {
    if (isAllDaysEnabled) {
      final normalizedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      return dateSlots[normalizedDate] ??
          {
            'Live Counselling': ['09:00 to 10:00'],
            'Personal Healing': ['09:00 to 10:00'],
            'Group Healing': ['09:00 to 10:00'],
          };
    } else {
      return weekDaySlots[selectedWeekDay] ??
          {
            'Live Counselling': ['09:00 to 10:00'],
            'Personal Healing': ['09:00 to 10:00'],
            'Group Healing': ['09:00 to 10:00'],
          };
    }
  }

  SessionsState copyWith({
    bool? isAllDaysEnabled,
    bool? isWeekDaysEnabled,
    DateTime? selectedDate,
    String? selectedWeekDay,
    Map<DateTime, Map<String, List<String>>>? dateSlots,
    Map<String, Map<String, List<String>>>? weekDaySlots,
    DateTime? baseCalendarDate,
    String? startTime,
    String? endTime,
    SessionsStatus? status,
    String? errorMessage,
  }) {
    return SessionsState(
      isAllDaysEnabled: isAllDaysEnabled ?? this.isAllDaysEnabled,
      isWeekDaysEnabled: isWeekDaysEnabled ?? this.isWeekDaysEnabled,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedWeekDay: selectedWeekDay ?? this.selectedWeekDay,
      dateSlots: dateSlots ?? this.dateSlots,
      weekDaySlots: weekDaySlots ?? this.weekDaySlots,
      baseCalendarDate: baseCalendarDate ?? this.baseCalendarDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

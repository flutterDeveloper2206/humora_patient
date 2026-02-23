import 'package:flutter_bloc/flutter_bloc.dart';

part 'sessions_event.dart';
part 'sessions_state.dart';

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  SessionsBloc()
    : super(
        SessionsState(
          selectedDate: DateTime.now(),
          baseCalendarDate: DateTime.now(),
        ),
      ) {
    on<ToggleAllDays>((event, emit) {
      if (event.value) {
        emit(state.copyWith(isAllDaysEnabled: true, isWeekDaysEnabled: false));
      } else {
        emit(state.copyWith(isAllDaysEnabled: false));
      }
    });

    on<ToggleWeekDays>((event, emit) {
      if (event.value) {
        emit(state.copyWith(isWeekDaysEnabled: true, isAllDaysEnabled: false));
      } else {
        emit(state.copyWith(isWeekDaysEnabled: false));
      }
    });

    on<SelectDate>((event, emit) {
      emit(state.copyWith(selectedDate: event.date));
    });

    on<ShiftWeek>((event, emit) {
      final currentBase = state.baseCalendarDate ?? DateTime.now();
      emit(
        state.copyWith(
          baseCalendarDate: currentBase.add(
            Duration(days: 7 * event.offsetWeeks),
          ),
        ),
      );
    });

    on<SetBaseCalendarDate>((event, emit) {
      emit(
        state.copyWith(baseCalendarDate: event.date, selectedDate: event.date),
      );
    });

    on<SelectWeekDay>((event, emit) {
      emit(state.copyWith(selectedWeekDay: event.day));
    });

    on<AddTimeSlot>((event, emit) {
      final slot = "${state.startTime} to ${state.endTime}";

      if (state.isAllDaysEnabled) {
        final normalizedDate = DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
        );
        final newDateSlots = Map<DateTime, Map<String, List<String>>>.from(
          state.dateSlots,
        );

        // Use provided default if this is the first time adding to this date
        Map<String, List<String>> currentDaySessions;
        if (newDateSlots.containsKey(normalizedDate)) {
          currentDaySessions = Map<String, List<String>>.from(
            newDateSlots[normalizedDate]!,
          );
        } else {
          currentDaySessions = {
            'Live Counselling': ['09:00 to 10:00'],
            'Personal Healing': ['09:00 to 10:00'],
            'Group Healing': ['09:00 to 10:00'],
          };
        }

        final currentSlots = List<String>.from(
          currentDaySessions[event.sessionType] ?? [],
        );

        if (!currentSlots.contains(slot)) {
          currentSlots.add(slot);
          currentSlots.sort();
          currentDaySessions[event.sessionType] = currentSlots;
          newDateSlots[normalizedDate] = currentDaySessions;
          emit(state.copyWith(dateSlots: newDateSlots));
        }
      } else {
        final newWeekDaySlots = Map<String, Map<String, List<String>>>.from(
          state.weekDaySlots,
        );

        Map<String, List<String>> currentDaySessions;
        if (newWeekDaySlots.containsKey(state.selectedWeekDay)) {
          currentDaySessions = Map<String, List<String>>.from(
            newWeekDaySlots[state.selectedWeekDay]!,
          );
        } else {
          currentDaySessions = {
            'Live Counselling': ['09:00 to 10:00'],
            'Personal Healing': ['09:00 to 10:00'],
            'Group Healing': ['09:00 to 10:00'],
          };
        }

        final currentSlots = List<String>.from(
          currentDaySessions[event.sessionType] ?? [],
        );

        if (!currentSlots.contains(slot)) {
          currentSlots.add(slot);
          currentSlots.sort();
          currentDaySessions[event.sessionType] = currentSlots;
          newWeekDaySlots[state.selectedWeekDay] = currentDaySessions;
          emit(state.copyWith(weekDaySlots: newWeekDaySlots));
        }
      }
    });

    on<RemoveTimeSlot>((event, emit) {
      if (state.isAllDaysEnabled) {
        final normalizedDate = DateTime(
          state.selectedDate.year,
          state.selectedDate.month,
          state.selectedDate.day,
        );
        final newDateSlots = Map<DateTime, Map<String, List<String>>>.from(
          state.dateSlots,
        );
        final currentDaySessions = Map<String, List<String>>.from(
          newDateSlots[normalizedDate] ??
              {
                'Live Counselling': ['09:00 to 10:00'],
                'Personal Healing': ['09:00 to 10:00'],
                'Group Healing': ['09:00 to 10:00'],
              },
        );
        final currentSlots = List<String>.from(
          currentDaySessions[event.sessionType] ?? [],
        );

        if (event.index < currentSlots.length) {
          currentSlots.removeAt(event.index);
          currentDaySessions[event.sessionType] = currentSlots;
          newDateSlots[normalizedDate] = currentDaySessions;
          emit(state.copyWith(dateSlots: newDateSlots));
        }
      } else {
        final newWeekDaySlots = Map<String, Map<String, List<String>>>.from(
          state.weekDaySlots,
        );
        final currentDaySessions = Map<String, List<String>>.from(
          newWeekDaySlots[state.selectedWeekDay] ??
              {
                'Live Counselling': ['09:00 to 10:00'],
                'Personal Healing': ['09:00 to 10:00'],
                'Group Healing': ['09:00 to 10:00'],
              },
        );
        final currentSlots = List<String>.from(
          currentDaySessions[event.sessionType] ?? [],
        );

        if (event.index < currentSlots.length) {
          currentSlots.removeAt(event.index);
          currentDaySessions[event.sessionType] = currentSlots;
          newWeekDaySlots[state.selectedWeekDay] = currentDaySessions;
          emit(state.copyWith(weekDaySlots: newWeekDaySlots));
        }
      }
    });

    on<UpdateTempStartTime>((event, emit) {
      emit(state.copyWith(startTime: event.time));
    });

    on<UpdateTempEndTime>((event, emit) {
      emit(state.copyWith(endTime: event.time));
    });

    on<SubmitSessions>((event, emit) async {
      emit(state.copyWith(status: SessionsStatus.loading));
      try {
        await Future.delayed(const Duration(seconds: 1));
        emit(state.copyWith(status: SessionsStatus.success));
      } catch (e) {
        emit(
          state.copyWith(
            status: SessionsStatus.failure,
            errorMessage: e.toString(),
          ),
        );
      }
    });
  }
}

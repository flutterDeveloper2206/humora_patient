import 'package:flutter_bloc/flutter_bloc.dart';
import 'scheduled_sessions_event.dart';
import 'scheduled_sessions_state.dart';

class ScheduledSessionsBloc
    extends Bloc<ScheduledSessionsEvent, ScheduledSessionsState> {
  ScheduledSessionsBloc()
    : super(ScheduledSessionsState(selectedDate: DateTime(2025, 9, 25))) {
    on<LoadSessions>(_onLoadSessions);
    on<SelectDate>(_onSelectDate);
    on<CancelSession>(_onCancelSession);
  }

  void _onLoadSessions(
    LoadSessions event,
    Emitter<ScheduledSessionsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // Simulating loading data based on date
    // For Wednesday 25th, we show sessions. For other dates we show empty.
    if (event.date.day == 25) {
      final mockSessions = [
        const ScheduledSession(
          id: '1',
          healerName: 'Dr. Lin Lector',
          healerImage: 'assets/image/doctorprofile.png',
          category: 'Emotional Healing',
          rating: 4.5,
          sessionType: 'Video Call Consultations',
          time: '7 AM',
        ),
        const ScheduledSession(
          id: '2',
          healerName: 'Dr. Hannibal Lector',
          healerImage: 'assets/image/111.png',
          category: 'Emotional Healing',
          rating: 4.5,
          sessionType: 'Video Call Consultations',
          time: '8 AM',
        ),
        const ScheduledSession(
          id: '3',
          healerName: 'Dr. Hina Lector',
          healerImage: 'assets/image/doctorprofile.png',
          category: 'Emotional Healing',
          rating: 4.5,
          sessionType: 'Video Call Consultations',
          time: '12 AM',
        ),
      ];
      emit(
        state.copyWith(
          sessions: mockSessions,
          isLoading: false,
          selectedDate: event.date,
        ),
      );
    } else {
      emit(
        state.copyWith(
          sessions: [],
          isLoading: false,
          selectedDate: event.date,
        ),
      );
    }
  }

  void _onSelectDate(SelectDate event, Emitter<ScheduledSessionsState> emit) {
    add(LoadSessions(event.date));
  }

  void _onCancelSession(
    CancelSession event,
    Emitter<ScheduledSessionsState> emit,
  ) {
    final updatedSessions = state.sessions
        .where((s) => s.id != event.sessionId)
        .toList();
    emit(state.copyWith(sessions: updatedSessions));
  }
}

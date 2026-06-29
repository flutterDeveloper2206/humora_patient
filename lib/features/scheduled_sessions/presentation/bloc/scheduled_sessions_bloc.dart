import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/healer_calendar_api_service.dart';
import '../../data/models/healer_calendar_models.dart';
import 'scheduled_sessions_event.dart';
import 'scheduled_sessions_state.dart';

class ScheduledSessionsBloc
    extends Bloc<ScheduledSessionsEvent, ScheduledSessionsState> {
  final HealerCalendarApiService _api;

  ScheduledSessionsBloc({HealerCalendarApiService? api})
      : _api = api ?? HealerCalendarApiService(),
        super(ScheduledSessionsState(selectedDate: _today())) {
    on<LoadCalendar>(_onLoadCalendar);
    on<RefreshCalendar>(_onRefreshCalendar);
    on<SelectDate>(_onSelectDate);
    on<CancelSession>(_onCancelSession);
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _onLoadCalendar(
    LoadCalendar event,
    Emitter<ScheduledSessionsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _fetchAndEmit(emit, isRefresh: false);
  }

  Future<void> _onRefreshCalendar(
    RefreshCalendar event,
    Emitter<ScheduledSessionsState> emit,
  ) async {
    if (state.allSessions.isNotEmpty) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else {
      emit(state.copyWith(isLoading: true, clearError: true));
    }
    await _fetchAndEmit(emit, isRefresh: state.allSessions.isNotEmpty);
  }

  Future<void> _fetchAndEmit(
    Emitter<ScheduledSessionsState> emit, {
    required bool isRefresh,
  }) async {
    try {
      final response = await _api.fetchCalendar();
      final all = _mapSessions(response.sessions);
      final selectedDate = isRefresh
          ? state.selectedDate
          : _resolveSelectedDate(all, state.selectedDate);
      final filtered = _filterByDate(all, selectedDate);
      emit(
        state.copyWith(
          selectedDate: selectedDate,
          allSessions: all,
          sessions: filtered,
          isLoading: false,
          isRefreshing: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: _cleanError(e),
        ),
      );
    }
  }

  void _onSelectDate(SelectDate event, Emitter<ScheduledSessionsState> emit) {
    final date = DateTime(event.date.year, event.date.month, event.date.day);
    emit(
      state.copyWith(
        selectedDate: date,
        sessions: _filterByDate(state.allSessions, date),
        clearError: true,
      ),
    );
  }

  void _onCancelSession(
    CancelSession event,
    Emitter<ScheduledSessionsState> emit,
  ) {
    final updatedAll = state.allSessions
        .where((s) => s.id != event.sessionId)
        .toList();
    emit(
      state.copyWith(
        allSessions: updatedAll,
        sessions: _filterByDate(updatedAll, state.selectedDate),
      ),
    );
  }

  List<ScheduledSession> _mapSessions(List<HealerCalendarSession> sessions) {
    final mapped = sessions
        .map(ScheduledSession.fromCalendar)
        .toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    return mapped;
  }

  List<ScheduledSession> _filterByDate(
    List<ScheduledSession> sessions,
    DateTime date,
  ) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return sessions.where((session) => session.bookingDate == key).toList();
  }

  String _cleanError(Object e) =>
      e.toString().replaceAll('Exception: ', '');

  DateTime _resolveSelectedDate(
    List<ScheduledSession> all,
    DateTime current,
  ) {
    if (_filterByDate(all, current).isNotEmpty) return current;

    final today = _today();
    final upcoming = all.where((session) {
      final date = DateTime.tryParse(session.bookingDate);
      if (date == null) return false;
      final day = DateTime(date.year, date.month, date.day);
      return !day.isBefore(today);
    }).toList();

    if (upcoming.isNotEmpty) {
      final date = DateTime.tryParse(upcoming.first.bookingDate);
      if (date != null) return DateTime(date.year, date.month, date.day);
    }

    if (all.isNotEmpty) {
      final date = DateTime.tryParse(all.last.bookingDate);
      if (date != null) return DateTime(date.year, date.month, date.day);
    }

    return current;
  }
}

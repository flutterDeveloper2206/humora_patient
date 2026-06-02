import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/my_booking_models.dart';
import '../../domain/usecases/fetch_my_bookings_usecase.dart';
import 'my_sessions_event.dart';
import 'my_sessions_state.dart';

class MySessionsBloc extends Bloc<MySessionsEvent, MySessionsState> {
  final FetchMyBookingsUseCase _fetchMyBookings;
  int _fetchGeneration = 0;

  MySessionsBloc({FetchMyBookingsUseCase? fetchMyBookings})
      : _fetchMyBookings = fetchMyBookings ?? FetchMyBookingsUseCase(),
        super(MySessionsInitial()) {
    on<LoadMySessions>(_onLoad);
    on<RefreshMySessions>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadMySessions event,
    Emitter<MySessionsState> emit,
  ) async {
    if (state is MySessionsLoaded || state is MySessionsLoading) return;
    emit(MySessionsLoading());
    await _fetch(emit, restoreOnError: null);
  }

  Future<void> _onRefresh(
    RefreshMySessions event,
    Emitter<MySessionsState> emit,
  ) async {
    final current = state;
    if (current is MySessionsLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else if (current is! MySessionsLoading) {
      emit(MySessionsLoading());
    }
    await _fetch(
      emit,
      restoreOnError: current is MySessionsLoaded ? current : null,
    );
  }

  Future<void> _fetch(
    Emitter<MySessionsState> emit, {
    MySessionsLoaded? restoreOnError,
  }) async {
    final generation = ++_fetchGeneration;
    try {
      final bookings = await _fetchMyBookings();
      if (generation != _fetchGeneration) return;

      final sorted = MyBookingsGrouper.sortUpcomingFirst(bookings);
      final groups = MyBookingsGrouper.groupByDate(sorted);
      emit(MySessionsLoaded(groups: groups, isRefreshing: false));
    } catch (e) {
      if (generation != _fetchGeneration) return;
      if (restoreOnError != null) {
        emit(restoreOnError.copyWith(isRefreshing: false));
        return;
      }
      emit(MySessionsError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

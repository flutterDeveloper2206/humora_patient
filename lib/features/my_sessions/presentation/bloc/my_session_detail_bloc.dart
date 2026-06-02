import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/fetch_booking_detail_usecase.dart';
import 'my_session_detail_event.dart';
import 'my_session_detail_state.dart';

class MySessionDetailBloc
    extends Bloc<MySessionDetailEvent, MySessionDetailState> {
  final FetchBookingDetailUseCase _fetchBookingDetail;

  MySessionDetailBloc({FetchBookingDetailUseCase? fetchBookingDetail})
      : _fetchBookingDetail = fetchBookingDetail ?? FetchBookingDetailUseCase(),
        super(MySessionDetailInitial()) {
    on<LoadBookingDetail>(_onLoad);
  }

  Future<void> _onLoad(
    LoadBookingDetail event,
    Emitter<MySessionDetailState> emit,
  ) async {
    final current = state;
    if (current is MySessionDetailLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(MySessionDetailLoading());
    }

    try {
      final booking = await _fetchBookingDetail(event.bookingId);
      emit(MySessionDetailLoaded(booking, isRefreshing: false));
    } catch (e) {
      if (current is MySessionDetailLoaded) {
        emit(current.copyWith(isRefreshing: false));
        return;
      }
      emit(MySessionDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

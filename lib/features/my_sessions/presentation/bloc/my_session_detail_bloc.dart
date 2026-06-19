import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/booking/data/datasource/booking_api_service.dart';
import 'package:humora_patient/features/booking/domain/usecases/cancel_booking_usecase.dart';

import '../../domain/usecases/fetch_booking_detail_usecase.dart';
import 'my_session_detail_event.dart';
import 'my_session_detail_state.dart';

class MySessionDetailBloc
    extends Bloc<MySessionDetailEvent, MySessionDetailState> {
  final FetchBookingDetailUseCase _fetchBookingDetail;
  final CancelBookingUseCase _cancelBooking;

  MySessionDetailBloc({
    FetchBookingDetailUseCase? fetchBookingDetail,
    CancelBookingUseCase? cancelBooking,
  })  : _fetchBookingDetail =
            fetchBookingDetail ?? FetchBookingDetailUseCase(),
        _cancelBooking = cancelBooking ?? CancelBookingUseCase(),
        super(MySessionDetailInitial()) {
    on<LoadBookingDetail>(_onLoad);
    on<CancelBooking>(_onCancel);
    on<ClearDetailFeedback>(_onClearFeedback);
  }

  String _cleanError(Object e) {
    if (e is BookingApiException) return e.message;
    return e.toString().replaceAll('Exception: ', '');
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
      emit(MySessionDetailError(_cleanError(e)));
    }
  }

  Future<void> _onCancel(
    CancelBooking event,
    Emitter<MySessionDetailState> emit,
  ) async {
    final current = state;
    if (current is! MySessionDetailLoaded) return;

    emit(current.copyWith(isCancelling: true, clearFeedback: true));

    try {
      final response = await _cancelBooking(
        bookingId: event.bookingId,
        reason: event.reason,
      );
      final booking = await _fetchBookingDetail(event.bookingId);
      emit(
        MySessionDetailLoaded(
          booking,
          successMessage: response.message,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isCancelling: false,
          cancelError: _cleanError(e),
        ),
      );
    }
  }

  void _onClearFeedback(
    ClearDetailFeedback event,
    Emitter<MySessionDetailState> emit,
  ) {
    final current = state;
    if (current is MySessionDetailLoaded) {
      emit(current.copyWith(clearFeedback: true));
    }
  }
}

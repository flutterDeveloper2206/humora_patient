import 'package:equatable/equatable.dart';

abstract class MySessionDetailEvent extends Equatable {
  const MySessionDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookingDetail extends MySessionDetailEvent {
  final String bookingId;

  const LoadBookingDetail(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class CancelBooking extends MySessionDetailEvent {
  final String bookingId;
  final String reason;

  const CancelBooking({
    required this.bookingId,
    required this.reason,
  });

  @override
  List<Object?> get props => [bookingId, reason];
}

class ClearDetailFeedback extends MySessionDetailEvent {
  const ClearDetailFeedback();
}

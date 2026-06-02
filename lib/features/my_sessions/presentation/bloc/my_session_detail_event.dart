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

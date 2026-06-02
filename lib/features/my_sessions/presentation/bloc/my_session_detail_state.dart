import 'package:equatable/equatable.dart';

import '../../data/models/my_booking_models.dart';

abstract class MySessionDetailState extends Equatable {
  const MySessionDetailState();

  @override
  List<Object?> get props => [];
}

class MySessionDetailInitial extends MySessionDetailState {}

class MySessionDetailLoading extends MySessionDetailState {}

class MySessionDetailLoaded extends MySessionDetailState {
  final BookingDetailModel booking;
  final bool isRefreshing;

  const MySessionDetailLoaded(
    this.booking, {
    this.isRefreshing = false,
  });

  MySessionDetailLoaded copyWith({
    BookingDetailModel? booking,
    bool? isRefreshing,
  }) {
    return MySessionDetailLoaded(
      booking ?? this.booking,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [booking, isRefreshing];
}

class MySessionDetailError extends MySessionDetailState {
  final String message;

  const MySessionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

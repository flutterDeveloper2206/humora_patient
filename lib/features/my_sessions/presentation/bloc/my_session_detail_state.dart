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
  final bool isCancelling;
  final String? successMessage;
  final String? cancelError;

  const MySessionDetailLoaded(
    this.booking, {
    this.isRefreshing = false,
    this.isCancelling = false,
    this.successMessage,
    this.cancelError,
  });

  MySessionDetailLoaded copyWith({
    BookingDetailModel? booking,
    bool? isRefreshing,
    bool? isCancelling,
    String? successMessage,
    String? cancelError,
    bool clearFeedback = false,
  }) {
    return MySessionDetailLoaded(
      booking ?? this.booking,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isCancelling: isCancelling ?? this.isCancelling,
      successMessage:
          clearFeedback ? null : (successMessage ?? this.successMessage),
      cancelError: clearFeedback ? null : (cancelError ?? this.cancelError),
    );
  }

  @override
  List<Object?> get props =>
      [booking, isRefreshing, isCancelling, successMessage, cancelError];
}

class MySessionDetailError extends MySessionDetailState {
  final String message;

  const MySessionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

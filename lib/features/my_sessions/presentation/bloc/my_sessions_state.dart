import 'package:equatable/equatable.dart';

import '../../data/models/my_booking_models.dart';

abstract class MySessionsState extends Equatable {
  const MySessionsState();

  @override
  List<Object?> get props => [];
}

class MySessionsInitial extends MySessionsState {}

class MySessionsLoading extends MySessionsState {}

class MySessionsLoaded extends MySessionsState {
  final List<BookingDateGroup> groups;
  final bool isRefreshing;

  const MySessionsLoaded({
    required this.groups,
    this.isRefreshing = false,
  });

  bool get isEmpty =>
      groups.isEmpty || groups.every((g) => g.bookings.isEmpty);

  MySessionsLoaded copyWith({
    List<BookingDateGroup>? groups,
    bool? isRefreshing,
  }) {
    return MySessionsLoaded(
      groups: groups ?? this.groups,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [groups, isRefreshing];
}

class MySessionsError extends MySessionsState {
  final String message;

  const MySessionsError(this.message);

  @override
  List<Object?> get props => [message];
}

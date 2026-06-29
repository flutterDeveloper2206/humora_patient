import 'package:equatable/equatable.dart';

import '../../data/models/healer_calendar_models.dart';

class ScheduledSession extends Equatable {
  final String id;
  final String bookingReference;
  final String bookingDate;
  final String healerName;
  final String healerImage;
  final String serviceTypeLabel;
  final String sessionTypeLabel;
  final String bookingStatusLabel;
  final int bookingStatus;
  final String time;
  final DateTime startDateTime;
  final String? durationLabel;
  final String? priceLabel;
  final bool isLiveDirect;
  final bool canCancel;

  const ScheduledSession({
    required this.id,
    required this.bookingReference,
    required this.bookingDate,
    required this.healerName,
    required this.healerImage,
    required this.serviceTypeLabel,
    required this.sessionTypeLabel,
    required this.bookingStatusLabel,
    required this.bookingStatus,
    required this.time,
    required this.startDateTime,
    this.durationLabel,
    this.priceLabel,
    this.isLiveDirect = false,
    this.canCancel = false,
  });

  factory ScheduledSession.fromCalendar(HealerCalendarSession session) {
    return ScheduledSession(
      id: session.bookingId,
      bookingReference: session.bookingReference,
      bookingDate: session.bookingDate,
      healerName: session.healerName,
      healerImage: session.healerImage,
      serviceTypeLabel: session.serviceTypeLabel,
      sessionTypeLabel: session.sessionTypeLabel,
      bookingStatusLabel: session.bookingStatusLabel,
      bookingStatus: session.bookingStatus,
      time: session.timeLabel,
      startDateTime: session.startDateTime,
      durationLabel: session.durationLabel,
      priceLabel: session.priceLabel,
      isLiveDirect: session.isLiveDirect,
      canCancel: session.canCancel,
    );
  }

  @override
  List<Object?> get props => [id, time, bookingStatus];
}

class ScheduledSessionsState extends Equatable {
  final DateTime selectedDate;
  final List<ScheduledSession> sessions;
  final List<ScheduledSession> allSessions;
  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;

  const ScheduledSessionsState({
    required this.selectedDate,
    this.sessions = const [],
    this.allSessions = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  bool get isBusy => isLoading || isRefreshing;

  ScheduledSessionsState copyWith({
    DateTime? selectedDate,
    List<ScheduledSession>? sessions,
    List<ScheduledSession>? allSessions,
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ScheduledSessionsState(
      selectedDate: selectedDate ?? this.selectedDate,
      sessions: sessions ?? this.sessions,
      allSessions: allSessions ?? this.allSessions,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [selectedDate, sessions, allSessions, isLoading, isRefreshing, errorMessage];
}

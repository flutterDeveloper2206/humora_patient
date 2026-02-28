import 'package:equatable/equatable.dart';

class ScheduledSession extends Equatable {
  final String id;
  final String healerName;
  final String healerImage;
  final String category;
  final double rating;
  final String sessionType;
  final String time;

  const ScheduledSession({
    required this.id,
    required this.healerName,
    required this.healerImage,
    required this.category,
    required this.rating,
    required this.sessionType,
    required this.time,
  });

  @override
  List<Object?> get props => [
    id,
    healerName,
    healerImage,
    category,
    rating,
    sessionType,
    time,
  ];
}

class ScheduledSessionsState extends Equatable {
  final DateTime selectedDate;
  final List<ScheduledSession> sessions;
  final bool isLoading;

  const ScheduledSessionsState({
    required this.selectedDate,
    this.sessions = const [],
    this.isLoading = false,
  });

  ScheduledSessionsState copyWith({
    DateTime? selectedDate,
    List<ScheduledSession>? sessions,
    bool? isLoading,
  }) {
    return ScheduledSessionsState(
      selectedDate: selectedDate ?? this.selectedDate,
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [selectedDate, sessions, isLoading];
}

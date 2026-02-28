import 'package:equatable/equatable.dart';
import '../models/live_counselling_session_model.dart';

abstract class LiveCounsellingSessionState extends Equatable {
  const LiveCounsellingSessionState();

  @override
  List<Object?> get props => [];
}

class LiveCounsellingSessionInitial extends LiveCounsellingSessionState {}

class LiveCounsellingSessionLoading extends LiveCounsellingSessionState {}

class LiveCounsellingSessionLoaded extends LiveCounsellingSessionState {
  final List<LiveCounsellingSessionModel> options;
  final int? selectedId;

  const LiveCounsellingSessionLoaded({required this.options, this.selectedId});

  LiveCounsellingSessionLoaded copyWith({
    List<LiveCounsellingSessionModel>? options,
    int? selectedId,
  }) {
    return LiveCounsellingSessionLoaded(
      options: options ?? this.options,
      selectedId: selectedId ?? this.selectedId,
    );
  }

  @override
  List<Object?> get props => [options, selectedId];
}

class LiveCounsellingSessionError extends LiveCounsellingSessionState {
  final String message;

  const LiveCounsellingSessionError(this.message);

  @override
  List<Object?> get props => [message];
}

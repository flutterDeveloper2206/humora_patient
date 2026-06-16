import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class FetchHomeData extends HomeEvent {}

class UpdateHealerLiveStatus extends HomeEvent {
  final String healerId;
  final String liveStatus;

  const UpdateHealerLiveStatus({
    required this.healerId,
    required this.liveStatus,
  });

  @override
  List<Object?> get props => [healerId, liveStatus];
}

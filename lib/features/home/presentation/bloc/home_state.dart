import 'package:equatable/equatable.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<HealerModel> continueHealingHealers;
  final List<HealerModel> availableHealers;
  final bool isRefreshing;

  const HomeLoaded({
    required this.continueHealingHealers,
    required this.availableHealers,
    this.isRefreshing = false,
  });

  HomeLoaded copyWith({
    List<HealerModel>? continueHealingHealers,
    List<HealerModel>? availableHealers,
    bool? isRefreshing,
  }) {
    return HomeLoaded(
      continueHealingHealers:
          continueHealingHealers ?? this.continueHealingHealers,
      availableHealers: availableHealers ?? this.availableHealers,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props =>
      [continueHealingHealers, availableHealers, isRefreshing];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

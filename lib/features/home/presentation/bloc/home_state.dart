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

  const HomeLoaded({
    required this.continueHealingHealers,
    required this.availableHealers,
  });

  @override
  List<Object?> get props => [continueHealingHealers, availableHealers];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

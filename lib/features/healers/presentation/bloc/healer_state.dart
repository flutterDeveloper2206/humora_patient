import 'package:equatable/equatable.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';

abstract class HealerState extends Equatable {
  const HealerState();

  @override
  List<Object?> get props => [];
}

class HealerInitial extends HealerState {}

class HealerLoading extends HealerState {}

class HealerLoaded extends HealerState {
  final List<HealerModel> healers;
  const HealerLoaded(this.healers);

  @override
  List<Object?> get props => [healers];
}

class HealerError extends HealerState {
  final String message;
  const HealerError(this.message);

  @override
  List<Object?> get props => [message];
}

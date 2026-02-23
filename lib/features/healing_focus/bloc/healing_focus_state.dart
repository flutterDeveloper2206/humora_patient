import 'package:equatable/equatable.dart';

abstract class HealingFocusState extends Equatable {
  final int currentStep;
  final Map<int, Map<String, String>> selections;

  const HealingFocusState({
    required this.currentStep,
    required this.selections,
  });

  @override
  List<Object?> get props => [currentStep, selections];
}

class HealingFocusInitial extends HealingFocusState {
  const HealingFocusInitial() : super(currentStep: 1, selections: const {});
}

class HealingFocusStepChange extends HealingFocusState {
  const HealingFocusStepChange({
    required super.currentStep,
    required super.selections,
  });
}

class HealingFocusCompleted extends HealingFocusState {
  const HealingFocusCompleted({
    required super.currentStep,
    required super.selections,
  });
}

import 'package:equatable/equatable.dart';

abstract class HealingFocusEvent extends Equatable {
  const HealingFocusEvent();

  @override
  List<Object?> get props => [];
}

class NextStep extends HealingFocusEvent {}

class PreviousStep extends HealingFocusEvent {}

class SelectOption extends HealingFocusEvent {
  final int step;
  final String category;
  final String value;

  const SelectOption({
    required this.step,
    required this.category,
    required this.value,
  });

  @override
  List<Object?> get props => [step, category, value];
}

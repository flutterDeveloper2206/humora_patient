import 'package:equatable/equatable.dart';
import '../data/healer_model.dart';

abstract class HealerDetailState extends Equatable {
  const HealerDetailState();

  @override
  List<Object?> get props => [];
}

class HealerDetailInitial extends HealerDetailState {}

class HealerDetailLoading extends HealerDetailState {}

class HealerDetailLoaded extends HealerDetailState {
  final HealerModel healer;
  final int activeTabIndex;
  final DateTime? selectedDate;
  final DateTime? focusedDate;
  final String? selectedTimeCategory;
  final String? selectedTime;

  const HealerDetailLoaded({
    required this.healer,
    this.activeTabIndex = 0,
    this.selectedDate,
    this.focusedDate,
    this.selectedTimeCategory = 'Morning',
    this.selectedTime,
  });

  HealerDetailLoaded copyWith({
    HealerModel? healer,
    int? activeTabIndex,
    DateTime? selectedDate,
    DateTime? focusedDate,
    String? selectedTimeCategory,
    String? selectedTime,
  }) {
    return HealerDetailLoaded(
      healer: healer ?? this.healer,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      selectedTimeCategory: selectedTimeCategory ?? this.selectedTimeCategory,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }

  @override
  List<Object?> get props => [
    healer,
    activeTabIndex,
    selectedDate,
    focusedDate,
    selectedTimeCategory,
    selectedTime,
  ];
}

class HealerDetailError extends HealerDetailState {
  final String message;
  const HealerDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

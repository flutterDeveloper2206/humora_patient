import 'package:equatable/equatable.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';

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
  final String? selectedSlotId;
  final SessionType selectedSessionType;

  const HealerDetailLoaded({
    required this.healer,
    this.activeTabIndex = 0,
    this.selectedDate,
    this.focusedDate,
    this.selectedTimeCategory = 'Morning',
    this.selectedTime,
    this.selectedSlotId,
    this.selectedSessionType = SessionType.personal,
  });

  HealerDetailLoaded copyWith({
    HealerModel? healer,
    int? activeTabIndex,
    DateTime? selectedDate,
    DateTime? focusedDate,
    String? selectedTimeCategory,
    String? selectedTime,
    String? selectedSlotId,
    SessionType? selectedSessionType,
    bool clearSlot = false,
  }) {
    return HealerDetailLoaded(
      healer: healer ?? this.healer,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
      selectedTimeCategory: selectedTimeCategory ?? this.selectedTimeCategory,
      selectedTime: clearSlot ? null : (selectedTime ?? this.selectedTime),
      selectedSlotId: clearSlot ? null : (selectedSlotId ?? this.selectedSlotId),
      selectedSessionType: selectedSessionType ?? this.selectedSessionType,
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
        selectedSlotId,
        selectedSessionType,
      ];
}

class HealerDetailError extends HealerDetailState {
  final String message;
  const HealerDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

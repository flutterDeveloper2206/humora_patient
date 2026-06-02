import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
import 'package:humora_patient/features/healers/data/repositories/healer_repository_impl.dart';
import 'package:humora_patient/features/healers/domain/repositories/healer_repository.dart';
import 'package:humora_patient/features/healers/domain/usecases/fetch_healer_details_usecase.dart';
import 'package:humora_patient/features/healers/presentation/utils/session_slot_utils.dart';

import 'healer_detail_event.dart';
import 'healer_detail_state.dart';

class HealerDetailBloc extends Bloc<HealerDetailEvent, HealerDetailState> {
  final FetchHealerDetailsUseCase _fetchHealerDetails;

  HealerDetailBloc({HealerRepository? repository})
      : _fetchHealerDetails = FetchHealerDetailsUseCase(
          repository ?? HealerRepositoryImpl(),
        ),
        super(HealerDetailInitial()) {
    on<LoadHealerDetail>(_onLoadHealerDetail);
    on<ChangeTab>(_onChangeTab);
    on<SelectDate>(_onSelectDate);
    on<SelectTimeCategory>(_onSelectTimeCategory);
    on<SelectSlot>(_onSelectSlot);
    on<NavigateWeek>(_onNavigateWeek);
    on<ChangeSessionType>(_onChangeSessionType);
  }

  void _onChangeTab(ChangeTab event, Emitter<HealerDetailState> emit) {
    if (state is HealerDetailLoaded) {
      emit((state as HealerDetailLoaded).copyWith(activeTabIndex: event.index));
    }
  }

  void _onSelectDate(SelectDate event, Emitter<HealerDetailState> emit) {
    if (state is! HealerDetailLoaded) return;
    if (SessionSlotUtils.isPastDate(event.date)) return;
    final loaded = state as HealerDetailLoaded;
    final selection = _selectionForDate(
      loaded.healer,
      loaded.selectedSessionType,
      event.date,
    );
    emit(
      loaded.copyWith(
        selectedDate: event.date,
        focusedDate: event.date,
        selectedTimeCategory: selection.category,
        selectedTime: selection.time,
        selectedSlotId: selection.slotId,
        clearSlot: selection.slotId == null,
      ),
    );
  }

  void _onSelectTimeCategory(
    SelectTimeCategory event,
    Emitter<HealerDetailState> emit,
  ) {
    if (state is! HealerDetailLoaded) return;
    final loaded = state as HealerDetailLoaded;
    final date = loaded.selectedDate ?? DateTime.now();
    final items = SessionSlotUtils.displaySlotItemsForCategory(
      loaded.healer.rawSlots,
      loaded.selectedSessionType,
      date,
      event.category,
    );
    emit(
      loaded.copyWith(
        selectedTimeCategory: event.category,
        selectedTime: items.isNotEmpty ? items.first.label : null,
        selectedSlotId: items.isNotEmpty ? items.first.id : null,
        clearSlot: items.isEmpty,
      ),
    );
  }

  void _onSelectSlot(SelectSlot event, Emitter<HealerDetailState> emit) {
    if (state is HealerDetailLoaded) {
      emit(
        (state as HealerDetailLoaded).copyWith(
          selectedTime: event.displayTime,
          selectedSlotId: event.slotId,
        ),
      );
    }
  }

  void _onNavigateWeek(NavigateWeek event, Emitter<HealerDetailState> emit) {
    if (state is! HealerDetailLoaded) return;
    final loaded = state as HealerDetailLoaded;
    final current =
        loaded.focusedDate ?? loaded.selectedDate ?? DateTime.now();
    if (event.weeks < 0 && !SessionSlotUtils.canNavigateToPreviousWeek(current)) {
      return;
    }
    final newFocus = current.add(Duration(days: event.weeks * 7));
    final weekDays = SessionSlotUtils.weekDates(newFocus);
    final previous = loaded.selectedDate;
    final dateInWeek = previous != null && !SessionSlotUtils.isPastDate(previous)
        ? weekDays.firstWhere(
            (d) => d.weekday == previous.weekday,
            orElse: () => SessionSlotUtils.preferredDateInWeek(weekDays),
          )
        : SessionSlotUtils.preferredDateInWeek(weekDays);
    if (SessionSlotUtils.isPastDate(dateInWeek)) return;
    final selection = _selectionForDate(
      loaded.healer,
      loaded.selectedSessionType,
      dateInWeek,
    );
    emit(
      loaded.copyWith(
        focusedDate: newFocus,
        selectedDate: dateInWeek,
        selectedTimeCategory: selection.category,
        selectedTime: selection.time,
        selectedSlotId: selection.slotId,
        clearSlot: selection.slotId == null,
      ),
    );
  }

  void _onChangeSessionType(
    ChangeSessionType event,
    Emitter<HealerDetailState> emit,
  ) {
    if (state is! HealerDetailLoaded) return;
    final loaded = state as HealerDetailLoaded;
    final focus = loaded.focusedDate ?? loaded.selectedDate ?? DateTime.now();
    var date = loaded.selectedDate ?? focus;
    if (SessionSlotUtils.isPastDate(date)) {
      date = SessionSlotUtils.dateOnly(DateTime.now());
    }
    final selection = _selectionForDate(
      loaded.healer,
      event.sessionType,
      date,
    );
    emit(
      loaded.copyWith(
        selectedSessionType: event.sessionType,
        selectedDate: date,
        focusedDate: focus,
        selectedTimeCategory: selection.category,
        selectedTime: selection.time,
        selectedSlotId: selection.slotId,
        clearSlot: selection.slotId == null,
      ),
    );
  }

  Future<void> _onLoadHealerDetail(
    LoadHealerDetail event,
    Emitter<HealerDetailState> emit,
  ) async {
    emit(HealerDetailLoading());

    try {
      final healer = await _fetchHealerDetails(event.healerId);
      final sessionType = SessionSlotUtils.defaultSessionType(healer.rawSlots);
      final today = SessionSlotUtils.dateOnly(DateTime.now());
      final selection = _selectionForDate(healer, sessionType, today);

      emit(
        HealerDetailLoaded(
          healer: healer,
          selectedDate: today,
          focusedDate: today,
          selectedTimeCategory: selection.category,
          selectedTime: selection.time,
          selectedSlotId: selection.slotId,
          selectedSessionType: sessionType,
        ),
      );
    } catch (e) {
      emit(HealerDetailError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  ({String? category, String? time, String? slotId}) _selectionForDate(
    HealerModel healer,
    SessionType sessionType,
    DateTime date,
  ) {
    final categories = SessionSlotUtils.availableCategoriesForDate(
      healer.rawSlots,
      sessionType,
      date,
    );
    if (categories.isEmpty) {
      return (category: 'Morning', time: null, slotId: null);
    }
    final category = categories.first;
    final items = SessionSlotUtils.displaySlotItemsForCategory(
      healer.rawSlots,
      sessionType,
      date,
      category,
    );
    if (items.isEmpty) {
      return (category: category, time: null, slotId: null);
    }
    return (
      category: category,
      time: items.first.label,
      slotId: items.first.id,
    );
  }
}

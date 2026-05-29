import 'package:flutter_bloc/flutter_bloc.dart';
import 'healer_detail_event.dart';
import 'healer_detail_state.dart';
import '../data/healer_model.dart';
import '../data/healer_api_service.dart';

class HealerDetailBloc extends Bloc<HealerDetailEvent, HealerDetailState> {
  final HealerApiService _apiService;

  HealerDetailBloc({HealerApiService? apiService})
      : _apiService = apiService ?? HealerApiService(),
        super(HealerDetailInitial()) {
    on<LoadHealerDetail>(_onLoadHealerDetail);

    on<ChangeTab>((event, emit) {
      if (state is HealerDetailLoaded) {
        emit(
          (state as HealerDetailLoaded).copyWith(activeTabIndex: event.index),
        );
      }
    });

    on<SelectDate>((event, emit) {
      if (state is HealerDetailLoaded) {
        emit((state as HealerDetailLoaded).copyWith(
          selectedDate: event.date,
          focusedDate: event.date,
        ));
      }
    });

    on<SelectTimeCategory>((event, emit) {
      if (state is HealerDetailLoaded) {
        emit(
          (state as HealerDetailLoaded).copyWith(
            selectedTimeCategory: event.category,
          ),
        );
      }
    });

    on<SelectTime>((event, emit) {
      if (state is HealerDetailLoaded) {
        emit((state as HealerDetailLoaded).copyWith(selectedTime: event.time));
      }
    });

    on<NavigateWeek>((event, emit) {
      if (state is HealerDetailLoaded) {
        final loaded = state as HealerDetailLoaded;
        final currentFocused =
            loaded.focusedDate ?? loaded.selectedDate ?? DateTime.now();
        emit(
          loaded.copyWith(
            focusedDate: currentFocused.add(Duration(days: event.weeks * 7)),
          ),
        );
      }
    });

    on<ChangeSessionType>((event, emit) {
      if (state is HealerDetailLoaded) {
        final loaded = state as HealerDetailLoaded;
        DateTime defaultDate = DateTime.now();
        if (loaded.healer.rawSlots.isNotEmpty) {
          final dates = loaded.healer.rawSlots
              .where((slot) => slot.sessionType == event.sessionType.value && slot.date.isNotEmpty)
              .map((s) => s.date)
              .toList();
          if (dates.isNotEmpty) {
            dates.sort();
            try {
              defaultDate = DateTime.parse(dates.first);
            } catch (_) {}
          }
        }
        emit(loaded.copyWith(
          selectedSessionType: event.sessionType,
          selectedDate: defaultDate,
          focusedDate: defaultDate,
          selectedTime: null,
        ));
      }
    });
  }

  void _onLoadHealerDetail(
    LoadHealerDetail event,
    Emitter<HealerDetailState> emit,
  ) async {
    emit(HealerDetailLoading());

    try {
      final healer = await _apiService.fetchHealerDetails(event.healerId);
      SessionType defaultSessionType = SessionType.personal;
      DateTime defaultDate = DateTime.now();
      
      if (healer.rawSlots.isNotEmpty) {
        final personalDates = healer.rawSlots
            .where((slot) => slot.sessionType == SessionType.personal.value && slot.date.isNotEmpty)
            .map((s) => s.date)
            .toList();
        if (personalDates.isNotEmpty) {
          personalDates.sort();
          try {
            defaultDate = DateTime.parse(personalDates.first);
          } catch (_) {}
        } else {
          // If no personal slots, check group slots
          final groupDates = healer.rawSlots
              .where((slot) => slot.sessionType == SessionType.group.value && slot.date.isNotEmpty)
              .map((s) => s.date)
              .toList();
          if (groupDates.isNotEmpty) {
            defaultSessionType = SessionType.group;
            groupDates.sort();
            try {
              defaultDate = DateTime.parse(groupDates.first);
            } catch (_) {}
          }
        }
      }

      emit(
        HealerDetailLoaded(
          healer: healer,
          selectedDate: defaultDate,
          focusedDate: defaultDate,
          selectedTimeCategory: 'Morning',
          selectedTime: null, // Let the user select the time slot explicitly
          selectedSessionType: defaultSessionType,
        ),
      );
    } catch (e) {
      emit(HealerDetailError(e.toString()));
    }
  }
}

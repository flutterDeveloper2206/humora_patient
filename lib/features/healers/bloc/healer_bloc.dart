import 'package:flutter_bloc/flutter_bloc.dart';
import 'healer_event.dart';
import 'healer_state.dart';
import '../data/healer_model.dart';

class HealerBloc extends Bloc<HealerEvent, HealerState> {
  HealerBloc() : super(HealerInitial()) {
    on<FetchHealersRequested>(_onFetchHealers);
    on<SearchHealersRequested>(_onSearchHealers);
  }

  void _onFetchHealers(
    FetchHealersRequested event,
    Emitter<HealerState> emit,
  ) async {
    emit(HealerLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      emit(const HealerLoaded(_mockHealers));
    } catch (e) {
      emit(const HealerError("Failed to fetch healers"));
    }
  }

  void _onSearchHealers(
    SearchHealersRequested event,
    Emitter<HealerState> emit,
  ) {
    if (state is HealerLoaded) {
      final filteredHealers = _mockHealers.where((healer) {
        return healer.name.toLowerCase().contains(event.query.toLowerCase());
      }).toList();
      emit(HealerLoaded(filteredHealers));
    }
  }

  static const List<HealerModel> _mockHealers = [
    HealerModel(
      id: '1',
      name: 'Dr. Hannibal Lector',
      imageUrl: 'assets/image/111.png',
      specialization: 'Emotional Healing',
      experienceYears: 5,
      rating: 4.5,
      reviewsCount: 999,
      isAvailableNow: true,
      feesPerMin: 30,
      availability: [
        HealerAvailability(date: 'Mar 11', isAvailable: true),
        HealerAvailability(date: 'Mar 12', isAvailable: false),
        HealerAvailability(date: 'Mar 13', isAvailable: true),
        HealerAvailability(date: 'Mar 14', isAvailable: true),
      ],
    ),
    HealerModel(
      id: '2',
      name: 'Dr. Hina Lector',
      imageUrl: 'assets/image/11.png',
      specialization: 'Emotional Healing',
      experienceYears: 5,
      rating: 4.5,
      reviewsCount: 999,
      isAvailableNow: true,
      feesPerMin: 30,
      availability: [
        HealerAvailability(date: 'Mar 11', isAvailable: true),
        HealerAvailability(date: 'Mar 12', isAvailable: false),
        HealerAvailability(date: 'Mar 13', isAvailable: true),
        HealerAvailability(date: 'Mar 14', isAvailable: true),
      ],
    ),
    HealerModel(
      id: '3',
      name: 'Dr. Lin Lector',
      imageUrl: 'assets/image/33.png',
      specialization: 'Emotional Healing',
      experienceYears: 5,
      rating: 4.5,
      reviewsCount: 999,
      isAvailableNow: true,
      feesPerMin: 30,
      availability: [
        HealerAvailability(date: 'Mar 11', isAvailable: false),
        HealerAvailability(date: 'Mar 12', isAvailable: false),
        HealerAvailability(date: 'Mar 13', isAvailable: true),
        HealerAvailability(date: 'Mar 14', isAvailable: true),
      ],
    ),
  ];
}

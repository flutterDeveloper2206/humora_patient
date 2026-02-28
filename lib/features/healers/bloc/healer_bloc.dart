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
      availability: const [

        HealerAvailability(  date: 'Mar 11',day: 'Mon', periods: ['Morning'], isAvailable: true),
        HealerAvailability(date: 'Mar 12',day: 'Tue', periods: ['Morning', 'Afternoon'], isAvailable: false
        ),
        HealerAvailability(date: 'Mar 13',day: 'Wed', periods: ['Evening'], isAvailable: true),
        HealerAvailability(date: 'Mar 14',day: 'Thu', periods: ['Afternoon'], isAvailable: true),
      ],
    ),
    HealerModel(
      id: '2',
      name: 'Jane Smith',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2',
      specialization: 'Yoga Expert',
      experienceYears: 8,
      rating: 4.8,
      reviewsCount: 32,
      isAvailableNow: true,
      feesPerMin: 40,
      availability: const [
        HealerAvailability(  date: 'Mar 11',day: 'Mon', periods: ['Morning'], isAvailable: true),
        HealerAvailability(date: 'Mar 12',day: 'Tue', periods: ['Morning', 'Afternoon'], isAvailable: false
        ),
        HealerAvailability(date: 'Mar 13',day: 'Wed', periods: ['Evening'], isAvailable: true),
        HealerAvailability(date: 'Mar 14',day: 'Thu', periods: ['Afternoon'], isAvailable: true),
      ],
    ),
    HealerModel(
      id: '3',
      name: 'Michael Chen',
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d',
      specialization: 'Physiotherapist',
      experienceYears: 15,
      rating: 4.9,
      reviewsCount: 124,
      isAvailableNow: false,
      feesPerMin: 60,
      availability: const [
        HealerAvailability(  date: 'Mar 11',day: 'Mon', periods: ['Morning'], isAvailable: true),
        HealerAvailability(date: 'Mar 12',day: 'Tue', periods: ['Morning', 'Afternoon'], isAvailable: false
        ),
        HealerAvailability(date: 'Mar 13',day: 'Wed', periods: ['Evening'], isAvailable: true),
        HealerAvailability(date: 'Mar 14',day: 'Thu', periods: ['Afternoon'], isAvailable: true),
      ],
    ),
  ];
}

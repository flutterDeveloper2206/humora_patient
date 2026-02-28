import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../healers/data/healer_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      // Premium Mock Data based on design
      final mockHealer1 = HealerModel(
        id: '1',
        name: 'Dr. Roshan Patel',
        imageUrl: 'assets/image/doctorprofile.png',
        specialization: 'Astrologer',
        experienceYears: 5,
        rating: 4.9,
        reviewsCount: 3696,
        isAvailableNow: true,
        feesPerMin: 75,
        availability: const [],
      );

      final mockHealer2 = HealerModel(
        id: '2',
        name: 'Dr. Hannibal Lector',
        imageUrl: 'assets/image/111.png',
        specialization: 'Emotional Healing',
        experienceYears: 5,
        rating: 4.5,
        reviewsCount: 999,
        isAvailableNow: true,
        feesPerMin: 50,
        availability: const [],
      );

      emit(
        HomeLoaded(
          continueHealingHealers: [
            mockHealer1,
            mockHealer2,
            mockHealer1,
            mockHealer2,
          ],
          availableHealers: [
            mockHealer2,
            mockHealer1,
            mockHealer2,
            mockHealer1,
            mockHealer2,
          ],
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../healers/data/healer_api_service.dart';
import '../../healers/data/healer_api_models.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HealerApiService _apiService;

  HomeBloc({HealerApiService? apiService}) 
      : _apiService = apiService ?? HealerApiService(),
        super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
  }

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final request = ApprovedHealersRequestModel();
      final healers = await _apiService.fetchApprovedHealers(request);
      
      emit(
        HomeLoaded(
          continueHealingHealers: healers,
          availableHealers: healers,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}

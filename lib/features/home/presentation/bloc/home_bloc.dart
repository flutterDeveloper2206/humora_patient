import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/healers/data/models/healer_api_models.dart';
import 'package:humora_patient/features/healers/data/repositories/healer_repository_impl.dart';
import 'package:humora_patient/features/healers/domain/repositories/healer_repository.dart';
import 'package:humora_patient/features/healers/domain/usecases/fetch_approved_healers_usecase.dart';

import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FetchApprovedHealersUseCase _fetchHealers;

  HomeBloc({HealerRepository? repository})
      : _fetchHealers = FetchApprovedHealersUseCase(
          repository ?? HealerRepositoryImpl(),
        ),
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
      final healers = await _fetchHealers(request);
      
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

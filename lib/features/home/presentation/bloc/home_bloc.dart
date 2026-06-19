import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/healers/data/models/healer_api_models.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
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
    on<RefreshHomeData>(_onRefreshHomeData);
    on<UpdateHealerLiveStatus>(_onUpdateHealerLiveStatus);
  }

  String _cleanError(Object e) =>
      e.toString().replaceAll('Exception: ', '');

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHealers(emit, isRefresh: false);
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHealers(emit, isRefresh: true);
  }

  Future<void> _loadHealers(
    Emitter<HomeState> emit, {
    required bool isRefresh,
  }) async {
    final current = state;
    if (isRefresh && current is HomeLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(HomeLoading());
    }

    try {
      final request = ApprovedHealersRequestModel();
      final healers = await _fetchHealers(request);

      emit(
        HomeLoaded(
          continueHealingHealers: healers,
          availableHealers: healers,
          isRefreshing: false,
        ),
      );
    } catch (e) {
      if (isRefresh && current is HomeLoaded) {
        emit(current.copyWith(isRefreshing: false));
        return;
      }
      emit(HomeError(_cleanError(e)));
    }
  }

  void _onUpdateHealerLiveStatus(
    UpdateHealerLiveStatus event,
    Emitter<HomeState> emit,
  ) {
    final current = state;
    if (current is! HomeLoaded) return;

    HealerModel patch(HealerModel healer) {
      if (healer.id != event.healerId) return healer;
      return healer.withLiveStatus(event.liveStatus);
    }

    emit(
      current.copyWith(
        continueHealingHealers:
            current.continueHealingHealers.map(patch).toList(),
        availableHealers: current.availableHealers.map(patch).toList(),
      ),
    );
  }
}

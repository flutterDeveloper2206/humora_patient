import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/healers/data/models/healer_api_models.dart';
import 'package:humora_patient/features/healers/data/repositories/healer_repository_impl.dart';
import 'package:humora_patient/features/healers/domain/repositories/healer_repository.dart';
import 'package:humora_patient/features/healers/domain/usecases/fetch_approved_healers_usecase.dart';

import 'healer_event.dart';
import 'healer_state.dart';

class HealerBloc extends Bloc<HealerEvent, HealerState> {
  final FetchApprovedHealersUseCase _fetchHealers;

  HealerBloc({HealerRepository? repository})
      : _fetchHealers = FetchApprovedHealersUseCase(
          repository ?? HealerRepositoryImpl(),
        ),
        super(HealerInitial()) {
    on<FetchHealersRequested>(_onFetchHealers);
    on<SearchHealersRequested>(_onSearchHealers);
  }

  void _onFetchHealers(
    FetchHealersRequested event,
    Emitter<HealerState> emit,
  ) async {
    emit(HealerLoading());
    try {
      final request = ApprovedHealersRequestModel();
      final healers = await _fetchHealers(request);
      emit(HealerLoaded(healers));
    } catch (e) {
      emit(HealerError("Failed to fetch healers: $e"));
    }
  }

  void _onSearchHealers(
    SearchHealersRequested event,
    Emitter<HealerState> emit,
  ) async {
    emit(HealerLoading());
    try {
      final request = ApprovedHealersRequestModel(searchValue: event.query);
      final healers = await _fetchHealers(request);
      emit(HealerLoaded(healers));
    } catch (e) {
      emit(HealerError("Failed to search healers: $e"));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'healer_event.dart';
import 'healer_state.dart';
import '../data/healer_api_service.dart';
import '../data/healer_api_models.dart';

class HealerBloc extends Bloc<HealerEvent, HealerState> {
  final HealerApiService _apiService;

  HealerBloc({HealerApiService? apiService}) 
      : _apiService = apiService ?? HealerApiService(),
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
      final healers = await _apiService.fetchApprovedHealers(request);
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
      final healers = await _apiService.fetchApprovedHealers(request);
      emit(HealerLoaded(healers));
    } catch (e) {
      emit(HealerError("Failed to search healers: $e"));
    }
  }
}

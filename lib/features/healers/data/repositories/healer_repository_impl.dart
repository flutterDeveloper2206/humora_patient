import '../../domain/repositories/healer_repository.dart';
import '../datasource/healer_api_service.dart';
import '../models/healer_api_models.dart';
import '../models/healer_model.dart';

class HealerRepositoryImpl implements HealerRepository {
  final HealerApiService _apiService;

  HealerRepositoryImpl({HealerApiService? apiService})
      : _apiService = apiService ?? HealerApiService();

  @override
  Future<List<HealerModel>> fetchApprovedHealers(
    ApprovedHealersRequestModel request,
  ) =>
      _apiService.fetchApprovedHealers(request);

  @override
  Future<HealerModel> fetchHealerDetails(String healerId) =>
      _apiService.fetchHealerDetails(healerId);
}

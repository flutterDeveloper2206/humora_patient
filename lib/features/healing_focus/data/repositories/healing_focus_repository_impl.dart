import '../../domain/repositories/healing_focus_repository.dart';
import '../datasource/healing_focus_api_service.dart';
import '../models/healing_focus_models.dart';

class HealingFocusRepositoryImpl implements HealingFocusRepository {
  final HealingFocusApiService _apiService;

  HealingFocusRepositoryImpl({HealingFocusApiService? apiService})
      : _apiService = apiService ?? HealingFocusApiService();

  @override
  Future<CategorySpecializationsResponse> getCategorySpecializations(
    String token,
  ) =>
      _apiService.getCategorySpecializations(token);

  @override
  Future<SavePreferenceResponse> savePreference(
    SavePreferenceRequest request,
    String token,
    String patientId,
  ) =>
      _apiService.savePreference(request, token, patientId);
}

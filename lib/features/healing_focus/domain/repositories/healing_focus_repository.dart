import '../../data/models/healing_focus_models.dart';

abstract class HealingFocusRepository {
  Future<CategorySpecializationsResponse> getCategorySpecializations(
    String token,
  );
  Future<SavePreferenceResponse> savePreference(
    SavePreferenceRequest request,
    String token,
    String patientId,
  );
}

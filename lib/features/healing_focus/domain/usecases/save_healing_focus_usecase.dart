import '../repositories/healing_focus_repository.dart';
import '../../data/models/healing_focus_models.dart';

class SaveHealingFocusUseCase {
  final HealingFocusRepository _repository;

  SaveHealingFocusUseCase(this._repository);

  Future<SavePreferenceResponse> call(
    SavePreferenceRequest request,
    String token,
    String patientId,
  ) =>
      _repository.savePreference(request, token, patientId);
}

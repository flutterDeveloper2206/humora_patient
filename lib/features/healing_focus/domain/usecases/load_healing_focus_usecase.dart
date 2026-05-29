import '../repositories/healing_focus_repository.dart';
import '../../data/models/healing_focus_models.dart';

class LoadHealingFocusUseCase {
  final HealingFocusRepository _repository;

  LoadHealingFocusUseCase(this._repository);

  Future<CategorySpecializationsResponse> call(String token) =>
      _repository.getCategorySpecializations(token);
}

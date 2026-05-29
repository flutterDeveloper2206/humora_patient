import '../repositories/healer_repository.dart';
import '../../data/models/healer_api_models.dart';
import '../../data/models/healer_model.dart';

class FetchApprovedHealersUseCase {
  final HealerRepository _repository;

  FetchApprovedHealersUseCase(this._repository);

  Future<List<HealerModel>> call(ApprovedHealersRequestModel request) =>
      _repository.fetchApprovedHealers(request);
}

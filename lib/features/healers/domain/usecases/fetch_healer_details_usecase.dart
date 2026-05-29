import '../repositories/healer_repository.dart';
import '../../data/models/healer_model.dart';

class FetchHealerDetailsUseCase {
  final HealerRepository _repository;

  FetchHealerDetailsUseCase(this._repository);

  Future<HealerModel> call(String healerId) =>
      _repository.fetchHealerDetails(healerId);
}

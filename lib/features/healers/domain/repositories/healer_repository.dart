import '../../data/models/healer_api_models.dart';
import '../../data/models/healer_model.dart';

abstract class HealerRepository {
  Future<List<HealerModel>> fetchApprovedHealers(
    ApprovedHealersRequestModel request,
  );
  Future<HealerModel> fetchHealerDetails(String healerId);
}

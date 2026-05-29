import '../repositories/auth_repository.dart';
import '../../data/models/profile_models.dart';

class SaveProfileUseCase {
  final AuthRepository _repository;

  SaveProfileUseCase(this._repository);

  Future<SaveProfileResponse> call(
    SaveProfileRequest request,
    String token,
    String patientId,
  ) =>
      _repository.saveProfile(request, token, patientId);
}

import '../repositories/wallet_repository.dart';
import '../../data/models/wallet_models.dart';

class CreatePaymentIntentUseCase {
  final WalletRepository _repository;

  CreatePaymentIntentUseCase(this._repository);

  Future<PaymentIntentResponse> call(PaymentIntentRequest request) =>
      _repository.createPaymentIntent(request);
}

import '../../data/models/wallet_models.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../repositories/wallet_repository.dart';

class GetWalletBalanceUseCase {
  final WalletRepository _repository;

  GetWalletBalanceUseCase({WalletRepository? repository})
      : _repository = repository ?? WalletRepositoryImpl();

  Future<WalletBalanceResponse> call() => _repository.getBalance();
}

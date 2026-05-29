import '../repositories/wallet_repository.dart';
import '../../data/models/wallet_models.dart';

class LoadWalletUseCase {
  final WalletRepository _repository;

  LoadWalletUseCase(this._repository);

  Future<({WalletBalanceResponse balance, WalletTransactionsResponse transactions})>
      call({int take = 20}) async {
    final balance = await _repository.getBalance();
    final transactions = await _repository.getTransactions(skip: 0, take: take);
    return (balance: balance, transactions: transactions);
  }
}

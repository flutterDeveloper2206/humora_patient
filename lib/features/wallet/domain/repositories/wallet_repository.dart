import '../../data/models/wallet_models.dart';

abstract class WalletRepository {
  Future<PaymentIntentResponse> createPaymentIntent(
    PaymentIntentRequest request,
  );
  Future<WalletBalanceResponse> getBalance();
  Future<WalletTransactionsResponse> getTransactions({
    int skip = 0,
    int take = 20,
    int? transactionType,
    int? status,
    int? source,
    String? from,
    String? to,
    String? search,
  });
}

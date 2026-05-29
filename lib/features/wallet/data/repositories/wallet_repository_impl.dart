import '../../domain/repositories/wallet_repository.dart';
import '../datasource/wallet_api_service.dart';
import '../models/wallet_models.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletApiService _apiService;

  WalletRepositoryImpl({WalletApiService? apiService})
      : _apiService = apiService ?? WalletApiService();

  @override
  Future<PaymentIntentResponse> createPaymentIntent(
    PaymentIntentRequest request,
  ) =>
      _apiService.createPaymentIntent(request);

  @override
  Future<WalletBalanceResponse> getBalance() => _apiService.getBalance();

  @override
  Future<WalletTransactionsResponse> getTransactions({
    int skip = 0,
    int take = 20,
    int? transactionType,
    int? status,
    int? source,
    String? from,
    String? to,
    String? search,
  }) =>
      _apiService.getTransactions(
        skip: skip,
        take: take,
        transactionType: transactionType,
        status: status,
        source: source,
        from: from,
        to: to,
        search: search,
      );
}

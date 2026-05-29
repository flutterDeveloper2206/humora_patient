import 'package:equatable/equatable.dart';

import 'package:humora_patient/features/wallet/data/models/wallet_models.dart';

class WalletState extends Equatable {
  final WalletBalanceResponse balance;
  final List<WalletTransactionItem> transactions;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isTopUpInProgress;
  final bool isRefreshingAfterPayment;
  final String? error;
  final int skip;
  final int totalCount;
  final bool hasMore;
  final String? topUpSuccessMessage;

  const WalletState({
    this.balance = WalletBalanceResponse.empty,
    this.transactions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isTopUpInProgress = false,
    this.isRefreshingAfterPayment = false,
    this.error,
    this.skip = 0,
    this.totalCount = 0,
    this.hasMore = true,
    this.topUpSuccessMessage,
  });

  static const int pageSize = 20;

  WalletState copyWith({
    WalletBalanceResponse? balance,
    List<WalletTransactionItem>? transactions,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isTopUpInProgress,
    bool? isRefreshingAfterPayment,
    String? error,
    bool clearError = false,
    int? skip,
    int? totalCount,
    bool? hasMore,
    String? topUpSuccessMessage,
    bool clearTopUpSuccess = false,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isTopUpInProgress: isTopUpInProgress ?? this.isTopUpInProgress,
      isRefreshingAfterPayment:
          isRefreshingAfterPayment ?? this.isRefreshingAfterPayment,
      error: clearError ? null : (error ?? this.error),
      skip: skip ?? this.skip,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      topUpSuccessMessage: clearTopUpSuccess
          ? null
          : (topUpSuccessMessage ?? this.topUpSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        balance,
        transactions,
        isLoading,
        isLoadingMore,
        isTopUpInProgress,
        isRefreshingAfterPayment,
        error,
        skip,
        totalCount,
        hasMore,
        topUpSuccessMessage,
      ];
}

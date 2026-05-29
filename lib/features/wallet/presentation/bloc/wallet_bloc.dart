import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:humora_patient/core/constants/stripe_config.dart';
import 'package:humora_patient/core/utils/session_manager.dart';
import 'package:humora_patient/features/wallet/data/models/wallet_models.dart';
import 'package:humora_patient/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:humora_patient/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:humora_patient/features/wallet/domain/usecases/create_payment_intent_usecase.dart';
import 'package:uuid/uuid.dart';

import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _repository;
  final CreatePaymentIntentUseCase _createPaymentIntent;
  static const _uuid = Uuid();

  WalletBloc({WalletRepository? repository})
      : _repository = repository ?? WalletRepositoryImpl(),
        _createPaymentIntent = CreatePaymentIntentUseCase(
          repository ?? WalletRepositoryImpl(),
        ),
        super(const WalletState()) {
    on<WalletLoadRequested>(_onLoad);
    on<WalletLoadMoreTransactions>(_onLoadMore);
    on<WalletTopUpRequested>(_onTopUp);
    on<WalletRefreshAfterPayment>(_onRefreshAfterPayment);
  }

  Future<void> _onLoad(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearTopUpSuccess: true));
    try {
      final balance = await _repository.getBalance();
      final txResponse = await _repository.getTransactions(
        skip: 0,
        take: WalletState.pageSize,
      );
      final hasMore = _computeHasMore(txResponse);

      emit(state.copyWith(
        isLoading: false,
        balance: balance,
        transactions: txResponse.items,
        skip: txResponse.items.length,
        totalCount: txResponse.totalCount,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: _cleanError(e),
      ));
    }
  }

  Future<void> _onLoadMore(
    WalletLoadMoreTransactions event,
    Emitter<WalletState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final txResponse = await _repository.getTransactions(
        skip: state.skip,
        take: WalletState.pageSize,
      );
      final merged = [...state.transactions, ...txResponse.items];
      final newSkip = state.skip + txResponse.items.length;
      final hasMore = txResponse.items.length < WalletState.pageSize
          ? false
          : newSkip < txResponse.totalCount;

      emit(state.copyWith(
        isLoadingMore: false,
        transactions: merged,
        skip: newSkip,
        totalCount: txResponse.totalCount,
        hasMore: hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingMore: false,
        error: _cleanError(e),
      ));
    }
  }

  Future<void> _onTopUp(
    WalletTopUpRequested event,
    Emitter<WalletState> emit,
  ) async {
    if (event.amount < StripeConfig.minimumTopUpAmount) {
      emit(state.copyWith(
        error:
            'Minimum top-up is ${state.balance.displaySymbol}${StripeConfig.minimumTopUpAmount.toStringAsFixed(0)}',
      ));
      return;
    }

    emit(state.copyWith(
      isTopUpInProgress: true,
      clearError: true,
      clearTopUpSuccess: true,
    ));

    try {
      final idempotencyKey = 'topup_${_uuid.v4()}';
      final savedCurrencyId = await SessionManager.getCurrencyId();
      final currencyId = state.balance.currencyId ??
          savedCurrencyId ??
          StripeConfig.defaultCurrencyId;

      final intent = await _createPaymentIntent(
        PaymentIntentRequest(
          amount: event.amount,
          currencyId: currencyId,
          description: 'Top-up via mobile app',
          idempotencyKey: idempotencyKey,
        ),
      );

      if (intent.clientSecret.isEmpty) {
        throw Exception('Payment could not be started. Please try again.');
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret,
          merchantDisplayName: 'Humora Patient',
          returnURL: StripeConfig.returnUrl,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      emit(state.copyWith(isTopUpInProgress: false, isRefreshingAfterPayment: true));

      await Future.delayed(const Duration(milliseconds: 1500));

      add(const WalletRefreshAfterPayment());
    } on StripeException catch (e) {
      final code = e.error.code;
      if (code == FailureCode.Canceled) {
        emit(state.copyWith(isTopUpInProgress: false));
        return;
      }
      emit(state.copyWith(
        isTopUpInProgress: false,
        error: e.error.localizedMessage ?? e.error.message ?? 'Payment failed',
      ));
    } catch (e) {
      emit(state.copyWith(
        isTopUpInProgress: false,
        error: _cleanError(e),
      ));
    }
  }

  Future<void> _onRefreshAfterPayment(
    WalletRefreshAfterPayment event,
    Emitter<WalletState> emit,
  ) async {
    emit(state.copyWith(isRefreshingAfterPayment: true, clearError: true));
    try {
      final balance = await _repository.getBalance();
      final txResponse = await _repository.getTransactions(
        skip: 0,
        take: WalletState.pageSize,
      );
      final hasMore = _computeHasMore(txResponse);

      emit(state.copyWith(
        isRefreshingAfterPayment: false,
        balance: balance,
        transactions: txResponse.items,
        skip: txResponse.items.length,
        totalCount: txResponse.totalCount,
        hasMore: hasMore,
        topUpSuccessMessage: 'Money added successfully!',
      ));
    } catch (e) {
      emit(state.copyWith(
        isRefreshingAfterPayment: false,
        error: _cleanError(e),
      ));
    }
  }

  bool _computeHasMore(WalletTransactionsResponse response) {
    if (response.items.length < WalletState.pageSize) return false;
    return response.items.length < response.totalCount;
  }

  String _cleanError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}

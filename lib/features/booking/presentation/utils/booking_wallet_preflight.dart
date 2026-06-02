import 'package:flutter/material.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../domain/booking_hold_calculator.dart';
import '../widgets/insufficient_wallet_dialog.dart';
import '../../../healers/data/models/healer_api_models.dart';
import '../../../healers/data/models/healer_model.dart';
import '../../../wallet/domain/usecases/get_wallet_balance_usecase.dart';

/// Phase 2 — wallet balance check before POST /booking.
class BookingWalletPreflight {
  static final _getBalance = GetWalletBalanceUseCase();

  static Future<bool> ensureCanAfford({
    required BuildContext context,
    required SessionType sessionType,
    required List<SessionPricingItem> sessionPricing,
    required List<LiveCounsellingItem> liveCounselling,
    int fallbackPricePerMinute = 0,
    int? consultationType,
  }) async {
    final requiredHold = BookingHoldCalculator.requiredHold(
      sessionType: sessionType,
      sessionPricing: sessionPricing,
      liveCounselling: liveCounselling,
      fallbackPricePerMinute: fallbackPricePerMinute,
      consultationType: consultationType,
    );

    _showLoading(context);

    try {
      final balance = await _getBalance();
      if (!context.mounted) return false;

      Navigator.of(context, rootNavigator: true).pop();

      final available = balance.availableBalance;
      if (available >= requiredHold) {
        return true;
      }

      final sessionLabel = switch (sessionType) {
        SessionType.live => 'live session',
        SessionType.personal => 'personal session',
        SessionType.group => 'group session',
      };

      await InsufficientWalletDialog.show(
        context: context,
        message:
            'Your wallet balance is not enough to book this $sessionLabel. '
            'Please add money to your wallet and try again.',
        requiredAmount: requiredHold,
        availableAmount: available,
      );
      return false;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        CommonFlushbar.error(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
      return false;
    }
  }

  static void _showLoading(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}

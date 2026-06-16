import 'package:flutter/material.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../booking/presentation/widgets/insufficient_wallet_dialog.dart';
import '../../../healers/data/models/healer_api_models.dart';
import '../../../wallet/domain/usecases/get_wallet_balance_usecase.dart';

/// Wallet check before POST /live/request (doc: min 5 minutes balance hold).
class LiveWalletPreflight {
  LiveWalletPreflight._();

  static const int minMinutes = 5;

  static final _getBalance = GetWalletBalanceUseCase();

  static Future<bool> ensureCanAfford({
    required BuildContext context,
    required List<LiveCounsellingItem> liveCounselling,
    required int consultationType,
    int fallbackPricePerMinute = 0,
  }) async {
    final pricePerMinute = _pricePerMinute(
      liveCounselling,
      consultationType: consultationType,
      fallback: fallbackPricePerMinute,
    );
    if (pricePerMinute <= 0) return true;

    final requiredHold = (minMinutes * pricePerMinute).toDouble();

    _showLoading(context);

    try {
      final balance = await _getBalance();
      if (!context.mounted) return false;

      Navigator.of(context, rootNavigator: true).pop();

      if (balance.availableBalance >= requiredHold) {
        return true;
      }

      await InsufficientWalletDialog.show(
        context: context,
        message:
            'Your wallet needs at least $minMinutes minutes of live session '
            'time (₹${requiredHold.toStringAsFixed(0)}). Please add money and '
            'try again.',
        requiredAmount: requiredHold,
        availableAmount: balance.availableBalance,
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

  static int _pricePerMinute(
    List<LiveCounsellingItem> liveCounselling, {
    required int consultationType,
    required int fallback,
  }) {
    for (final item in liveCounselling) {
      if (item.consultationType == consultationType) {
        return item.pricePerMinute;
      }
    }
    if (liveCounselling.isNotEmpty) {
      return liveCounselling.first.pricePerMinute;
    }
    return fallback;
  }

  static void _showLoading(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}

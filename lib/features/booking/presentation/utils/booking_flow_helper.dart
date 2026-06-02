import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../data/datasource/booking_api_service.dart';
import '../../data/models/booking_models.dart';
import '../../domain/usecases/create_booking_usecase.dart';
import '../widgets/insufficient_wallet_dialog.dart';

class BookingFlowHelper {
  static final _useCase = CreateBookingUseCase();

  static bool canBook({
    required String? slotId,
    required String? selectedTime,
  }) {
    return slotId != null &&
        slotId.isNotEmpty &&
        selectedTime != null &&
        selectedTime.isNotEmpty;
  }

  static Future<CreateBookingResponse?> submit({
    required BuildContext context,
    required String healerId,
    required String slotId,
    required String bookingDate,
    int? consultationType,
    VoidCallback? onRefreshSlots,
    String? idempotencyKey,
    bool isRetry = false,
  }) async {
    final key = idempotencyKey ?? 'booking_${const Uuid().v4()}';

    if (!isRetry) {
      _showLoading(context);
    }

    try {
      final response = await _useCase.call(
        healerId: healerId,
        slotId: slotId,
        bookingDate: bookingDate,
        idempotencyKey: key,
        consultationType: consultationType,
      );

      if (context.mounted && !isRetry) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (context.mounted) {
        _navigateToBookingSuccess(context, response);
      }
      return response;
    } on BookingApiException catch (e) {
      if (context.mounted && !isRetry) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (e.isIdempotencyInProgress && context.mounted) {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (!context.mounted) return null;
        return submit(
          context: context,
          healerId: healerId,
          slotId: slotId,
          bookingDate: bookingDate,
          consultationType: consultationType,
          onRefreshSlots: onRefreshSlots,
          idempotencyKey: key,
          isRetry: true,
        );
      }

      if (context.mounted) {
        _handleError(context, e, onRefreshSlots: onRefreshSlots);
      }
      return null;
    } catch (e) {
      if (context.mounted && !isRetry) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (context.mounted) {
        CommonFlushbar.error(
          context,
          e.toString().replaceAll('Exception: ', ''),
        );
      }
      return null;
    }
  }

  static void _showLoading(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  static void _navigateToBookingSuccess(
    BuildContext context,
    CreateBookingResponse response,
  ) {
    context.push(
      '/success',
      extra: {
        'imagePath': 'assets/image/waitforwhile.png',
        'title': 'Booking Confirmed',
        'subtitle':
            'Reference: ${response.bookingReference}\n₹${response.holdAmount} held from your wallet until the session completes.',
        'buttonText': 'View My Sessions',
        'onButtonPressed': () {
          context.go('/my-sessions');
        },
      },
    );
  }

  static void _handleError(
    BuildContext context,
    BookingApiException e, {
    VoidCallback? onRefreshSlots,
  }) {
    final message = e.message;

    if (e.isInsufficientBalance) {
      InsufficientWalletDialog.show(
        context: context,
        message: message.isNotEmpty
            ? message
            : 'Your wallet balance is not enough to complete this booking. '
                'Please add money to your wallet and try again.',
      );
      return;
    }

    switch (e.statusCode) {
      case 400:
        CommonFlushbar.error(context, message);
        break;
      case 404:
        if (message.toLowerCase().contains('profile')) {
          CommonFlushbar.error(context, message);
          context.push('/finish-signup');
        } else {
          CommonFlushbar.error(context, message);
          onRefreshSlots?.call();
        }
        break;
      case 409:
        onRefreshSlots?.call();
        CommonFlushbar.error(context, message);
        break;
      default:
        CommonFlushbar.error(context, message);
    }
  }
}

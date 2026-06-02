import 'package:humora_patient/features/healers/data/models/healer_api_models.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';

/// Wallet hold amount before POST /booking.
class BookingHoldCalculator {
  static double requiredHold({
    required SessionType sessionType,
    required List<SessionPricingItem> sessionPricing,
    required List<LiveCounsellingItem> liveCounselling,
    int fallbackPricePerMinute = 0,
    int? consultationType,
  }) {
    switch (sessionType) {
      case SessionType.live:
        final minMinutes = _minSessionMinutes(sessionPricing);
        final pricePerMinute = _pricePerMinute(
          liveCounselling,
          consultationType: consultationType,
          fallback: fallbackPricePerMinute,
        );
        return (minMinutes * pricePerMinute).toDouble();
      case SessionType.personal:
        return _fixedPrice(sessionPricing, SessionType.personal).toDouble();
      case SessionType.group:
        return _fixedPrice(sessionPricing, SessionType.group).toDouble();
    }
  }

  static int _minSessionMinutes(List<SessionPricingItem> sessionPricing) {
    for (final item in sessionPricing) {
      if (item.sessionType == SessionType.live.value &&
          item.durationMinutes > 0) {
        return item.durationMinutes;
      }
    }
    return 30;
  }

  static int _fixedPrice(
    List<SessionPricingItem> sessionPricing,
    SessionType type,
  ) {
    for (final item in sessionPricing) {
      if (item.sessionType == type.value) {
        return item.price;
      }
    }
    return 0;
  }

  static int _pricePerMinute(
    List<LiveCounsellingItem> liveCounselling, {
    int? consultationType,
    required int fallback,
  }) {
    if (consultationType != null) {
      for (final item in liveCounselling) {
        if (item.consultationType == consultationType) {
          return item.pricePerMinute;
        }
      }
    }
    if (liveCounselling.isEmpty) {
      return fallback > 0 ? fallback : 0;
    }
    return liveCounselling
        .map((c) => c.pricePerMinute)
        .reduce((a, b) => a < b ? a : b);
  }
}

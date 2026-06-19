import 'package:humora_patient/features/healers/data/models/healer_api_models.dart';

class CreateBookingRequest {
  final String healerId;
  final String slotId;
  final String bookingDate;
  final int? consultationType;
  final String idempotencyKey;

  const CreateBookingRequest({
    required this.healerId,
    required this.slotId,
    required this.bookingDate,
    required this.idempotencyKey,
    this.consultationType,
  });

  Map<String, dynamic> toJson() => {
        'healerId': healerId,
        'slotId': slotId,
        'bookingDate': bookingDate,
        'consultationType': consultationType,
        'idempotencyKey': idempotencyKey,
      };
}

class CreateBookingResponse {
  final String bookingId;
  final String bookingReference;
  final int status;
  final int holdAmount;
  final String scheduledStartAt;

  const CreateBookingResponse({
    required this.bookingId,
    required this.bookingReference,
    required this.status,
    required this.holdAmount,
    required this.scheduledStartAt,
  });

  factory CreateBookingResponse.fromJson(Map<String, dynamic> json) {
    return CreateBookingResponse(
      bookingId: json['bookingId']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      status: (json['status'] as num?)?.toInt() ?? 0,
      holdAmount: (json['holdAmount'] as num?)?.toInt() ?? 0,
      scheduledStartAt: json['scheduledStartAt']?.toString() ?? '',
    );
  }
}

class CancelBookingRequest {
  final String bookingId;
  final String reason;

  const CancelBookingRequest({
    required this.bookingId,
    required this.reason,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'reason': reason,
      };
}

class CancelBookingResponse {
  final String message;

  const CancelBookingResponse({required this.message});

  factory CancelBookingResponse.fromJson(Map<String, dynamic> json) {
    return CancelBookingResponse(
      message: json['message']?.toString() ?? 'Booking cancelled successfully.',
    );
  }
}

class BookingFlowArgs {
  final String healerId;
  final String slotId;
  final String bookingDate;
  final int sessionType;
  final List<SessionPricingItem> sessionPricing;
  final List<LiveCounsellingItem> liveCounselling;
  final int fallbackPricePerMinute;

  const BookingFlowArgs({
    required this.healerId,
    required this.slotId,
    required this.bookingDate,
    this.sessionType = 1,
    this.sessionPricing = const [],
    this.liveCounselling = const [],
    this.fallbackPricePerMinute = 0,
  });
}

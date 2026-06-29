import 'package:equatable/equatable.dart';

import 'call_push_type.dart';

/// Parsed incoming-call push payload (healer → patient ring).
class IncomingCallPayload extends Equatable {
  final String callId;
  final String bookingId;
  final String? requestId;
  final String callerId;
  final String callerName;
  final String? callerPhoto;
  final int consultationType;
  final String callType;
  final String source;
  final DateTime? expiresAt;
  final int ttlSeconds;

  const IncomingCallPayload({
    required this.callId,
    required this.bookingId,
    this.requestId,
    required this.callerId,
    required this.callerName,
    this.callerPhoto,
    required this.consultationType,
    required this.callType,
    required this.source,
    this.expiresAt,
    this.ttlSeconds = 60,
  });

  bool get isLive => source.toLowerCase() == 'live';
  bool get isBooking => source.toLowerCase() == 'booking';
  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) return false;
    return DateTime.now().toUtc().isAfter(expiry.toUtc());
  }

  bool get isAudio => consultationType == 1;
  bool get isVideo => consultationType == 2;
  bool get isChat => consultationType == 0;

  String get titleLabel {
    if (isVideo) return 'Incoming Video Call';
    if (isAudio) return 'Incoming Audio Call';
    return 'Incoming Chat Request';
  }

  String get subtitleLabel {
    final kind = isLive ? 'Live session' : 'Scheduled session';
    return '$kind · ${isVideo ? 'Video' : isAudio ? 'Audio' : 'Chat'}';
  }

  factory IncomingCallPayload.fromMap(Map<String, dynamic> map) {
    final callType = map['callType']?.toString().toLowerCase() ?? 'audio';
    return IncomingCallPayload(
      callId: map['callId']?.toString() ?? '',
      bookingId: map['bookingId']?.toString() ?? '',
      requestId: _optionalString(map['requestId']),
      callerId: map['callerId']?.toString() ?? '',
      callerName: map['callerName']?.toString() ?? 'Healer',
      callerPhoto: _optionalString(map['callerPhoto'] ?? map['callerImageUrl']),
      consultationType: _consultationTypeFromCallType(callType, map),
      callType: callType,
      source: map['source']?.toString().toLowerCase() ?? 'live',
      expiresAt: DateTime.tryParse(map['expiresAt']?.toString() ?? ''),
      ttlSeconds: int.tryParse(map['ttlSeconds']?.toString() ?? '') ?? 60,
    );
  }

  static IncomingCallPayload? tryFromNotificationData(
    Map<String, dynamic> data, {
    String? type,
  }) {
    final eventType = type ?? data['type']?.toString();
    if (eventType != CallPushType.incomingCall) return null;
    final payload = IncomingCallPayload.fromMap(data);
    if (payload.callId.isEmpty || payload.bookingId.isEmpty) return null;
    return payload;
  }

  static int _consultationTypeFromCallType(
    String callType,
    Map<String, dynamic> map,
  ) {
    final explicit = int.tryParse(map['consultationType']?.toString() ?? '');
    if (explicit != null && explicit >= 0 && explicit <= 2) return explicit;
    switch (callType) {
      case 'video':
        return 2;
      case 'audio':
        return 1;
      case 'chat':
        return 0;
      default:
        return 1;
    }
  }

  static String? _optionalString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  @override
  List<Object?> get props => [
        callId,
        bookingId,
        requestId,
        callerId,
        callerName,
        callerPhoto,
        consultationType,
        source,
        expiresAt,
      ];
}

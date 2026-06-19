import 'package:equatable/equatable.dart';

/// Doc §3 — integer sent in POST /live/end and SessionEnded.endReason.
class SessionEndReason {
  static const int patientEnded = 1;
  static const int healerEnded = 2;
  static const int walletExhausted = 3;
  static const int networkDisconnected = 4;
  static const int systemTerminated = 5;

  static String label(dynamic value) {
    final code = _asInt(value);
    switch (code) {
      case patientEnded:
        return 'You ended the session';
      case healerEnded:
        return 'Healer ended the session';
      case walletExhausted:
        return 'Wallet exhausted';
      case networkDisconnected:
        return 'Network disconnected';
      case systemTerminated:
        return 'Session terminated';
      default:
        if (value == null) return '';
        return value.toString();
    }
  }

  static int? _asInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'patientended':
          return patientEnded;
        case 'healerended':
          return healerEnded;
        case 'walletexhausted':
          return walletExhausted;
        case 'networkdisconnected':
          return networkDisconnected;
        case 'systemterminated':
          return systemTerminated;
      }
      return int.tryParse(value);
    }
    return null;
  }
}

/// Doc §3 — GET /live/request/{id} status field.
class LiveRequestStatus {
  static const int pending = 1;
  static const int accepted = 2;
  static const int rejected = 3;
  static const int expired = 4;
  static const int cancelled = 5;

  static int? parseCode(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'pending':
          return pending;
        case 'accepted':
          return accepted;
        case 'rejected':
          return rejected;
        case 'expired':
          return expired;
        case 'cancelled':
        case 'canceled':
          return cancelled;
      }
      return int.tryParse(value);
    }
    return null;
  }

  static bool isAccepted(dynamic value) => parseCode(value) == accepted;

  static bool isRejected(dynamic value) => parseCode(value) == rejected;

  static bool isExpired(dynamic value) => parseCode(value) == expired;

  static bool isCancelled(dynamic value) => parseCode(value) == cancelled;
}

/// Doc §3 — HealerPresenceStatus on approved-healers and HealerStatusChanged.
class HealerPresenceStatus {
  static const int offline = 0;
  static const int online = 1;
  static const int busy = 2;

  static String label(dynamic value) {
    if (value == null) return '';
    if (value is num) {
      switch (value.toInt()) {
        case online:
          return 'Online';
        case busy:
          return 'Busy';
        default:
          return 'Offline';
      }
    }
    final text = value.toString();
    if (text.isEmpty) return text;
    if (text == '0') return 'Offline';
    if (text == '1') return 'Online';
    if (text == '2') return 'Busy';
    return text;
  }
}

class LiveRequestBody extends Equatable {
  final String healerId;
  final int consultationType;

  const LiveRequestBody({
    required this.healerId,
    required this.consultationType,
  });

  Map<String, dynamic> toJson() => {
        'healerId': healerId,
        'consultationType': consultationType,
      };

  @override
  List<Object?> get props => [healerId, consultationType];
}

class LiveRequestResponse extends Equatable {
  final String requestId;
  final String waitlistId;
  final String healerId;
  final String healerName;
  final int consultationType;
  final String status;
  final DateTime? requestedAt;
  final DateTime? expiresAt;
  final String? bookingId;
  final String? bookingReference;
  final int position;
  final int? estimatedWaitMinutes;
  final DateTime? joinedAt;

  const LiveRequestResponse({
    required this.requestId,
    this.waitlistId = '',
    required this.healerId,
    required this.healerName,
    required this.consultationType,
    required this.status,
    this.requestedAt,
    this.expiresAt,
    this.bookingId,
    this.bookingReference,
    this.position = 0,
    this.estimatedWaitMinutes,
    this.joinedAt,
  });

  bool get isQueued =>
      waitlistId.isNotEmpty || status.toLowerCase() == 'queued';

  factory LiveRequestResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return LiveRequestResponse(
      requestId: data['requestId']?.toString() ?? '',
      waitlistId: data['waitlistId']?.toString() ?? '',
      healerId: data['healerId']?.toString() ?? '',
      healerName: data['healerName']?.toString() ?? 'Healer',
      consultationType: parseLiveConsultationType(data['consultationType']),
      status: _liveRequestStatusLabel(data['status']),
      requestedAt: _parseDate(data['requestedAt']),
      expiresAt: _parseDate(data['expiresAt']),
      bookingId: data['bookingId']?.toString(),
      bookingReference: data['bookingReference']?.toString(),
      position: (data['position'] as num?)?.toInt() ?? 0,
      estimatedWaitMinutes: (data['estimatedWaitMinutes'] as num?)?.toInt(),
      joinedAt: _parseDate(data['joinedAt']),
    );
  }

  @override
  List<Object?> get props =>
      [requestId, waitlistId, healerId, healerName, consultationType, status, expiresAt, position];
}

class WaitlistYourTurnPayload extends Equatable {
  final String waitlistId;
  final String healerId;
  final int consultationType;
  final DateTime? expiresAt;

  const WaitlistYourTurnPayload({
    required this.waitlistId,
    required this.healerId,
    required this.consultationType,
    this.expiresAt,
  });

  factory WaitlistYourTurnPayload.fromJson(Map<String, dynamic> json) {
    return WaitlistYourTurnPayload(
      waitlistId: json['waitlistId']?.toString() ?? '',
      healerId: json['healerId']?.toString() ?? '',
      consultationType: parseLiveConsultationType(json['consultationType']),
      expiresAt: _parseDate(json['expiresAt']),
    );
  }

  @override
  List<Object?> get props => [waitlistId, healerId, consultationType, expiresAt];
}

class WaitlistTurnExpiredPayload extends Equatable {
  final String waitlistId;
  final String healerId;

  const WaitlistTurnExpiredPayload({
    required this.waitlistId,
    required this.healerId,
  });

  factory WaitlistTurnExpiredPayload.fromJson(Map<String, dynamic> json) {
    return WaitlistTurnExpiredPayload(
      waitlistId: json['waitlistId']?.toString() ?? '',
      healerId: json['healerId']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [waitlistId, healerId];
}

class WaitlistPositionResponse extends Equatable {
  final String waitlistId;
  final String healerId;
  final int consultationType;
  final String status;
  final int position;
  final int peopleAhead;
  final int? estimatedWaitMinutes;
  final DateTime? joinedAt;

  const WaitlistPositionResponse({
    required this.waitlistId,
    required this.healerId,
    required this.consultationType,
    required this.status,
    required this.position,
    this.peopleAhead = 0,
    this.estimatedWaitMinutes,
    this.joinedAt,
  });

  factory WaitlistPositionResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return WaitlistPositionResponse(
      waitlistId: data['waitlistId']?.toString() ?? '',
      healerId: data['healerId']?.toString() ?? '',
      consultationType: parseLiveConsultationType(data['consultationType']),
      status: data['status']?.toString() ?? 'Waiting',
      position: (data['position'] as num?)?.toInt() ?? 0,
      peopleAhead: (data['peopleAhead'] as num?)?.toInt() ?? 0,
      estimatedWaitMinutes: (data['estimatedWaitMinutes'] as num?)?.toInt(),
      joinedAt: _parseDate(data['joinedAt']),
    );
  }

  @override
  List<Object?> get props => [waitlistId, position, peopleAhead, status];
}

String liveConsultationTypeLabel(int consultationType) {
  switch (consultationType) {
    case 1:
      return 'Audio';
    case 2:
      return 'Video';
    default:
      return 'Chat';
  }
}

class LiveInsufficientWalletResponse extends Equatable {
  final bool isValid;
  final double currentBalance;
  final double requiredBalance;
  final double ratePerMinute;
  final int minMinutes;
  final String message;

  const LiveInsufficientWalletResponse({
    required this.isValid,
    required this.currentBalance,
    required this.requiredBalance,
    required this.ratePerMinute,
    required this.minMinutes,
    required this.message,
  });

  factory LiveInsufficientWalletResponse.fromJson(Map<String, dynamic> json) {
    return LiveInsufficientWalletResponse(
      isValid: json['isValid'] as bool? ?? false,
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
      requiredBalance: (json['requiredBalance'] as num?)?.toDouble() ?? 0,
      ratePerMinute: (json['ratePerMinute'] as num?)?.toDouble() ?? 0,
      minMinutes: (json['minMinutes'] as num?)?.toInt() ?? 5,
      message: json['message']?.toString() ?? 'Insufficient wallet balance.',
    );
  }

  @override
  List<Object?> get props => [message, requiredBalance];
}

class RequestAcceptedPayload extends Equatable {
  final String bookingId;
  final String bookingReference;
  final DateTime? startedAt;
  final double pricePerMinute;
  final int freeMinutes;
  final int consultationType;
  final String? agoraToken;
  final String? agoraChannelName;
  final String? agoraUid;

  const RequestAcceptedPayload({
    required this.bookingId,
    required this.bookingReference,
    this.startedAt,
    this.pricePerMinute = 0,
    this.freeMinutes = 0,
    this.consultationType = 0,
    this.agoraToken,
    this.agoraChannelName,
    this.agoraUid,
  });

  bool get hasAgoraCredentials =>
      (agoraToken?.isNotEmpty ?? false) &&
      (agoraChannelName?.isNotEmpty ?? false);

  factory RequestAcceptedPayload.fromJson(Map<String, dynamic> json) {
    return RequestAcceptedPayload(
      bookingId: json['bookingId']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      startedAt: _parseDate(json['startedAt']),
      pricePerMinute: (json['pricePerMinute'] as num?)?.toDouble() ?? 0,
      freeMinutes: (json['freeMinutes'] as num?)?.toInt() ?? 0,
      consultationType: parseLiveConsultationType(json['consultationType']),
      agoraToken: json['agoraToken']?.toString(),
      agoraChannelName: json['agoraChannelName']?.toString(),
      agoraUid: json['agoraUid']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        bookingReference,
        consultationType,
        agoraToken,
        agoraChannelName,
      ];
}

class BillingCyclePayload extends Equatable {
  final String bookingId;
  final int cycleNumber;
  final double amountDeducted;
  final double balanceAfter;
  final DateTime? nextDeductionAt;

  const BillingCyclePayload({
    required this.bookingId,
    required this.cycleNumber,
    required this.amountDeducted,
    required this.balanceAfter,
    this.nextDeductionAt,
  });

  factory BillingCyclePayload.fromJson(Map<String, dynamic> json) {
    return BillingCyclePayload(
      bookingId: json['bookingId']?.toString() ?? '',
      cycleNumber: (json['cycleNumber'] as num?)?.toInt() ?? 0,
      amountDeducted: (json['amountDeducted'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0,
      nextDeductionAt: _parseDate(json['nextDeductionAt']),
    );
  }

  @override
  List<Object?> get props => [bookingId, cycleNumber, amountDeducted];
}

class LowBalanceWarningPayload extends Equatable {
  final String bookingId;
  final double currentBalance;
  final int estimatedMinutesLeft;

  const LowBalanceWarningPayload({
    required this.bookingId,
    required this.currentBalance,
    required this.estimatedMinutesLeft,
  });

  factory LowBalanceWarningPayload.fromJson(Map<String, dynamic> json) {
    return LowBalanceWarningPayload(
      bookingId: json['bookingId']?.toString() ?? '',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
      estimatedMinutesLeft:
          (json['estimatedMinutesLeft'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [bookingId, estimatedMinutesLeft];
}

class SessionEndedSummary extends Equatable {
  final String bookingId;
  final String bookingReference;
  final int consultationType;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int totalSeconds;
  final int billedMinutes;
  final double ratePerMinute;
  final int freeMinutes;
  final int freeMinutesApplied;
  final double totalAmountCharged;
  final String endReason;

  const SessionEndedSummary({
    required this.bookingId,
    required this.bookingReference,
    this.consultationType = 0,
    this.startedAt,
    this.endedAt,
    this.totalSeconds = 0,
    this.billedMinutes = 0,
    this.ratePerMinute = 0,
    this.freeMinutes = 0,
    this.freeMinutesApplied = 0,
    this.totalAmountCharged = 0,
    this.endReason = '',
  });

  factory SessionEndedSummary.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return SessionEndedSummary(
      bookingId: data['bookingId']?.toString() ?? '',
      bookingReference: data['bookingReference']?.toString() ?? '',
      consultationType: (data['consultationType'] as num?)?.toInt() ?? 0,
      startedAt: _parseDate(data['startedAt']),
      endedAt: _parseDate(data['endedAt']),
      totalSeconds: (data['totalSeconds'] as num?)?.toInt() ?? 0,
      billedMinutes: (data['billedMinutes'] as num?)?.toInt() ?? 0,
      ratePerMinute: (data['ratePerMinute'] as num?)?.toDouble() ?? 0,
      freeMinutes: (data['freeMinutes'] as num?)?.toInt() ?? 0,
      freeMinutesApplied: (data['freeMinutesApplied'] as num?)?.toInt() ?? 0,
      totalAmountCharged: (data['totalAmountCharged'] as num?)?.toDouble() ?? 0,
      endReason: SessionEndReason.label(data['endReason']),
    );
  }

  @override
  List<Object?> get props => [bookingId, totalAmountCharged, endReason];
}

class HealerStatusChangedPayload extends Equatable {
  final String healerId;
  final String newStatus;

  const HealerStatusChangedPayload({
    required this.healerId,
    required this.newStatus,
  });

  factory HealerStatusChangedPayload.fromJson(Map<String, dynamic> json) {
    final raw = json['newStatus'] ?? json['status'];
    return HealerStatusChangedPayload(
      healerId: json['healerId']?.toString() ?? '',
      newStatus: HealerPresenceStatus.label(raw),
    );
  }

  @override
  List<Object?> get props => [healerId, newStatus];
}

class LiveEndBody extends Equatable {
  final String bookingId;
  final int reason;

  const LiveEndBody({
    required this.bookingId,
    this.reason = SessionEndReason.patientEnded,
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'reason': reason,
      };

  @override
  List<Object?> get props => [bookingId, reason];
}

/// 0=Chat, 1=Audio, 2=Video — handles int or string from API/hub.
int parseLiveConsultationType(dynamic value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  if (value is String) {
    final lower = value.trim().toLowerCase();
    if (lower == 'chat' || lower == '0') return 0;
    if (lower == 'audio' || lower == 'voice' || lower == '1') return 1;
    if (lower == 'video' || lower == '2') return 2;
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

String _liveRequestStatusLabel(dynamic status) {
  if (status is String && status.toLowerCase() == 'queued') {
    return 'Queued';
  }
  final code = LiveRequestStatus.parseCode(status);
  switch (code) {
    case LiveRequestStatus.pending:
      return 'Pending';
    case LiveRequestStatus.accepted:
      return 'Accepted';
    case LiveRequestStatus.rejected:
      return 'Rejected';
    case LiveRequestStatus.expired:
      return 'Expired';
    case LiveRequestStatus.cancelled:
      return 'Cancelled';
    default:
      return status?.toString() ?? 'Pending';
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

import 'package:equatable/equatable.dart';

/// SignalR `GroupSessionStarted` — healer started the shared group channel.
class GroupSessionStartedPayload extends Equatable {
  final String bookingId;
  final String bookingReference;
  final String channelName;
  final String slotId;
  final String bookingDate;

  const GroupSessionStartedPayload({
    required this.bookingId,
    required this.bookingReference,
    required this.channelName,
    required this.slotId,
    required this.bookingDate,
  });

  factory GroupSessionStartedPayload.fromJson(Map<String, dynamic> json) {
    return GroupSessionStartedPayload(
      bookingId: json['bookingId']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      channelName: json['channelName']?.toString() ?? '',
      slotId: json['slotId']?.toString() ?? '',
      bookingDate: json['bookingDate']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props =>
      [bookingId, bookingReference, channelName, slotId, bookingDate];
}

/// SignalR `GroupSessionEnded` — billing completed for this patient.
class GroupSessionEndedPayload extends Equatable {
  final String bookingId;
  final String bookingReference;
  final double amountCharged;
  final double amountRefunded;

  const GroupSessionEndedPayload({
    required this.bookingId,
    required this.bookingReference,
    required this.amountCharged,
    required this.amountRefunded,
  });

  factory GroupSessionEndedPayload.fromJson(Map<String, dynamic> json) {
    return GroupSessionEndedPayload(
      bookingId: json['bookingId']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      amountCharged: (json['amountCharged'] as num?)?.toDouble() ?? 0,
      amountRefunded: (json['amountRefunded'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props =>
      [bookingId, bookingReference, amountCharged, amountRefunded];
}

/// SignalR `AutoDisconnected` — slot end time reached.
class GroupSessionAutoDisconnectedPayload extends Equatable {
  final String bookingId;

  const GroupSessionAutoDisconnectedPayload({required this.bookingId});

  factory GroupSessionAutoDisconnectedPayload.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroupSessionAutoDisconnectedPayload(
      bookingId: json['bookingId']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [bookingId];
}

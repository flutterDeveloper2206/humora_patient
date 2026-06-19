import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../../../agora/data/models/agora_info.dart';

enum BookingStatus {
  pending(1, 'Awaiting confirmation'),
  confirmed(2, 'Confirmed'),
  active(3, 'Session in progress'),
  completed(4, 'Done'),
  cancelled(5, 'Cancelled'),
  expired(6, 'Expired (no-one joined)'),
  rejected(7, 'Cancelled by healer'),
  noShow(8, 'Marked no-show'),
  autoDisconnected(9, 'Disconnected mid-session'),
  unknown(0, 'Unknown');

  final int value;
  final String label;

  const BookingStatus(this.value, this.label);

  static BookingStatus fromValue(int? val) {
    return BookingStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => BookingStatus.unknown,
    );
  }

  bool get showJoinButton => this == BookingStatus.active;

  bool get showReceipt => this == BookingStatus.completed;

  bool get showCountdown => this == BookingStatus.confirmed;

  bool get canCancel =>
      this == BookingStatus.pending || this == BookingStatus.confirmed;

  bool get isTerminal =>
      this == BookingStatus.completed ||
      this == BookingStatus.cancelled ||
      this == BookingStatus.expired ||
      this == BookingStatus.rejected ||
      this == BookingStatus.noShow ||
      this == BookingStatus.autoDisconnected;
}

class MyBookingModel extends Equatable {
  final String id;
  final String bookingReference;
  final String healerName;
  final String bookingDate;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final int serviceType;
  final int status;
  final int fixedPrice;
  final int holdAmount;
  final int? consultationType;
  final AgoraInfo? agoraInfo;

  const MyBookingModel({
    required this.id,
    required this.bookingReference,
    required this.healerName,
    required this.bookingDate,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    required this.serviceType,
    required this.status,
    required this.fixedPrice,
    required this.holdAmount,
    this.consultationType,
    this.agoraInfo,
  });

  factory MyBookingModel.fromJson(Map<String, dynamic> json) {
    return MyBookingModel(
      id: json['id']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      healerName: json['healerName']?.toString() ?? 'Healer',
      bookingDate: json['bookingDate']?.toString() ?? '',
      scheduledStartTime: json['scheduledStartTime']?.toString() ?? '',
      scheduledEndTime: json['scheduledEndTime']?.toString() ?? '',
      serviceType: _parseServiceType(json['serviceType']),
      status: _parseStatus(json['status']),
      fixedPrice: (json['fixedPrice'] as num?)?.toInt() ?? 0,
      holdAmount: (json['holdAmount'] as num?)?.toInt() ?? 0,
      consultationType: (json['consultationType'] as num?)?.toInt(),
      agoraInfo: AgoraInfo.tryParse(json['agoraInfo']),
    );
  }

  BookingStatus get bookingStatus => BookingStatus.fromValue(status);

  /// Join opens 5 minutes before scheduled start (chat / session access window).
  static const Duration joinEarlyAccess = Duration(minutes: 5);

  DateTime get startDateTime => _dateTimeFromParts(
        bookingDate,
        scheduledStartTime,
        fallback: DateTime.tryParse(bookingDate) ?? DateTime.now(),
      );

  DateTime get endDateTime => _dateTimeFromParts(
        bookingDate,
        scheduledEndTime,
        fallback: startDateTime,
      );

  DateTime get joinOpensAt => startDateTime.subtract(joinEarlyAccess);

  bool get isWithinScheduledWindow {
    final now = DateTime.now();
    return !now.isBefore(joinOpensAt) && now.isBefore(endDateTime);
  }

  /// Join when server sent Agora metadata and the local access window allows it.
  bool get isGroupBooking => serviceType == 3;

  bool get isWaitingForGroupStart =>
      isGroupBooking &&
      bookingStatus == BookingStatus.confirmed &&
      agoraInfo != null &&
      DateTime.now().isBefore(endDateTime);

  bool get canJoin {
    if (agoraInfo == null) return false;
    if (isGroupBooking) {
      // Group: patient joins only after healer starts (Active) or SignalR auto-nav.
      return bookingStatus == BookingStatus.active;
    }
    if (bookingStatus == BookingStatus.active) return true;
    if (bookingStatus == BookingStatus.confirmed) return isWithinScheduledWindow;
    return false;
  }

  bool get isUpcomingConfirmed =>
      bookingStatus == BookingStatus.confirmed &&
      agoraInfo != null &&
      DateTime.now().isBefore(startDateTime) &&
      DateTime.now().isBefore(endDateTime) &&
      !isGroupBooking;

  DateTime _dateTimeFromParts(
    String date,
    String time, {
    required DateTime fallback,
  }) {
    if (time.trim().isEmpty) return fallback;
    try {
      return DateTime.parse('$date $time');
    } catch (_) {
      return fallback;
    }
  }

  String get serviceTypeLabel {
    switch (serviceType) {
      case 1:
        return 'Live Session';
      case 2:
        return 'Personal Session';
      case 3:
        return 'Group Session';
      default:
        return 'Session';
    }
  }

  String get timeRangeLabel {
    final start = _formatClock(scheduledStartTime);
    final end = _formatClock(scheduledEndTime);
    if (end.isEmpty) return start;
    return '$start – $end';
  }

  String _formatClock(String time) {
    try {
      final parts = time.split(':');
      final h = int.parse(parts[0]);
      final m = parts.length > 1 ? parts[1] : '00';
      final ampm = h >= 12 ? 'PM' : 'AM';
      final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$displayHour:$m $ampm';
    } catch (_) {
      return time;
    }
  }

  @override
  List<Object?> get props => [
        id,
        bookingReference,
        healerName,
        bookingDate,
        scheduledStartTime,
        scheduledEndTime,
        serviceType,
        status,
        fixedPrice,
        holdAmount,
        consultationType,
        agoraInfo,
      ];
}

int _parseStatus(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'pending' || 'awaiting confirmation' => 1,
      'confirmed' => 2,
      'active' || 'session in progress' => 3,
      'completed' || 'done' => 4,
      'cancelled' => 5,
      'expired' || 'expired (no-one joined)' => 6,
      'rejected' || 'cancelled by healer' => 7,
      'no-show' || 'marked no-show' => 8,
      'auto disconnected' || 'disconnected mid-session' => 9,
      _ => int.tryParse(value) ?? 0,
    };
  }
  return 0;
}

int _parseServiceType(dynamic value) {
  if (value is num) return value.toInt();
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    return switch (normalized) {
      'live' || 'live session' => 1,
      'personal' || 'personal session' => 2,
      'group' || 'group session' => 3,
      _ => int.tryParse(value) ?? 0,
    };
  }
  return 0;
}

class BookingDetailModel extends MyBookingModel {
  final String? healerId;
  final String? scheduledStartAt;
  final String? scheduledEndAt;
  final String? refundStatus;

  const BookingDetailModel({
    required super.id,
    required super.bookingReference,
    required super.healerName,
    required super.bookingDate,
    required super.scheduledStartTime,
    required super.scheduledEndTime,
    required super.serviceType,
    required super.status,
    required super.fixedPrice,
    required super.holdAmount,
    super.consultationType,
    super.agoraInfo,
    this.healerId,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.refundStatus,
  });

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailModel(
      id: json['id']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      healerName: json['healerName']?.toString() ?? 'Healer',
      bookingDate: json['bookingDate']?.toString() ?? '',
      scheduledStartTime: json['scheduledStartTime']?.toString() ?? '',
      scheduledEndTime: json['scheduledEndTime']?.toString() ?? '',
      serviceType: _parseServiceType(json['serviceType']),
      status: _parseStatus(json['status']),
      fixedPrice: (json['fixedPrice'] as num?)?.toInt() ?? 0,
      holdAmount: (json['holdAmount'] as num?)?.toInt() ?? 0,
      consultationType: (json['consultationType'] as num?)?.toInt(),
      agoraInfo: AgoraInfo.tryParse(json['agoraInfo']),
      healerId: json['healerId']?.toString(),
      scheduledStartAt: json['scheduledStartAt']?.toString(),
      scheduledEndAt: json['scheduledEndAt']?.toString(),
      refundStatus: json['refundStatus']?.toString(),
    );
  }

  String get consultationLabel {
    switch (consultationType) {
      case 0:
        return 'Chat';
      case 1:
        return 'Audio';
      case 2:
        return 'Video';
      default:
        return '';
    }
  }

  String get refundLabel {
    if (bookingStatus != BookingStatus.cancelled) return '';
    if (refundStatus == null || refundStatus!.isEmpty) {
      return 'Refund status pending';
    }
    return 'Refund: $refundStatus';
  }

  @override
  DateTime get startDateTime {
    final iso = scheduledStartAt;
    if (iso != null && iso.isNotEmpty) {
      final parsed = DateTime.tryParse(iso);
      if (parsed != null) return parsed.toLocal();
    }
    return super.startDateTime;
  }

  @override
  DateTime get endDateTime {
    final iso = scheduledEndAt;
    if (iso != null && iso.isNotEmpty) {
      final parsed = DateTime.tryParse(iso);
      if (parsed != null) return parsed.toLocal();
    }
    return super.endDateTime;
  }

  static BookingDetailModel placeholder() {
    return const BookingDetailModel(
      id: 'placeholder',
      bookingReference: 'HU-00000000-XXXX',
      healerName: 'Healer Name',
      bookingDate: '2026-01-15',
      scheduledStartTime: '10:00:00',
      scheduledEndTime: '11:00:00',
      serviceType: 2,
      status: 1,
      fixedPrice: 500,
      holdAmount: 500,
    );
  }
}

class BookingDateGroup extends Equatable {
  final String dateKey;
  final String dateHeader;
  final List<MyBookingModel> bookings;

  const BookingDateGroup({
    required this.dateKey,
    required this.dateHeader,
    required this.bookings,
  });

  @override
  List<Object?> get props => [dateKey, dateHeader, bookings];
}

class MyBookingsGrouper {
  static List<BookingDateGroup> placeholderGroups() {
    return const [
      BookingDateGroup(
        dateKey: '2026-01-15',
        dateHeader: 'Thursday, 15 Jan 2026',
        bookings: [
          MyBookingModel(
            id: 'placeholder-1',
            bookingReference: 'HU-00000000-XXXX',
            healerName: 'Healer Name',
            bookingDate: '2026-01-15',
            scheduledStartTime: '10:00:00',
            scheduledEndTime: '11:00:00',
            serviceType: 2,
            status: 1,
            fixedPrice: 500,
            holdAmount: 500,
          ),
          MyBookingModel(
            id: 'placeholder-2',
            bookingReference: 'HU-00000000-YYYY',
            healerName: 'Healer Name',
            bookingDate: '2026-01-15',
            scheduledStartTime: '14:00:00',
            scheduledEndTime: '15:00:00',
            serviceType: 2,
            status: 1,
            fixedPrice: 500,
            holdAmount: 500,
          ),
        ],
      ),
    ];
  }

  static List<MyBookingModel> sortUpcomingFirst(List<MyBookingModel> items) {
    final now = DateTime.now();
    final upcoming = <MyBookingModel>[];
    final past = <MyBookingModel>[];

    for (final item in items) {
      if (item.startDateTime.isBefore(now) && item.bookingStatus.isTerminal) {
        past.add(item);
      } else if (item.startDateTime.isBefore(now) &&
          !item.bookingStatus.isTerminal) {
        upcoming.add(item);
      } else if (!item.startDateTime.isBefore(now)) {
        upcoming.add(item);
      } else {
        past.add(item);
      }
    }

    upcoming.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
    past.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
    return [...upcoming, ...past];
  }

  static List<BookingDateGroup> groupByDate(List<MyBookingModel> sorted) {
    final map = <String, List<MyBookingModel>>{};
    for (final booking in sorted) {
      map.putIfAbsent(booking.bookingDate, () => []).add(booking);
    }

    final keys = map.keys.toList()..sort();
    return keys.map((key) {
      final entry = map[key]!;
      DateTime? dt;
      try {
        dt = DateTime.parse(key);
      } catch (_) {}
      final header = dt != null
          ? DateFormat('EEEE, d MMM yyyy').format(dt)
          : key;
      return BookingDateGroup(
        dateKey: key,
        dateHeader: header,
        bookings: entry,
      );
    }).toList();
  }
}

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

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
  });

  factory MyBookingModel.fromJson(Map<String, dynamic> json) {
    return MyBookingModel(
      id: json['id']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      healerName: json['healerName']?.toString() ?? 'Healer',
      bookingDate: json['bookingDate']?.toString() ?? '',
      scheduledStartTime: json['scheduledStartTime']?.toString() ?? '',
      scheduledEndTime: json['scheduledEndTime']?.toString() ?? '',
      serviceType: (json['serviceType'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      fixedPrice: (json['fixedPrice'] as num?)?.toInt() ?? 0,
      holdAmount: (json['holdAmount'] as num?)?.toInt() ?? 0,
    );
  }

  BookingStatus get bookingStatus => BookingStatus.fromValue(status);

  DateTime get startDateTime {
    try {
      return DateTime.parse('$bookingDate $scheduledStartTime');
    } catch (_) {
      return DateTime.tryParse(bookingDate) ?? DateTime.now();
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
      ];
}

class BookingDetailModel extends MyBookingModel {
  final String? healerId;
  final int? consultationType;
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
    this.healerId,
    this.consultationType,
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
      serviceType: (json['serviceType'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      fixedPrice: (json['fixedPrice'] as num?)?.toInt() ?? 0,
      holdAmount: (json['holdAmount'] as num?)?.toInt() ?? 0,
      healerId: json['healerId']?.toString(),
      consultationType: (json['consultationType'] as num?)?.toInt(),
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

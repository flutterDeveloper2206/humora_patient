import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class HealerCalendarResponse extends Equatable {
  final String callerRole;
  final int total;
  final List<HealerCalendarSession> sessions;

  const HealerCalendarResponse({
    required this.callerRole,
    required this.total,
    required this.sessions,
  });

  factory HealerCalendarResponse.fromJson(Map<String, dynamic> json) {
    final rawSessions = json['sessions'];
    final sessions = <HealerCalendarSession>[];
    if (rawSessions is List) {
      for (final item in rawSessions) {
        if (item is Map<String, dynamic>) {
          try {
            sessions.add(HealerCalendarSession.fromJson(item));
          } catch (_) {}
        }
      }
    }

    return HealerCalendarResponse(
      callerRole: json['callerRole']?.toString() ?? '',
      total: (json['total'] as num?)?.toInt() ?? sessions.length,
      sessions: sessions,
    );
  }

  @override
  List<Object?> get props => [callerRole, total, sessions];
}

class HealerCalendarSession extends Equatable {
  final String bookingId;
  final String bookingReference;
  final int serviceType;
  final String serviceTypeLabel;
  final int? consultationType;
  final String? consultationTypeLabel;
  final int bookingStatus;
  final String bookingStatusLabel;
  final String bookingDate;
  final String? scheduledStartAt;
  final String? scheduledEndAt;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final bool isLiveDirect;
  final int? durationMinutes;
  final String? actualStartAt;
  final String? actualEndAt;
  final int? actualDurationSeconds;
  final HealerCalendarPerson healer;
  final HealerCalendarPricing? pricing;

  const HealerCalendarSession({
    required this.bookingId,
    required this.bookingReference,
    required this.serviceType,
    required this.serviceTypeLabel,
    this.consultationType,
    this.consultationTypeLabel,
    required this.bookingStatus,
    required this.bookingStatusLabel,
    required this.bookingDate,
    this.scheduledStartAt,
    this.scheduledEndAt,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.isLiveDirect = false,
    this.durationMinutes,
    this.actualStartAt,
    this.actualEndAt,
    this.actualDurationSeconds,
    required this.healer,
    this.pricing,
  });

  factory HealerCalendarSession.fromJson(Map<String, dynamic> json) {
    return HealerCalendarSession(
      bookingId: json['bookingId']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      serviceType: (json['serviceType'] as num?)?.toInt() ?? 0,
      serviceTypeLabel: json['serviceTypeLabel']?.toString() ?? '',
      consultationType: (json['consultationType'] as num?)?.toInt(),
      consultationTypeLabel: json['consultationTypeLabel']?.toString(),
      bookingStatus: (json['bookingStatus'] as num?)?.toInt() ?? 0,
      bookingStatusLabel: json['bookingStatusLabel']?.toString() ?? '',
      bookingDate: json['bookingDate']?.toString() ?? '',
      scheduledStartAt: json['scheduledStartAt']?.toString(),
      scheduledEndAt: json['scheduledEndAt']?.toString(),
      scheduledStartTime: json['scheduledStartTime']?.toString() ?? '',
      scheduledEndTime: json['scheduledEndTime']?.toString() ?? '',
      isLiveDirect: json['isLiveDirect'] == true,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      actualStartAt: json['actualStartAt']?.toString(),
      actualEndAt: json['actualEndAt']?.toString(),
      actualDurationSeconds: (json['actualDurationSeconds'] as num?)?.toInt(),
      healer: HealerCalendarPerson.fromJson(
        json['healer'] is Map<String, dynamic>
            ? json['healer'] as Map<String, dynamic>
            : const {},
      ),
      pricing: json['pricing'] is Map<String, dynamic>
          ? HealerCalendarPricing.fromJson(
              json['pricing'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  String get healerName {
    final name = '${healer.firstName} ${healer.lastName}'.trim();
    return name.isEmpty ? 'Healer' : name;
  }

  String get healerImage =>
      (healer.profileImage?.trim().isNotEmpty ?? false)
          ? healer.profileImage!.trim()
          : 'assets/image/doctorprofile.png';

  DateTime get startDateTime {
    final parsed = DateTime.tryParse(scheduledStartAt ?? '');
    if (parsed != null) return parsed.toLocal();

    final time = scheduledStartTime.trim();
    if (time.isEmpty) {
      return DateTime.tryParse(bookingDate)?.toLocal() ?? DateTime.now();
    }
    final parts = bookingDate.split('-');
    if (parts.length == 3) {
      final timeParts = time.split(':');
      return DateTime(
        int.tryParse(parts[0]) ?? 1970,
        int.tryParse(parts[1]) ?? 1,
        int.tryParse(parts[2]) ?? 1,
        int.tryParse(timeParts.elementAtOrNull(0) ?? '0') ?? 0,
        int.tryParse(timeParts.elementAtOrNull(1) ?? '0') ?? 0,
      );
    }
    return DateTime.now();
  }

  String get timeLabel => DateFormat('h:mm a').format(startDateTime);

  String get sessionTypeLabel {
    if (consultationTypeLabel != null &&
        consultationTypeLabel!.trim().isNotEmpty) {
      return consultationTypeLabel!.trim();
    }
    if (serviceTypeLabel.trim().isNotEmpty) return serviceTypeLabel.trim();
    return 'Session';
  }

  String? get durationLabel {
    if (actualDurationSeconds != null && actualDurationSeconds! > 0) {
      final mins = actualDurationSeconds! ~/ 60;
      final secs = actualDurationSeconds! % 60;
      if (mins > 0 && secs > 0) return '${mins}m ${secs}s';
      if (mins > 0) return '${mins}m';
      return '${secs}s';
    }
    if (durationMinutes != null && durationMinutes! > 0) {
      return '${durationMinutes}m';
    }
    return null;
  }

  String? get priceLabel {
    final p = pricing;
    if (p == null) return null;
    if (p.fixedPrice != null) {
      return '${p.currencySymbol}${p.fixedPrice}';
    }
    if (p.pricePerMinute != null) {
      return '${p.currencySymbol}${p.pricePerMinute}/min';
    }
    return null;
  }

  bool get canCancel => bookingStatus == 1 || bookingStatus == 2;

  @override
  List<Object?> get props => [bookingId, bookingDate, scheduledStartTime];
}

class HealerCalendarPerson extends Equatable {
  final String? id;
  final String firstName;
  final String lastName;
  final String? profileImage;

  const HealerCalendarPerson({
    this.id,
    this.firstName = '',
    this.lastName = '',
    this.profileImage,
  });

  factory HealerCalendarPerson.fromJson(Map<String, dynamic> json) {
    return HealerCalendarPerson(
      id: json['id']?.toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, firstName, lastName, profileImage];
}

class HealerCalendarPricing extends Equatable {
  final num? pricePerMinute;
  final int? freeMinutes;
  final num? fixedPrice;
  final String currencySymbol;
  final String currencyIsoCode;

  const HealerCalendarPricing({
    this.pricePerMinute,
    this.freeMinutes,
    this.fixedPrice,
    this.currencySymbol = '',
    this.currencyIsoCode = '',
  });

  factory HealerCalendarPricing.fromJson(Map<String, dynamic> json) {
    return HealerCalendarPricing(
      pricePerMinute: json['pricePerMinute'] as num?,
      freeMinutes: (json['freeMinutes'] as num?)?.toInt(),
      fixedPrice: json['fixedPrice'] as num?,
      currencySymbol: json['currencySymbol']?.toString() ?? '',
      currencyIsoCode: json['currencyIsoCode']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props =>
      [pricePerMinute, freeMinutes, fixedPrice, currencySymbol];
}

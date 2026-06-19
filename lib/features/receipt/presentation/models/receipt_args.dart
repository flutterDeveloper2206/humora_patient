import 'package:equatable/equatable.dart';

import '../../../group_session/data/models/group_session_hub_models.dart';
import '../../../live_consultation/data/models/live_models.dart';

class ReceiptArgs extends Equatable {
  final String healerName;
  final String healerRole;
  final String healerImage;
  final String startTime;
  final String endTime;
  final String duration;
  final String date;
  final String mode;
  final String healingType;
  final String sessionType;
  final double totalAmount;
  final String receiptId;

  const ReceiptArgs({
    required this.healerName,
    required this.healerRole,
    required this.healerImage,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.date,
    required this.mode,
    required this.healingType,
    required this.sessionType,
    required this.totalAmount,
    required this.receiptId,
  });

  factory ReceiptArgs.fromSessionSummary({
    required SessionEndedSummary summary,
    String? healerName,
    String? healerRole,
    String? healerImage,
    String? healingType,
    String? sessionType,
  }) {
    final started = summary.startedAt?.toLocal();
    final ended = summary.endedAt?.toLocal();
    return ReceiptArgs(
      healerName:
          healerName?.trim().isNotEmpty == true ? healerName!.trim() : 'Healer',
      healerRole:
          healerRole?.trim().isNotEmpty == true ? healerRole!.trim() : 'Healer',
      healerImage:
          healerImage?.trim().isNotEmpty == true
              ? healerImage!.trim()
              : 'assets/image/doctorprofile.png',
      startTime: started != null ? _hhmm(started) : '--:--',
      endTime: ended != null ? _hhmm(ended) : '--:--',
      duration: _durationLabel(summary.totalSeconds),
      date: _dateLabel(started ?? ended),
      mode: _modeLabel(summary.consultationType),
      healingType:
          healingType?.trim().isNotEmpty == true
              ? healingType!.trim()
              : 'Live Consultation',
      sessionType:
          sessionType?.trim().isNotEmpty == true ? sessionType!.trim() : 'Live',
      totalAmount: summary.totalAmountCharged,
      receiptId:
          summary.bookingReference.isNotEmpty
              ? summary.bookingReference
              : summary.bookingId,
    );
  }

  factory ReceiptArgs.fromGroupSessionEnd({
    required GroupSessionEndedPayload summary,
    required Duration sessionDuration,
    String? healerName,
    bool autoDisconnected = false,
  }) {
    final now = DateTime.now();
    return ReceiptArgs(
      healerName:
          healerName?.trim().isNotEmpty == true ? healerName!.trim() : 'Healer',
      healerRole: 'Healer',
      healerImage: 'assets/image/doctorprofile.png',
      startTime: '--:--',
      endTime: _hhmm(now),
      duration: _durationLabel(sessionDuration.inSeconds),
      date: _dateLabel(now),
      mode: 'Video Consultation',
      healingType: 'Group Healing',
      sessionType: autoDisconnected ? 'Group (auto-ended)' : 'Group',
      totalAmount: summary.amountCharged,
      receiptId: summary.bookingReference.isNotEmpty
          ? summary.bookingReference
          : summary.bookingId,
    );
  }

  @override
  List<Object?> get props => [
    healerName,
    healerRole,
    healerImage,
    startTime,
    endTime,
    duration,
    date,
    mode,
    healingType,
    sessionType,
    totalAmount,
    receiptId,
  ];
}

String _hhmm(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _durationLabel(int totalSeconds) {
  if (totalSeconds <= 0) return '0m';
  final hours = totalSeconds ~/ 3600;
  final mins = (totalSeconds % 3600) ~/ 60;
  final secs = totalSeconds % 60;
  if (hours > 0) {
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
  if (mins > 0) {
    return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
  }
  return '${secs}s';
}

String _dateLabel(DateTime? dt) {
  if (dt == null) return '--';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[dt.month - 1];
  return '$month ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
}

String _modeLabel(int consultationType) {
  switch (consultationType) {
    case 0:
      return 'Chat Consultation';
    case 1:
      return 'Audio Consultation';
    case 2:
      return 'Video Consultation';
    default:
      return 'Live Consultation';
  }
}

import 'package:equatable/equatable.dart';

class ReceiptState extends Equatable {
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

  const ReceiptState({
    this.healerName = 'Marvin McKinney',
    this.healerRole = 'Astrologer',
    this.healerImage = 'assets/image/doctorprofile.png',
    this.startTime = '10:00',
    this.endTime = '12:30',
    this.duration = '2h 30m',
    this.date = 'Oct 06, 2025',
    this.mode = 'Video Consultation',
    this.healingType = 'Money block',
    this.sessionType = 'Group',
    this.totalAmount = 85.0,
    this.receiptId = '10297U 12819GA18217',
  });

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

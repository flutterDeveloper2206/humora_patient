import 'package:humora_patient/features/healers/data/models/healer_model.dart';

class AppointmentReminderModel {
  final HealerModel healer;
  final DateTime appointmentTime;

  AppointmentReminderModel({
    required this.healer,
    required this.appointmentTime,
  });
}

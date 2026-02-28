import '../../healers/data/healer_model.dart';

class AppointmentReminderModel {
  final HealerModel healer;
  final DateTime appointmentTime;

  AppointmentReminderModel({
    required this.healer,
    required this.appointmentTime,
  });
}

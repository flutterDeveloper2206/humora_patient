import 'package:equatable/equatable.dart';
import '../data/appointment_reminder_model.dart';

abstract class AppointmentReminderEvent extends Equatable {
  const AppointmentReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppointmentReminder extends AppointmentReminderEvent {
  final AppointmentReminderModel appointment;

  const LoadAppointmentReminder(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

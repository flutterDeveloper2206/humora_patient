import 'package:equatable/equatable.dart';
import 'package:humora_patient/features/appointment_reminder/data/models/appointment_reminder_model.dart';

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

import 'package:equatable/equatable.dart';
import '../data/appointment_reminder_model.dart';

enum AppointmentReminderStatus { initial, loading, loaded, error }

class AppointmentReminderState extends Equatable {
  final AppointmentReminderStatus status;
  final AppointmentReminderModel? appointment;
  final String? errorMessage;

  const AppointmentReminderState({
    this.status = AppointmentReminderStatus.initial,
    this.appointment,
    this.errorMessage,
  });

  AppointmentReminderState copyWith({
    AppointmentReminderStatus? status,
    AppointmentReminderModel? appointment,
    String? errorMessage,
  }) {
    return AppointmentReminderState(
      status: status ?? this.status,
      appointment: appointment ?? this.appointment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, appointment, errorMessage];
}

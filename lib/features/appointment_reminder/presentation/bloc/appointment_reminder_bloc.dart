import 'package:flutter_bloc/flutter_bloc.dart';
import 'appointment_reminder_event.dart';
import 'appointment_reminder_state.dart';

class AppointmentReminderBloc
    extends Bloc<AppointmentReminderEvent, AppointmentReminderState> {
  AppointmentReminderBloc() : super(const AppointmentReminderState()) {
    on<LoadAppointmentReminder>(_onLoadAppointmentReminder);
  }

  void _onLoadAppointmentReminder(
    LoadAppointmentReminder event,
    Emitter<AppointmentReminderState> emit,
  ) {
    emit(
      state.copyWith(
        status: AppointmentReminderStatus.loaded,
        appointment: event.appointment,
      ),
    );
  }
}

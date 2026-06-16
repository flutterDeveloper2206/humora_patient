import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:humora_patient/features/live_consultation/presentation/utils/live_consultation_options.dart';
import 'live_counselling_session_event.dart';
import 'live_counselling_session_state.dart';

class LiveCounsellingSessionBloc
    extends Bloc<LiveCounsellingSessionEvent, LiveCounsellingSessionState> {
  LiveCounsellingSessionBloc() : super(LiveCounsellingSessionInitial()) {
    on<LoadLiveCounsellingSessionOptions>(_onLoadLiveCounsellingSessionOptions);
    on<SelectLiveCounsellingSession>(_onSelectLiveCounsellingSession);
  }

  void _onLoadLiveCounsellingSessionOptions(
    LoadLiveCounsellingSessionOptions event,
    Emitter<LiveCounsellingSessionState> emit,
  ) {
    emit(LiveCounsellingSessionLoading());
    try {
      final options =
          LiveConsultationOptions.fromLiveCounselling(event.liveCounselling);
      emit(
        LiveCounsellingSessionLoaded(
          options: options,
          selectedId: options.isNotEmpty ? options.first.id : null,
        ),
      );
    } catch (e) {
      emit(LiveCounsellingSessionError(e.toString()));
    }
  }

  void _onSelectLiveCounsellingSession(
    SelectLiveCounsellingSession event,
    Emitter<LiveCounsellingSessionState> emit,
  ) {
    if (state is LiveCounsellingSessionLoaded) {
      final currentState = state as LiveCounsellingSessionLoaded;
      emit(currentState.copyWith(selectedId: event.sessionId));
    }
  }
}

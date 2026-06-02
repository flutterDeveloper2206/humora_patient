import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:humora_patient/features/live_counselling_session/data/models/live_counselling_session_model.dart';
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
      final List<Map<String, dynamic>> dummyData = [
        {
          "id": 1,
          "image": "assets/image/chatstart.png",
          "value": "Chat",
          "price": 100,
          "consultationType": 0,
        },
        {
          "id": 2,
          "image": "assets/image/voicestart.png",
          "value": "Voice Call",
          "price": 300,
          "consultationType": 1,
        },
        {
          "id": 3,
          "image": "assets/image/videostart.png",
          "value": "Video Call",
          "price": 500,
          "consultationType": 2,
        },
      ];

      final options = dummyData
          .map((e) => LiveCounsellingSessionModel.fromJson(e))
          .toList();
      emit(LiveCounsellingSessionLoaded(options: options, selectedId: 1));
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

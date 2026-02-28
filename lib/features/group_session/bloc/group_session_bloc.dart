import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'group_session_event.dart';
import 'group_session_state.dart';

class GroupSessionBloc extends Bloc<GroupSessionEvent, GroupSessionState> {
  Timer? _timer;

  GroupSessionBloc() : super(const GroupSessionState()) {
    on<LoadSession>(_onLoadSession);
    on<ToggleMyMute>(_onToggleMyMute);
    on<ToggleMyVideo>(_onToggleMyVideo);
    on<UpdateSessionTimer>(_onUpdateSessionTimer);
  }

  void _onLoadSession(LoadSession event, Emitter<GroupSessionState> emit) {
    final participants = [
      const GroupParticipant(
        id: '1',
        name: 'Alexx Manuel',
        role: 'Astrologer',
        imageUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=1976&auto=format&fit=crop',
        isMainSpeaker: true,
      ),
      const GroupParticipant(
        id: '2',
        name: 'Adams',
        role: 'UI Designer',
        imageUrl:
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1974&auto=format&fit=crop',
      ),
      const GroupParticipant(
        id: '3',
        name: 'Iman Roberts',
        role: 'UX De..',
        imageUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974&auto=format&fit=crop',
        isMuted: true,
      ),
      const GroupParticipant(
        id: '4',
        name: 'Anna Slens',
        role: 'UI Desi..',
        imageUrl:
            'https://images.unsplash.com/photo-1580489944761-15a19d654956?q=80&w=1961&auto=format&fit=crop',
        isHandRaised: true,
      ),
      const GroupParticipant(
        id: '5',
        name: 'Adams',
        role: 'UI Designer',
        imageUrl:
            'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1974&auto=format&fit=crop',
      ),
    ];

    emit(state.copyWith(participants: participants));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(UpdateSessionTimer(state.duration + const Duration(seconds: 1)));
    });
  }

  void _onToggleMyMute(ToggleMyMute event, Emitter<GroupSessionState> emit) {
    emit(state.copyWith(isMyMuted: !state.isMyMuted));
  }

  void _onToggleMyVideo(ToggleMyVideo event, Emitter<GroupSessionState> emit) {
    emit(state.copyWith(isMyVideoOff: !state.isMyVideoOff));
  }

  void _onUpdateSessionTimer(
    UpdateSessionTimer event,
    Emitter<GroupSessionState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

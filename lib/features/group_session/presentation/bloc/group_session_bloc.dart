import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../agora/domain/usecases/agora_session_usecase.dart';
import '../../../agora/domain/usecases/fetch_agora_token_usecase.dart';
import '../../../agora/presentation/models/call_phase.dart';
import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/services/agora_rtc_service.dart';
import '../../../agora/presentation/utils/call_permissions.dart';
import '../../../../core/network/connectivity_service.dart';
import 'group_session_event.dart';
import 'group_session_state.dart';

class GroupSessionBloc extends Bloc<GroupSessionEvent, GroupSessionState> {
  final CallRouteArgs _args;
  final FetchAgoraTokenUseCase _fetchToken;
  final AgoraSessionUseCase _agoraSession;
  AgoraRtcService _rtc;

  Timer? _timer;
  StreamSubscription<AgoraCallEvent>? _rtcSub;
  String? _agoraUid;
  int _localRtcUid = 0;

  GroupSessionBloc({
    required CallRouteArgs args,
    FetchAgoraTokenUseCase? fetchToken,
    AgoraSessionUseCase? agoraSession,
    AgoraRtcService? rtc,
  })  : _args = args,
        _fetchToken = fetchToken ?? FetchAgoraTokenUseCase(),
        _agoraSession = agoraSession ?? AgoraSessionUseCase(),
        _rtc = rtc ?? AgoraRtcService(),
        super(
          GroupSessionState(
            sessionTitle: args.healerName,
          ),
        ) {
    on<LoadSession>(_onLoadSession);
    on<RetrySession>(_onRetrySession);
    on<AgoraEngineEvent>(_onAgoraEngineEvent);
    on<ToggleMyMute>(_onToggleMyMute);
    on<ToggleMyVideo>(_onToggleMyVideo);
    on<EndSession>(_onEndSession);
    on<UpdateSessionTimer>(_onUpdateSessionTimer);
  }

  Future<void> _onLoadSession(
    LoadSession event,
    Emitter<GroupSessionState> emit,
  ) async {
    await _connect(emit);
  }

  Future<void> _onRetrySession(
    RetrySession event,
    Emitter<GroupSessionState> emit,
  ) async {
    await _connect(emit);
  }

  Future<void> _connect(Emitter<GroupSessionState> emit) async {
    emit(
      state.copyWith(
        phase: CallPhase.loadingToken,
        participants: [],
        clearError: true,
      ),
    );

    if (!ConnectivityService.instance.isOnline) {
      emit(
        state.copyWith(
          phase: CallPhase.error,
          errorMessage: 'No internet connection. Check your network and retry.',
        ),
      );
      return;
    }

    final permissionError = await CallPermissions.requestForMode(_args.mode);
    if (permissionError != null) {
      emit(
        state.copyWith(
          phase: CallPhase.error,
          errorMessage: permissionError,
        ),
      );
      return;
    }

    try {
      await _rtcSub?.cancel();
      await _rtc.leaveAndDispose();
      _rtc.dispose();
      _rtc = AgoraRtcService();

      final tokenResponse = await _fetchToken(_args.bookingId);
      if (tokenResponse.channelName.isEmpty) {
        throw Exception('Invalid channel from server');
      }
      _agoraUid = tokenResponse.agoraUid.isNotEmpty
          ? tokenResponse.agoraUid
          : tokenResponse.uid.toString();
      emit(state.copyWith(phase: CallPhase.connecting));

      await _rtcSub?.cancel();
      _rtcSub = _rtc.events.listen((e) => add(AgoraEngineEvent(e)));

      await _rtc.initialize(
        appId: tokenResponse.appId,
        enableVideo: true,
      );

      final uid = tokenResponse.uid == 0 ? 0 : tokenResponse.uid;
      _localRtcUid = uid;
      await _rtc.joinChannel(
        token: tokenResponse.token,
        channelId: tokenResponse.channelName,
        uid: uid,
        publishVideo: true,
      );

      emit(state.copyWith(engine: _rtc.engine));
    } catch (e) {
      await _rtc.leaveAndDispose();
      _rtc.dispose();
      emit(
        state.copyWith(
          phase: CallPhase.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  void _onAgoraEngineEvent(
    AgoraEngineEvent event,
    Emitter<GroupSessionState> emit,
  ) {
    switch (event.event.type) {
      case AgoraCallEventType.joinSuccess:
        if (_agoraUid != null && _agoraUid!.isNotEmpty) {
          unawaited(
            _agoraSession.notifyJoined(
              bookingId: _args.bookingId,
              agoraUid: _agoraUid!,
            ),
          );
        }
        final localUid = _localRtcUid;
        final withLocal = state.participants.any((p) => p.agoraUid == localUid)
            ? state.participants
            : [
                GroupParticipant(
                  agoraUid: localUid,
                  name: 'You',
                  isMainSpeaker: true,
                ),
                ...state.participants,
              ];
        emit(
          state.copyWith(
            phase: CallPhase.inProgress,
            engine: _rtc.engine,
            participants: withLocal,
          ),
        );
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          add(UpdateSessionTimer(Duration(seconds: t.tick)));
        });
        break;
      case AgoraCallEventType.userJoined:
        final remoteUid = event.event.uid;
        if (remoteUid == null) break;
        final existing = state.participants.any((p) => p.agoraUid == remoteUid);
        if (existing) break;
        final updated = [
          ...state.participants,
          GroupParticipant(
            agoraUid: remoteUid,
            name: 'Participant ${state.participants.length + 1}',
            isMainSpeaker: state.participants.isEmpty,
          ),
        ];
        emit(state.copyWith(participants: updated));
        break;
      case AgoraCallEventType.userOffline:
        final remoteUid = event.event.uid;
        if (remoteUid == null) break;
        emit(
          state.copyWith(
            participants: state.participants
                .where((p) => p.agoraUid != remoteUid)
                .toList(),
          ),
        );
        break;
      case AgoraCallEventType.error:
        emit(
          state.copyWith(
            phase: CallPhase.error,
            errorMessage:
                event.event.message ?? 'Session connection error',
          ),
        );
        break;
      default:
        break;
    }
  }

  void _onUpdateSessionTimer(
    UpdateSessionTimer event,
    Emitter<GroupSessionState> emit,
  ) {
    emit(state.copyWith(duration: event.duration));
  }

  Future<void> _onToggleMyMute(
    ToggleMyMute event,
    Emitter<GroupSessionState> emit,
  ) async {
    final muted = !state.isMyMuted;
    await _rtc.muteLocalAudio(muted);
    emit(state.copyWith(isMyMuted: muted));
  }

  Future<void> _onToggleMyVideo(
    ToggleMyVideo event,
    Emitter<GroupSessionState> emit,
  ) async {
    final off = !state.isMyVideoOff;
    await _rtc.muteLocalVideo(off);
    emit(state.copyWith(isMyVideoOff: off));
  }

  Future<void> _onEndSession(
    EndSession event,
    Emitter<GroupSessionState> emit,
  ) async {
    _timer?.cancel();
    try {
      if (_agoraUid != null && _agoraUid!.isNotEmpty) {
        await _agoraSession.notifyLeft(bookingId: _args.bookingId);
      }
    } catch (_) {}
    await _rtcSub?.cancel();
    await _rtc.leaveAndDispose();
    _rtc.dispose();
    emit(state.copyWith(phase: CallPhase.ended, engine: null));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _rtcSub?.cancel();
    _rtc.leaveAndDispose();
    _rtc.dispose();
    return super.close();
  }
}

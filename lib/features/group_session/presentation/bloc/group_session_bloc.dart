import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../agora/domain/usecases/agora_session_usecase.dart';
import '../../../agora/domain/usecases/fetch_agora_token_usecase.dart';
import '../../../agora/presentation/models/call_phase.dart';
import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/services/agora_rtc_service.dart';
import '../../../agora/presentation/utils/agora_call_token_resolver.dart';
import '../../../agora/presentation/utils/agora_token_refresh_scheduler.dart';
import '../../../agora/presentation/utils/call_permissions.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../core/notifications/session_hub_service.dart';
import '../../data/group_session_remote_end_bus.dart';
import '../../data/models/group_session_hub_models.dart';
import 'group_session_event.dart';
import 'group_session_state.dart';

class GroupSessionBloc extends Bloc<GroupSessionEvent, GroupSessionState> {
  final CallRouteArgs _args;
  final FetchAgoraTokenUseCase _fetchToken;
  final AgoraSessionUseCase _agoraSession;
  AgoraRtcService _rtc;

  Timer? _timer;
  StreamSubscription<AgoraCallEvent>? _rtcSub;
  StreamSubscription<GroupSessionRemoteEnd>? _remoteEndSub;
  StreamSubscription<GroupSessionEndedPayload>? _hubEndedSub;
  StreamSubscription<GroupSessionAutoDisconnectedPayload>? _hubAutoDisconnectSub;
  String? _agoraUid;
  int _localRtcUid = 0;
  AgoraTokenRefreshScheduler? _tokenRefresh;

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
            healerImage: _healerImageFromArgs(args),
          ),
        ) {
    on<LoadSession>(_onLoadSession);
    on<RetrySession>(_onRetrySession);
    on<AgoraEngineEvent>(_onAgoraEngineEvent);
    on<ToggleMyMute>(_onToggleMyMute);
    on<ToggleMyVideo>(_onToggleMyVideo);
    on<EndSession>(_onEndSession);
    on<RemoteSessionEnded>(_onRemoteSessionEnded);
    on<UpdateSessionTimer>(_onUpdateSessionTimer);

    _remoteEndSub = GroupSessionRemoteEndBus.instance.stream.listen((remote) {
      if (!_bookingIdMatches(remote.bookingId)) return;
      add(RemoteSessionEnded(remote));
    });

    final hub = SessionHubService.instance;
    _hubEndedSub = hub.groupSessionEnded.listen((payload) {
      if (!_bookingIdMatches(payload.bookingId)) return;
      add(
        RemoteSessionEnded(
          GroupSessionRemoteEnd(
            bookingId: payload.bookingId,
            summary: payload,
          ),
        ),
      );
    });
    _hubAutoDisconnectSub = hub.groupSessionAutoDisconnected.listen((payload) {
      if (!_bookingIdMatches(payload.bookingId)) return;
      add(
        RemoteSessionEnded(
          GroupSessionRemoteEnd(
            bookingId: payload.bookingId,
            isAutoDisconnected: true,
          ),
        ),
      );
    });
  }

  bool _bookingIdMatches(String other) {
    return _args.bookingId.trim().toLowerCase() ==
        other.trim().toLowerCase();
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
      await SessionHubService.instance.connect();
    } catch (_) {}

    try {
      await _rtcSub?.cancel();
      await _rtc.leaveAndDispose();
      _rtc.dispose();
      _rtc = AgoraRtcService();

      final tokenResponse = await AgoraCallTokenResolver.resolve(
        args: _args,
        fetchToken: _fetchToken,
      );
      if (tokenResponse.channelName.isEmpty) {
        throw Exception('Invalid channel from server');
      }
      _agoraUid = tokenResponse.agoraUidWire;
      _tokenRefresh?.dispose();
      _tokenRefresh = AgoraTokenRefreshScheduler(rtc: _rtc)
        ..schedule(args: _args, tokenResponse: tokenResponse);
      emit(state.copyWith(phase: CallPhase.connecting));

      await _rtcSub?.cancel();
      _rtcSub = _rtc.events.listen((e) => add(AgoraEngineEvent(e)));

      await _rtc.initialize(
        appId: tokenResponse.appId,
        enableVideo: true,
      );

      _localRtcUid = tokenResponse.uidForSdk;
      await _rtc.joinChannel(
        token: tokenResponse.token,
        channelId: tokenResponse.channelName,
        uid: tokenResponse.uidForSdk,
        userAccount: tokenResponse.requiresUserAccountJoin
            ? tokenResponse.userAccountForJoin
            : null,
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

  Future<void> _onAgoraEngineEvent(
    AgoraEngineEvent event,
    Emitter<GroupSessionState> emit,
  ) async {
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
                  isLocal: true,
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
        final isFirstRemote = !state.participants.any((p) => !p.isLocal);
        final remoteParticipant = GroupParticipant(
          agoraUid: remoteUid,
          name: isFirstRemote ? _args.healerName : 'Participant',
          isMainSpeaker: isFirstRemote,
          isHealer: isFirstRemote,
        );
        final updated = [
          for (final participant in state.participants)
            participant.isLocal
                ? participant.copyWith(isMainSpeaker: false)
                : participant,
          remoteParticipant,
        ];
        emit(state.copyWith(participants: updated));
        break;
      case AgoraCallEventType.userOffline:
        final remoteUid = event.event.uid;
        if (remoteUid == null) break;
        GroupParticipant? offlineParticipant;
        for (final participant in state.participants) {
          if (participant.agoraUid == remoteUid) {
            offlineParticipant = participant;
            break;
          }
        }
        if (offlineParticipant?.isHealer == true &&
            state.phase == CallPhase.inProgress) {
          await _leaveSession(emit, sessionEndedByHealer: true);
          break;
        }
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
    await _leaveSession(emit);
  }

  Future<void> _onRemoteSessionEnded(
    RemoteSessionEnded event,
    Emitter<GroupSessionState> emit,
  ) async {
    if (state.phase == CallPhase.ended) return;
    await _leaveSession(
      emit,
      endSummary: event.remoteEnd.summary,
      sessionAutoDisconnected: event.remoteEnd.isAutoDisconnected,
      sessionEndedByHealer: !event.remoteEnd.isAutoDisconnected,
    );
  }

  Future<void> _leaveSession(
    Emitter<GroupSessionState> emit, {
    GroupSessionEndedPayload? endSummary,
    bool sessionAutoDisconnected = false,
    bool sessionEndedByHealer = false,
  }) async {
    _timer?.cancel();
    _tokenRefresh?.dispose();
    _tokenRefresh = null;
    try {
      if (_agoraUid != null && _agoraUid!.isNotEmpty) {
        await _agoraSession.notifyLeft(bookingId: _args.bookingId);
      }
    } catch (_) {}
    await _rtcSub?.cancel();
    await _rtc.leaveAndDispose();
    _rtc.dispose();
    if (emit.isDone) return;
    emit(
      state.copyWith(
        phase: CallPhase.ended,
        clearEngine: true,
        endSummary: endSummary,
        sessionAutoDisconnected: sessionAutoDisconnected,
        sessionEndedByHealer: sessionEndedByHealer,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _tokenRefresh?.dispose();
    _remoteEndSub?.cancel();
    _hubEndedSub?.cancel();
    _hubAutoDisconnectSub?.cancel();
    _rtcSub?.cancel();
    _rtc.leaveAndDispose();
    _rtc.dispose();
    return super.close();
  }
}

String _healerImageFromArgs(CallRouteArgs args) {
  final url = args.healerImageUrl?.trim();
  if (url != null && url.isNotEmpty) return url;
  return 'assets/image/doctorprofile.png';
}

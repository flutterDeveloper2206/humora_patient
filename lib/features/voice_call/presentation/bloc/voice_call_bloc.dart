import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../agora/domain/usecases/agora_session_usecase.dart';
import '../../../agora/domain/usecases/fetch_agora_token_usecase.dart';
import '../../../agora/presentation/models/call_phase.dart';
import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/services/agora_rtc_service.dart';
import '../../../../core/constants/agora_config.dart';
import '../../../agora/presentation/utils/agora_call_token_resolver.dart';
import '../../../agora/presentation/utils/call_permissions.dart';
import '../../../live_consultation/data/datasource/live_api_service.dart';
import '../../../live_consultation/data/models/live_models.dart';
import '../../../../core/network/connectivity_service.dart';
import 'voice_call_event.dart';
import 'voice_call_state.dart';

class VoiceCallBloc extends Bloc<VoiceCallEvent, VoiceCallState> {
  final CallRouteArgs _args;
  final FetchAgoraTokenUseCase _fetchToken;
  final AgoraSessionUseCase _agoraSession;
  final LiveApiService _liveApi;
  AgoraRtcService _rtc;

  Timer? _timer;
  StreamSubscription<AgoraCallEvent>? _rtcSub;
  String? _agoraUid;
  bool _backendJoinNotified = false;

  VoiceCallBloc({
    required CallRouteArgs args,
    FetchAgoraTokenUseCase? fetchToken,
    AgoraSessionUseCase? agoraSession,
    LiveApiService? liveApi,
    AgoraRtcService? rtc,
  })  : _args = args,
        _fetchToken = fetchToken ?? FetchAgoraTokenUseCase(),
        _agoraSession = agoraSession ?? AgoraSessionUseCase(),
        _liveApi = liveApi ?? LiveApiService(),
        _rtc = rtc ?? AgoraRtcService(),
        super(
          VoiceCallState(
            callerName: args.healerName,
            callerImage:
                args.healerImageUrl ?? 'assets/image/doctorprofile.png',
          ),
        ) {
    on<LoadCall>(_onLoadCall);
    on<RetryCall>(_onRetryCall);
    on<AgoraEngineEvent>(_onAgoraEngineEvent);
    on<UpdateDuration>(_onUpdateDuration);
    on<ToggleMute>(_onToggleMute);
    on<EndCall>(_onEndCall);
  }

  Future<void> _onLoadCall(LoadCall event, Emitter<VoiceCallState> emit) async {
    await _startCall(emit);
  }

  Future<void> _onRetryCall(
    RetryCall event,
    Emitter<VoiceCallState> emit,
  ) async {
    await _startCall(emit);
  }

  Future<void> _startCall(Emitter<VoiceCallState> emit) async {
    emit(
      state.copyWith(
        phase: CallPhase.loadingToken,
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

      final tokenResponse = await AgoraCallTokenResolver.resolve(
        args: _args,
        fetchToken: _fetchToken,
      );
      _agoraUid = tokenResponse.agoraUidWire;
      _backendJoinNotified = false;

      emit(state.copyWith(phase: CallPhase.connecting));

      await _rtcSub?.cancel();
      _rtcSub = _rtc.events.listen((e) => add(AgoraEngineEvent(e)));

      await _rtc.initialize(
        appId: AgoraConfig.appId,
        enableVideo: false,
      );

      await _rtc.joinChannel(
        token: tokenResponse.token,
        channelId: tokenResponse.channelName,
        uid: tokenResponse.uidForSdk,
        userAccount: tokenResponse.usesStringUserAccount
            ? tokenResponse.agoraUid
            : null,
        publishVideo: false,
      );
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
    Emitter<VoiceCallState> emit,
  ) {
    switch (event.event.type) {
      case AgoraCallEventType.joinSuccess:
        if (_agoraUid != null && _agoraUid!.isNotEmpty && !_backendJoinNotified) {
          _backendJoinNotified = true;
          unawaited(
            _agoraSession.notifyJoined(
              bookingId: _args.bookingId,
              agoraUid: _agoraUid!,
            ),
          );
        }
        emit(state.copyWith(phase: CallPhase.inProgress));
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (t) {
          add(UpdateDuration(Duration(seconds: t.tick)));
        });
        break;
      case AgoraCallEventType.userJoined:
        emit(state.copyWith(remoteUid: event.event.uid));
        break;
      case AgoraCallEventType.error:
        if (state.phase == CallPhase.inProgress) break;
        emit(
          state.copyWith(
            phase: CallPhase.error,
            errorMessage: event.event.message?.trim().isNotEmpty == true
                ? event.event.message
                : 'Unable to join the call. Please retry.',
          ),
        );
        break;
      default:
        break;
    }
  }

  void _onUpdateDuration(UpdateDuration event, Emitter<VoiceCallState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  Future<void> _onToggleMute(
    ToggleMute event,
    Emitter<VoiceCallState> emit,
  ) async {
    final muted = !state.isMuted;
    await _rtc.muteLocalAudio(muted);
    emit(state.copyWith(isMuted: muted));
  }

  Future<void> _onEndCall(EndCall event, Emitter<VoiceCallState> emit) async {
    _timer?.cancel();
    SessionEndedSummary? summary;
    try {
      if (_agoraUid != null && _agoraUid!.isNotEmpty) {
        await _agoraSession.notifyLeft(bookingId: _args.bookingId);
      }
      if (_args.isLive) {
        summary = await _liveApi.endSession(
          LiveEndBody(bookingId: _args.bookingId),
        );
      }
    } catch (_) {}
    await _rtcSub?.cancel();
    await _rtc.leaveAndDispose();
    _rtc.dispose();
    emit(state.copyWith(phase: CallPhase.ended, sessionSummary: summary));
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

import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../../../core/constants/agora_config.dart';
import '../../data/models/agora_token_models.dart';
import '../utils/agora_rtc_logging.dart';

enum AgoraCallEventType {
  joinSuccess,
  userJoined,
  userOffline,
  remoteVideoMuted,
  error,
  invalidToken,
  left,
}

class AgoraCallEvent {
  final AgoraCallEventType type;
  final int? uid;
  final String? message;

  const AgoraCallEvent({
    required this.type,
    this.uid,
    this.message,
  });
}

class AgoraRtcService {
  RtcEngine? _engine;
  final _events = StreamController<AgoraCallEvent>.broadcast();
  bool _initialized = false;
  bool _channelReady = false;
  String? _appId;

  Stream<AgoraCallEvent> get events => _events.stream;
  RtcEngine? get engine => _engine;
  bool get channelReady => _channelReady;

  void markChannelReady() => _channelReady = true;

  Future<void> initialize({
    String? appId,
    required bool enableVideo,
  }) async {
    if (_initialized && _engine != null) return;

    _appId = appId ?? AgoraConfig.appId;
    AgoraRtcLogger.initialize(
      appId: _appId!,
      enableVideo: enableVideo,
    );
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: _appId!,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
    await _engine!.enableAudio();
    await _engine!.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioDefault,
    );
    if (enableVideo) {
      await _engine!.enableVideo();
      await _engine!.startPreview();
    } else {
      await _engine!.disableVideo();
    }
    _registerHandlers();
    _initialized = true;
  }

  void _registerHandlers() {
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          _channelReady = true;
          AgoraRtcLogger.event('onJoinChannelSuccess', {
            'channelId': connection.channelId,
            'localUid': connection.localUid,
            'elapsedMs': elapsed,
          });
          _events.add(
            const AgoraCallEvent(type: AgoraCallEventType.joinSuccess),
          );
        },
        onLocalUserRegistered: (uid, userAccount) {
          _channelReady = true;
          AgoraRtcLogger.event('onLocalUserRegistered', {
            'uid': uid,
            'userAccount': userAccount,
          });
          _events.add(
            const AgoraCallEvent(type: AgoraCallEventType.joinSuccess),
          );
        },
        onConnectionStateChanged: (connection, state, reason) {
          AgoraRtcLogger.event('onConnectionStateChanged', {
            'channelId': connection.channelId,
            'localUid': connection.localUid,
            'state': state.name,
            'reason': reason.name,
          });
          if (state == ConnectionStateType.connectionStateConnected) {
            _channelReady = true;
            _events.add(
              const AgoraCallEvent(type: AgoraCallEventType.joinSuccess),
            );
          } else if (state == ConnectionStateType.connectionStateFailed &&
              reason ==
                  ConnectionChangedReasonType.connectionChangedInvalidToken) {
            AgoraRtcLogger.error(
              'connectionChangedInvalidToken',
              reason.name,
            );
            _events.add(
              const AgoraCallEvent(type: AgoraCallEventType.invalidToken),
            );
          }
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          AgoraRtcLogger.event('onUserJoined', {
            'channelId': connection.channelId,
            'remoteUid': remoteUid,
            'elapsedMs': elapsed,
          });
          _events.add(
            AgoraCallEvent(
              type: AgoraCallEventType.userJoined,
              uid: remoteUid,
            ),
          );
        },
        onUserOffline: (connection, remoteUid, reason) {
          AgoraRtcLogger.event('onUserOffline', {
            'remoteUid': remoteUid,
            'reason': reason.name,
          });
          _events.add(
            AgoraCallEvent(
              type: AgoraCallEventType.userOffline,
              uid: remoteUid,
            ),
          );
        },
        onRemoteVideoStateChanged: (
          connection,
          remoteUid,
          state,
          reason,
          elapsed,
        ) {
          _events.add(
            AgoraCallEvent(
              type: AgoraCallEventType.remoteVideoMuted,
              uid: remoteUid,
            ),
          );
        },
        onError: (err, msg) {
          AgoraRtcLogger.error('onError', msg.isNotEmpty ? msg : err);
          if (err == ErrorCodeType.errInvalidToken) {
            _events.add(
              const AgoraCallEvent(type: AgoraCallEventType.invalidToken),
            );
            return;
          }
          final detail =
              msg.isNotEmpty ? msg : 'RTC error ($err)';
          _events.add(
            AgoraCallEvent(
              type: AgoraCallEventType.error,
              message: detail,
            ),
          );
        },
      ),
    );
  }

  Future<void> joinChannel({
    required String token,
    required String channelId,
    required int uid,
    String? userAccount,
    required bool publishVideo,
  }) async {
    final engine = _engine;
    if (engine == null) {
      throw Exception('RTC engine not initialized');
    }

    final options = ChannelMediaOptions(
      channelProfile: ChannelProfileType.channelProfileCommunication,
      clientRoleType: ClientRoleType.clientRoleBroadcaster,
      publishMicrophoneTrack: true,
      publishCameraTrack: publishVideo,
      autoSubscribeAudio: true,
      autoSubscribeVideo: publishVideo,
    );

    final parsedAccount =
        userAccount != null ? int.tryParse(userAccount) : null;
    final useUserAccount = userAccount != null &&
        userAccount.isNotEmpty &&
        (parsedAccount == null ||
            parsedAccount > AgoraTokenResponse.maxNativeUid ||
            parsedAccount < 0);

    if (useUserAccount) {
      final appId = _appId ?? AgoraConfig.appId;
      AgoraRtcLogger.registerUserAccount(
        appId: appId,
        userAccount: userAccount,
      );
      AgoraRtcLogger.joinChannel(
        joinMethod: 'joinChannelWithUserAccount',
        appId: appId,
        token: token,
        channelId: channelId,
        uid: uid,
        userAccount: userAccount,
        publishVideo: publishVideo,
        publishAudio: true,
      );
      await engine.registerLocalUserAccount(
        appId: appId,
        userAccount: userAccount,
      );
      await engine.joinChannelWithUserAccount(
        token: token,
        channelId: channelId,
        userAccount: userAccount,
        options: options,
      );
      _channelReady = false;
      AgoraRtcLogger.action('joinChannelWithUserAccount invoked');
      return;
    }

    AgoraRtcLogger.joinChannel(
      joinMethod: 'joinChannel (numeric uid)',
      appId: _appId ?? AgoraConfig.appId,
      token: token,
      channelId: channelId,
      uid: uid,
      userAccount: null,
      publishVideo: publishVideo,
      publishAudio: true,
    );
    await engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: options,
    );
    _channelReady = false;
    AgoraRtcLogger.action('joinChannel invoked');
  }

  Future<bool> setEnableSpeakerphone(bool enabled) async {
    final engine = _engine;
    if (engine == null) return false;

    for (var attempt = 0; attempt < 3; attempt++) {
      if (!_channelReady && attempt == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
      try {
        await engine.setEnableSpeakerphone(enabled);
        return true;
      } catch (_) {
        if (attempt < 2) {
          await Future<void>.delayed(
            Duration(milliseconds: 400 * (attempt + 1)),
          );
        }
      }
    }
    return false;
  }

  Future<void> muteLocalAudio(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  Future<void> muteLocalVideo(bool muted) async {
    await _engine?.muteLocalVideoStream(muted);
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }

  Future<void> renewToken(String token) async {
    AgoraRtcLogger.action('renewToken');
    await _engine?.renewToken(token);
  }

  Future<void> leaveChannelOnly() async {
    AgoraRtcLogger.action('leaveChannel');
    try {
      await _engine?.leaveChannel();
      _channelReady = false;
    } catch (_) {}
  }

  Future<void> leaveAndDispose() async {
    AgoraRtcLogger.action('leaveAndDispose');
    try {
      await _engine?.leaveChannel();
      _channelReady = false;
      if (!_events.isClosed) {
        _events.add(const AgoraCallEvent(type: AgoraCallEventType.left));
      }
    } finally {
      await _engine?.release();
      _engine = null;
      _initialized = false;
    }
  }

  void dispose() {
    if (!_events.isClosed) {
      _events.close();
    }
  }
}

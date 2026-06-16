import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import '../../../../core/constants/agora_config.dart';

enum AgoraCallEventType {
  joinSuccess,
  userJoined,
  userOffline,
  remoteVideoMuted,
  error,
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

  Stream<AgoraCallEvent> get events => _events.stream;
  RtcEngine? get engine => _engine;

  Future<void> initialize({
    String? appId,
    required bool enableVideo,
  }) async {
    if (_initialized && _engine != null) return;

    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId ?? AgoraConfig.appId,
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
          _events.add(
            const AgoraCallEvent(type: AgoraCallEventType.joinSuccess),
          );
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          _events.add(
            AgoraCallEvent(
              type: AgoraCallEventType.userJoined,
              uid: remoteUid,
            ),
          );
        },
        onUserOffline: (connection, remoteUid, reason) {
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

    if (userAccount != null &&
        userAccount.isNotEmpty &&
        int.tryParse(userAccount) == null) {
      await engine.joinChannelWithUserAccount(
        token: token,
        channelId: channelId,
        userAccount: userAccount,
        options: options,
      );
      return;
    }

    await engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: options,
    );
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

  Future<void> setEnableSpeakerphone(bool enabled) async {
    await _engine?.setEnableSpeakerphone(enabled);
  }

  Future<void> leaveAndDispose() async {
    try {
      await _engine?.leaveChannel();
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

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import '../utils/session_manager.dart';
import 'incoming_call_controller.dart';
import 'incoming_call_navigator.dart';
import 'models/incoming_call_payload.dart';

/// Native incoming-call UI via [flutter_callkit_incoming] (CallKit / Android).
class CallKitIncomingService {
  CallKitIncomingService._();
  static final CallKitIncomingService instance = CallKitIncomingService._();

  static const String _appName = 'Humora Patient';
  static const String _primaryHex = '#E81848';
  static const String _darkHex = '#1A1A1A';

  final Map<String, IncomingCallPayload> _rings = {};
  StreamSubscription<CallEvent?>? _eventSub;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    await FlutterCallkitIncoming.onBackgroundMessage(
      callkitBackgroundHandler,
    );

    _eventSub?.cancel();
    _eventSub = FlutterCallkitIncoming.onEvent.listen(
      handleCallEvent,
      onError: (Object e) {
        developer.log('CallKit event error: $e', name: 'CallKitIncomingService');
      },
    );

    if (Platform.isAndroid) {
      await _ensureAndroidPermissions();
    }

    if (Platform.isIOS) {
      await _syncVoipToken();
    }

    _initialized = true;
    developer.log('CallKitIncomingService initialized', name: 'CallKitIncomingService');
  }

  Future<void> _ensureAndroidPermissions() async {
    try {
      await FlutterCallkitIncoming.requestNotificationPermission({
        'title': 'Notification permission',
        'rationaleMessagePermission':
            'Allow notifications to receive incoming calls.',
        'postNotificationMessageRequired':
            'Notification permission is required for incoming calls.',
      });
      final canFullScreen = await FlutterCallkitIncoming.canUseFullScreenIntent();
      if (canFullScreen == false) {
        await FlutterCallkitIncoming.requestFullIntentPermission();
      }
    } catch (e) {
      developer.log(
        'Android call permissions: $e',
        name: 'CallKitIncomingService',
      );
    }
  }

  Future<void> _syncVoipToken() async {
    try {
      final voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
      if (voipToken != null && voipToken.isNotEmpty) {
        await SessionManager.saveVoipToken(voipToken);
      }
    } catch (e) {
      developer.log('VoIP token sync: $e', name: 'CallKitIncomingService');
    }
  }

  Future<void> showIncoming(IncomingCallPayload ring) async {
    if (ring.isExpired) return;
    _rings[ring.callId] = ring;

    final params = _buildParams(ring);
    try {
      await FlutterCallkitIncoming.showCallkitIncoming(params);
    } catch (e) {
      developer.log('showCallkitIncoming failed: $e', name: 'CallKitIncomingService');
      IncomingCallController.instance.showRing(ring);
    }
  }

  Future<void> endIncoming(String? callId) async {
    if (callId == null || callId.isEmpty) {
      await FlutterCallkitIncoming.endAllCalls();
      _rings.clear();
      return;
    }
    _rings.remove(callId);
    try {
      await FlutterCallkitIncoming.endCall(callId);
    } catch (e) {
      developer.log('endCall failed: $e', name: 'CallKitIncomingService');
    }
  }

  Future<void> showMissedCall(IncomingCallPayload ring) async {
    final params = _buildParams(ring);
    try {
      await FlutterCallkitIncoming.showMissCallNotification(params);
    } catch (e) {
      developer.log('showMissCallNotification: $e', name: 'CallKitIncomingService');
    }
  }

  CallKitParams _buildParams(IncomingCallPayload ring) {
    final isVideo = ring.isVideo;
    final durationMs = ring.ttlSeconds * 1000;

    return CallKitParams(
      id: ring.callId,
      nameCaller: ring.callerName,
      appName: _appName,
      avatar: ring.callerPhoto,
      handle: ring.callerId.isNotEmpty ? ring.callerId : ring.bookingId,
      type: isVideo ? 1 : 0,
      duration: durationMs,
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      callingNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: 'Incoming call…',
        callbackText: 'Hang Up',
      ),
      extra: _extraFor(ring),
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: _primaryHex,
        actionColor: _darkHex,
        textColor: '#FFFFFF',
        incomingCallNotificationChannelName: 'Incoming Calls',
        missedCallNotificationChannelName: 'Missed Calls',
        isShowCallID: false,
        isShowFullLockedScreen: true,
        isFullScreen: true,
        isImportant: true,
        textAccept: 'Accept',
        textDecline: 'Decline',
      ),
      ios: IOSParams(
        handleType: 'generic',
        supportsVideo: isVideo,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        supportsDTMF: false,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
  }

  Map<String, dynamic> _extraFor(IncomingCallPayload ring) => {
        'bookingId': ring.bookingId,
        'requestId': ring.requestId ?? '',
        'callerId': ring.callerId,
        'callerName': ring.callerName,
        'callType': ring.callType,
        'source': ring.source,
        'consultationType': ring.consultationType.toString(),
        if (ring.callerPhoto != null) 'callerPhoto': ring.callerPhoto,
        if (ring.expiresAt != null)
          'expiresAt': ring.expiresAt!.toIso8601String(),
        'ttlSeconds': ring.ttlSeconds.toString(),
      };

  IncomingCallPayload? _payloadFromParams(CallKitParams params) {
    final cached = _rings[params.id];
    if (cached != null) return cached;

    final extra = params.extra;
    if (extra == null || extra.isEmpty) return null;

    return IncomingCallPayload.fromMap({
      'callId': params.id,
      'callerName': params.nameCaller ?? extra['callerName'] ?? 'Healer',
      ...extra,
    });
  }

  Future<void> handleCallEvent(CallEvent? event) async {
    if (event == null) return;

    switch (event) {
      case CallEventActionDidUpdateDevicePushTokenVoip():
        await _syncVoipToken();
      case CallEventActionCallIncoming(:final callKitParams):
        final ring = _payloadFromParams(callKitParams);
        if (ring != null) _rings[ring.callId] = ring;
      case CallEventActionCallAccept(:final callKitParams):
        await _onAccept(callKitParams);
      case CallEventActionCallDecline(:final callKitParams):
        await _onDecline(callKitParams);
      case CallEventActionCallEnded(:final callKitParams):
        _rings.remove(callKitParams.id);
        IncomingCallController.instance.dismiss(callId: callKitParams.id);
      case CallEventActionCallTimeout(:final id):
        _rings.remove(id);
        IncomingCallController.instance.dismiss(callId: id);
      case CallEventActionCallCallback(:final id):
        final ring = _rings[id];
        if (ring != null) {
          await IncomingCallNavigator.accept(ring);
        }
      case CallEventActionCallConnected(:final id):
        try {
          await FlutterCallkitIncoming.setCallConnected(id);
        } catch (_) {}
      default:
        break;
    }
  }

  Future<void> _onAccept(CallKitParams params) async {
    final ring = _payloadFromParams(params);
    if (ring == null) return;

    IncomingCallController.instance.dismiss(callId: ring.callId);
    await IncomingCallNavigator.accept(ring);
    await endIncoming(ring.callId);
    try {
      await FlutterCallkitIncoming.setCallConnected(ring.callId);
    } catch (_) {}
  }

  Future<void> _onDecline(CallKitParams params) async {
    final ring = _payloadFromParams(params);
    if (ring == null) {
      await endIncoming(params.id);
      return;
    }
    IncomingCallController.instance.dismiss(callId: ring.callId);
    await IncomingCallNavigator.reject(ring);
    await endIncoming(ring.callId);
  }

  void dispose() {
    _eventSub?.cancel();
    _eventSub = null;
  }
}

@pragma('vm:entry-point')
Future<void> callkitBackgroundHandler(CallEvent event) async {
  await CallKitIncomingService.instance.handleCallEvent(event);
}

import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/live_consultation/data/models/live_models.dart';
import '../../features/live_consultation/presentation/utils/live_waitlist_cache.dart';
import '../notifications/notification_payload.dart';
import 'callkit_incoming_service.dart';
import 'incoming_call_controller.dart';
import 'incoming_call_navigator.dart';
import 'incoming_call_remote_end_bus.dart';
import 'models/call_push_type.dart';
import 'models/incoming_call_payload.dart';

/// Routes call push events per INCOMING_CALL_PUSH_NOTIFICATIONS spec.
class IncomingCallService {
  IncomingCallService._();
  static final IncomingCallService instance = IncomingCallService._();

  /// Returns true when the message was handled as a call event.
  Future<bool> handleRemoteMessage(RemoteMessage message) async {
    final payload = NotificationPayload.fromRemoteMessage(message);
    return handleNotificationPayload(payload);
  }

  Future<bool> handleNotificationPayload(NotificationPayload payload) async {
    final data = payload.data;
    final type = data['type']?.toString() ?? payload.screen;

    if (!CallPushType.isCallEvent(type)) return false;

    developer.log('Call push type=$type', name: 'IncomingCallService');

    switch (type) {
      case CallPushType.incomingCall:
        final ring = IncomingCallPayload.tryFromNotificationData(
          data,
          type: type,
        );
        if (ring == null) return true;
        if (ring.isExpired) return true;
        await CallKitIncomingService.instance.showIncoming(ring);
        return true;

      case CallPushType.callCancelled:
      case CallPushType.callTimeout:
        await CallKitIncomingService.instance.endIncoming(
          data['callId']?.toString(),
        );
        IncomingCallController.instance.dismiss(
          callId: data['callId']?.toString(),
        );
        return true;

      case CallPushType.callMissed:
        final ring = IncomingCallPayload.fromMap(data);
        if (ring.callId.isNotEmpty) {
          await CallKitIncomingService.instance.showMissedCall(ring);
        }
        return true;

      case CallPushType.callAccepted:
        await CallKitIncomingService.instance.endIncoming(
          data['callId']?.toString(),
        );
        IncomingCallController.instance.dismiss(
          callId: data['callId']?.toString(),
        );
        final bookingId = data['bookingId']?.toString() ?? '';
        if (bookingId.isEmpty) return true;

        final healerId = data['healerId']?.toString() ?? '';
        int? consultationType =
            LiveWaitlistCache.instance.consultationTypeForBooking(bookingId);

        if (consultationType == null && data.containsKey('consultationType')) {
          consultationType = parseLiveConsultationType(data['consultationType']);
        }

        if (consultationType == null && healerId.isNotEmpty) {
          consultationType =
              LiveWaitlistCache.instance.argsFor(healerId)?.consultationType;
        }

        // Chat is opened via SignalR RequestAccepted on the chat screen.
        if (consultationType == 0) {
          developer.log(
            'call_accepted → chat session, skipping call navigation',
            name: 'IncomingCallService',
          );
          return true;
        }

        if (consultationType == null) {
          developer.log(
            'call_accepted → unknown consultationType, skipping',
            name: 'IncomingCallService',
          );
          return true;
        }

        await IncomingCallNavigator.joinAcceptedCall(
          bookingId: bookingId,
          healerName: data['healerName']?.toString(),
          consultationType: consultationType,
          isLive: data['source']?.toString().toLowerCase() != 'booking',
        );
        return true;

      case CallPushType.callRejected:
        await CallKitIncomingService.instance.endIncoming(
          data['callId']?.toString(),
        );
        IncomingCallController.instance.dismiss(
          callId: data['callId']?.toString(),
        );
        return true;

      case CallPushType.callEnded:
        await CallKitIncomingService.instance.endIncoming(
          data['callId']?.toString(),
        );
        IncomingCallController.instance.dismiss(
          callId: data['callId']?.toString(),
        );
        IncomingCallRemoteEndBus.instance.notify(
          IncomingCallRemoteEnd(
            callId: data['callId']?.toString() ?? '',
            bookingId: data['bookingId']?.toString() ?? '',
            reason: data['reason']?.toString() ?? '',
          ),
        );
        return true;

      default:
        return false;
    }
  }
}

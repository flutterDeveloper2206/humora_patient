/// Push `type` values from INCOMING_CALL_PUSH_NOTIFICATIONS spec.
class CallPushType {
  CallPushType._();

  static const incomingCall = 'incoming_call';
  static const callCancelled = 'call_cancelled';
  static const callTimeout = 'call_timeout';
  static const callMissed = 'call_missed';
  static const callAccepted = 'call_accepted';
  static const callRejected = 'call_rejected';
  static const callEnded = 'call_ended';

  static bool isCallEvent(String? type) {
    if (type == null || type.isEmpty) return false;
    return type == incomingCall ||
        type == callCancelled ||
        type == callTimeout ||
        type == callMissed ||
        type == callAccepted ||
        type == callRejected ||
        type == callEnded;
  }
}

import 'package:flutter/foundation.dart';

import 'models/incoming_call_payload.dart';

/// Holds the active ringing call shown in [IncomingCallCoordinator].
class IncomingCallController extends ChangeNotifier {
  IncomingCallController._();
  static final IncomingCallController instance = IncomingCallController._();

  IncomingCallPayload? _active;
  bool _isProcessing = false;

  IncomingCallPayload? get active => _active;
  bool get isRinging => _active != null;
  bool get isProcessing => _isProcessing;

  void showRing(IncomingCallPayload payload) {
    if (payload.isExpired) return;
    _active = payload;
    _isProcessing = false;
    notifyListeners();
  }

  void setProcessing(bool value) {
    if (_isProcessing == value) return;
    _isProcessing = value;
    notifyListeners();
  }

  void dismiss({String? callId}) {
    if (callId != null &&
        _active != null &&
        _active!.callId.isNotEmpty &&
        _active!.callId != callId) {
      return;
    }
    _active = null;
    _isProcessing = false;
    notifyListeners();
  }
}

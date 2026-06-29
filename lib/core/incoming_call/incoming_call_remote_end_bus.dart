import 'dart:async';

/// Notifies active voice/video/chat screens that a call ended via push.
class IncomingCallRemoteEnd {
  final String callId;
  final String bookingId;
  final String reason;

  const IncomingCallRemoteEnd({
    required this.callId,
    required this.bookingId,
    this.reason = '',
  });
}

class IncomingCallRemoteEndBus {
  IncomingCallRemoteEndBus._();
  static final IncomingCallRemoteEndBus instance = IncomingCallRemoteEndBus._();

  final _controller = StreamController<IncomingCallRemoteEnd>.broadcast();

  Stream<IncomingCallRemoteEnd> get stream => _controller.stream;

  void notify(IncomingCallRemoteEnd event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }
}

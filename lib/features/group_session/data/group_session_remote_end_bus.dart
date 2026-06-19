import 'dart:async';

import 'models/group_session_hub_models.dart';

/// Notifies an in-call [GroupSessionBloc] that the healer ended the session.
class GroupSessionRemoteEnd {
  final String bookingId;
  final GroupSessionEndedPayload? summary;
  final bool isAutoDisconnected;

  const GroupSessionRemoteEnd({
    required this.bookingId,
    this.summary,
    this.isAutoDisconnected = false,
  });
}

class GroupSessionRemoteEndBus {
  GroupSessionRemoteEndBus._();
  static final GroupSessionRemoteEndBus instance = GroupSessionRemoteEndBus._();

  final _controller = StreamController<GroupSessionRemoteEnd>.broadcast();

  Stream<GroupSessionRemoteEnd> get stream => _controller.stream;

  void notify(GroupSessionRemoteEnd event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }
}

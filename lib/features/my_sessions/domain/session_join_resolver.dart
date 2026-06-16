import 'package:flutter/material.dart';

import '../../healers/data/models/healer_model.dart';
import '../data/models/my_booking_models.dart';

enum SessionJoinAction {
  chat,
  voiceCall,
  videoCall,
  groupSession,
  liveSession,
}

extension BookingDetailJoin on BookingDetailModel {
  List<SessionJoinAction> get availableJoinActions {
    final consultation =
        ConsultationType.fromValue(consultationType ?? 0);
    final session = SessionType.fromValue(serviceType);

    switch (consultation) {
      case ConsultationType.chat:
        return [SessionJoinAction.chat];
      case ConsultationType.audio:
        return [SessionJoinAction.voiceCall];
      case ConsultationType.video:
        if (session == SessionType.group) {
          return [SessionJoinAction.groupSession];
        }
        return [SessionJoinAction.videoCall];
    }
  }

  /// On-demand live consultation booking (`serviceType == 1`).
  bool get isLiveBooking => serviceType == SessionType.live.value;
}

extension SessionJoinActionLabels on SessionJoinAction {
  String get title => switch (this) {
        SessionJoinAction.chat => 'Start Chat',
        SessionJoinAction.voiceCall => 'Join Voice Call',
        SessionJoinAction.videoCall => 'Join Video Call',
        SessionJoinAction.groupSession => 'Join Group Session',
        SessionJoinAction.liveSession => 'Join Live Session',
      };

  IconData get icon => switch (this) {
        SessionJoinAction.chat => Icons.chat_bubble_outline,
        SessionJoinAction.voiceCall => Icons.call,
        SessionJoinAction.videoCall => Icons.videocam_outlined,
        SessionJoinAction.groupSession => Icons.groups_outlined,
        SessionJoinAction.liveSession => Icons.live_tv_outlined,
      };
}

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
  bool get canJoinSession => canJoin;

  List<SessionJoinAction> get availableJoinActions {
    if (!canJoinSession) return [];
    return _joinActionsFor(
      consultationType: consultationType ?? 0,
      serviceType: serviceType,
    );
  }

  /// On-demand live consultation booking (`serviceType == 1`).
  bool get isLiveBooking => serviceType == SessionType.live.value;
}

extension MyBookingJoin on MyBookingModel {
  List<SessionJoinAction> get availableJoinActions {
    if (!canJoin) return [];
    return _joinActionsFor(
      consultationType: consultationType ?? 0,
      serviceType: serviceType,
    );
  }

  bool get isLiveBooking => serviceType == SessionType.live.value;

  BookingDetailModel toDetailModel() {
    return BookingDetailModel(
      id: id,
      bookingReference: bookingReference,
      healerName: healerName,
      bookingDate: bookingDate,
      scheduledStartTime: scheduledStartTime,
      scheduledEndTime: scheduledEndTime,
      serviceType: serviceType,
      status: status,
      fixedPrice: fixedPrice,
      holdAmount: holdAmount,
      consultationType: consultationType,
      agoraInfo: agoraInfo,
    );
  }
}

List<SessionJoinAction> _joinActionsFor({
  required int consultationType,
  required int serviceType,
}) {
  final consultation = ConsultationType.fromValue(consultationType);
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

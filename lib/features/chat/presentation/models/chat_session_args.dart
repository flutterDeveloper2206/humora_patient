import 'package:equatable/equatable.dart';

/// Live chat before a booking exists — POST /live/request + SignalR status.
class PendingLiveChatRequest extends Equatable {
  final String healerId;
  final String? healerImage;

  const PendingLiveChatRequest({required this.healerId, this.healerImage});

  @override
  List<Object?> get props => [healerId, healerImage];
}

class ChatSessionArgs extends Equatable {
  final String bookingId;
  final bool isLiveSession;
  final String? healerName;
  final String? otherUserProfile;
  final PendingLiveChatRequest? pendingLiveRequest;
  final int bookingCount;
  final String? otherPartyUserId;

  const ChatSessionArgs({
    this.bookingId = '',
    this.isLiveSession = false,
    this.healerName,
    this.otherUserProfile,
    this.pendingLiveRequest,
    this.bookingCount = 1,
    this.otherPartyUserId,
  });

  bool get isGroupedHealerChat =>
      otherPartyUserId != null && otherPartyUserId!.isNotEmpty;

  bool get isPendingLiveRequest => pendingLiveRequest != null;

  ChatSessionArgs copyWith({
    String? bookingId,
    bool? isLiveSession,
    String? healerName,
    String? otherUserProfile,
    PendingLiveChatRequest? pendingLiveRequest,
    int? bookingCount,
    String? otherPartyUserId,
    bool clearPendingLiveRequest = false,
  }) {
    return ChatSessionArgs(
      bookingId: bookingId ?? this.bookingId,
      isLiveSession: isLiveSession ?? this.isLiveSession,
      healerName: healerName ?? this.healerName,
      otherUserProfile: otherUserProfile ?? this.otherUserProfile,
      pendingLiveRequest: clearPendingLiveRequest
          ? null
          : (pendingLiveRequest ?? this.pendingLiveRequest),
      bookingCount: bookingCount ?? this.bookingCount,
      otherPartyUserId: otherPartyUserId ?? this.otherPartyUserId,
    );
  }

  @override
  List<Object?> get props => [
    bookingId,
    isLiveSession,
    healerName,
    otherUserProfile,
    pendingLiveRequest,
    bookingCount,
    otherPartyUserId,
  ];
}

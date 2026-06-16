import 'package:equatable/equatable.dart';

/// Live chat before a booking exists — POST /live/request + SignalR status.
class PendingLiveChatRequest extends Equatable {
  final String healerId;
  final String? healerImage;

  const PendingLiveChatRequest({
    required this.healerId,
    this.healerImage,
  });

  @override
  List<Object?> get props => [healerId, healerImage];
}

class ChatSessionArgs extends Equatable {
  final String bookingId;
  final bool isLiveSession;
  final String? healerName;
  final PendingLiveChatRequest? pendingLiveRequest;

  const ChatSessionArgs({
    required this.bookingId,
    this.isLiveSession = false,
    this.healerName,
    this.pendingLiveRequest,
  });

  bool get isPendingLiveRequest => pendingLiveRequest != null;

  ChatSessionArgs copyWith({
    String? bookingId,
    bool? isLiveSession,
    String? healerName,
    PendingLiveChatRequest? pendingLiveRequest,
    bool clearPendingLiveRequest = false,
  }) {
    return ChatSessionArgs(
      bookingId: bookingId ?? this.bookingId,
      isLiveSession: isLiveSession ?? this.isLiveSession,
      healerName: healerName ?? this.healerName,
      pendingLiveRequest: clearPendingLiveRequest
          ? null
          : (pendingLiveRequest ?? this.pendingLiveRequest),
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        isLiveSession,
        healerName,
        pendingLiveRequest,
      ];
}

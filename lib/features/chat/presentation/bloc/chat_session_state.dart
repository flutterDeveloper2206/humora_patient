import 'package:equatable/equatable.dart';

import '../../data/models/chat_models.dart';

abstract class ChatSessionState extends Equatable {
  const ChatSessionState();

  @override
  List<Object?> get props => [];
}

class ChatSessionAccessLoading extends ChatSessionState {
  final String? healerName;

  const ChatSessionAccessLoading({this.healerName});

  @override
  List<Object?> get props => [healerName];
}

class ChatSessionWaitingRoom extends ChatSessionState {
  final ChatAccessResponse access;
  final List<ChatMessageDto> messages;
  final String? healerName;
  final Duration countdown;

  const ChatSessionWaitingRoom({
    required this.access,
    this.messages = const [],
    this.healerName,
    required this.countdown,
  });

  ChatSessionWaitingRoom copyWith({
    ChatAccessResponse? access,
    List<ChatMessageDto>? messages,
    String? healerName,
    Duration? countdown,
  }) {
    return ChatSessionWaitingRoom(
      access: access ?? this.access,
      messages: messages ?? this.messages,
      healerName: healerName ?? this.healerName,
      countdown: countdown ?? this.countdown,
    );
  }

  @override
  List<Object?> get props => [access, messages, healerName, countdown];
}

class ChatSessionActive extends ChatSessionState {
  final ChatAccessResponse access;
  final List<ChatMessageDto> messages;
  final String? healerName;
  final bool isLiveSession;
  final bool canCompose;
  final String? sendError;
  final bool isOtherPartyOnline;
  final String? typingUserName;
  final bool hasMoreHistory;
  final bool isLoadingOlder;
  final Set<String> searchHighlightIds;
  final bool isUploadingAttachment;
  final List<ChatBookingMessageGroup>? bookingGroups;
  final String? activeBookingId;

  const ChatSessionActive({
    required this.access,
    required this.messages,
    this.healerName,
    this.isLiveSession = false,
    this.canCompose = true,
    this.sendError,
    this.isOtherPartyOnline = false,
    this.typingUserName,
    this.hasMoreHistory = false,
    this.isLoadingOlder = false,
    this.searchHighlightIds = const {},
    this.isUploadingAttachment = false,
    this.bookingGroups,
    this.activeBookingId,
  });

  bool get isGrouped => bookingGroups != null && bookingGroups!.isNotEmpty;

  ChatSessionActive copyWith({
    ChatAccessResponse? access,
    List<ChatMessageDto>? messages,
    String? healerName,
    bool? isLiveSession,
    bool? canCompose,
    String? sendError,
    bool clearSendError = false,
    bool? isOtherPartyOnline,
    String? typingUserName,
    bool clearTyping = false,
    bool? hasMoreHistory,
    bool? isLoadingOlder,
    Set<String>? searchHighlightIds,
    bool clearSearchHighlight = false,
    bool? isUploadingAttachment,
    List<ChatBookingMessageGroup>? bookingGroups,
    String? activeBookingId,
  }) {
    return ChatSessionActive(
      access: access ?? this.access,
      messages: messages ?? this.messages,
      healerName: healerName ?? this.healerName,
      isLiveSession: isLiveSession ?? this.isLiveSession,
      canCompose: canCompose ?? this.canCompose,
      sendError: clearSendError ? null : (sendError ?? this.sendError),
      isOtherPartyOnline: isOtherPartyOnline ?? this.isOtherPartyOnline,
      typingUserName: clearTyping
          ? null
          : (typingUserName ?? this.typingUserName),
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      isLoadingOlder: isLoadingOlder ?? this.isLoadingOlder,
      searchHighlightIds: clearSearchHighlight
          ? const {}
          : (searchHighlightIds ?? this.searchHighlightIds),
      isUploadingAttachment:
          isUploadingAttachment ?? this.isUploadingAttachment,
      bookingGroups: bookingGroups ?? this.bookingGroups,
      activeBookingId: activeBookingId ?? this.activeBookingId,
    );
  }

  @override
  List<Object?> get props => [
    access,
    messages,
    healerName,
    isLiveSession,
    canCompose,
    sendError,
    isOtherPartyOnline,
    typingUserName,
    hasMoreHistory,
    isLoadingOlder,
    searchHighlightIds,
    isUploadingAttachment,
    bookingGroups,
    activeBookingId,
  ];
}

class ChatSessionHistoryOnly extends ChatSessionState {
  final ChatAccessResponse access;
  final List<ChatMessageDto> messages;
  final String? healerName;
  final bool showBookAgain;
  final List<ChatBookingMessageGroup>? bookingGroups;

  const ChatSessionHistoryOnly({
    required this.access,
    required this.messages,
    this.healerName,
    this.showBookAgain = true,
    this.bookingGroups,
  });

  bool get isGrouped => bookingGroups != null && bookingGroups!.isNotEmpty;

  @override
  List<Object?> get props => [
    access,
    messages,
    healerName,
    showBookAgain,
    bookingGroups,
  ];
}

class ChatSessionCancelled extends ChatSessionState {
  final ChatAccessResponse access;
  final List<ChatMessageDto> messages;
  final String? healerName;

  const ChatSessionCancelled({
    required this.access,
    this.messages = const [],
    this.healerName,
  });

  @override
  List<Object?> get props => [access, messages, healerName];
}

class ChatSessionError extends ChatSessionState {
  final String message;
  final String? healerName;

  const ChatSessionError({required this.message, this.healerName});

  @override
  List<Object?> get props => [message, healerName];
}

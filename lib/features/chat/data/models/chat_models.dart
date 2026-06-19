import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'chat_reaction_model.dart';

class ChatAccessResponse extends Equatable {
  final bool canRead;
  final bool canWrite;
  final String code;
  final String message;
  final DateTime? chatOpensAt;
  final DateTime? chatClosesAt;
  final DateTime? scheduledStartAt;
  final DateTime? scheduledEndAt;
  final DateTime? serverTimeUtc;

  const ChatAccessResponse({
    required this.canRead,
    required this.canWrite,
    required this.code,
    this.message = '',
    this.chatOpensAt,
    this.chatClosesAt,
    this.scheduledStartAt,
    this.scheduledEndAt,
    this.serverTimeUtc,
  });

  factory ChatAccessResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return ChatAccessResponse(
      canRead: data['canRead'] as bool? ?? false,
      canWrite: data['canWrite'] as bool? ?? false,
      code: data['code']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      chatOpensAt: _parseDate(data['chatOpensAt']),
      chatClosesAt: _parseDate(data['chatClosesAt']),
      scheduledStartAt: _parseDate(data['scheduledStartAt']),
      scheduledEndAt: _parseDate(data['scheduledEndAt']),
      serverTimeUtc: _parseDate(data['serverTimeUtc']),
    );
  }

  Duration get clockDrift {
    if (serverTimeUtc == null) return Duration.zero;
    return DateTime.now().toUtc().difference(serverTimeUtc!);
  }

  DateTime adjustedNow() => DateTime.now().toUtc().subtract(clockDrift);

  @override
  List<Object?> get props => [canRead, canWrite, code];
}

class ChatMessageDto extends Equatable {
  final String messageId;
  final String bookingId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final String messageType;
  final bool isEdited;
  final bool isDeleted;
  final bool isReadByMe;
  final bool isDelivered;
  final bool isReadByOther;
  final DateTime? createdAt;
  final String? idempotencyKey;
  final bool isPending;
  final List<ChatReactionDto> reactions;
  final AttachmentInfo? attachment;

  const ChatMessageDto({
    required this.messageId,
    required this.bookingId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    this.messageType = 'Text',
    this.isEdited = false,
    this.isDeleted = false,
    this.isReadByMe = false,
    this.isDelivered = false,
    this.isReadByOther = false,
    this.createdAt,
    this.idempotencyKey,
    this.isPending = false,
    this.reactions = const [],
    this.attachment,
  });

  bool get isSystem => messageType == 'System' || senderRole == 'System';

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final rawReactions = data['reactions'] as List? ?? [];
    return ChatMessageDto(
      messageId: (data['messageId'] ?? data['MessageId'])?.toString() ?? '',
      bookingId: data['bookingId']?.toString() ?? '',
      senderId: data['senderId']?.toString() ?? '',
      senderName: data['senderName']?.toString() ?? '',
      senderRole: data['senderRole']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      messageType: data['messageType']?.toString() ?? 'Text',
      isEdited: data['isEdited'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      isReadByMe: data['isReadByMe'] as bool? ?? false,
      isDelivered: data['isDelivered'] as bool? ?? false,
      isReadByOther: _readByOtherFromJson(data),
      createdAt: _parseDate(data['createdAt']),
      idempotencyKey: (data['idempotencyKey'] ?? data['IdempotencyKey'])
          ?.toString(),
      reactions: rawReactions
          .map(
            (e) =>
                ChatReactionDto.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      attachment: _parseAttachment(data),
    );
  }

  ChatMessageDto copyWith({
    String? messageId,
    String? bookingId,
    String? content,
    String? messageType,
    bool? isEdited,
    bool? isDeleted,
    bool? isPending,
    bool? isReadByMe,
    bool? isDelivered,
    bool? isReadByOther,
    String? idempotencyKey,
    List<ChatReactionDto>? reactions,
    AttachmentInfo? attachment,
  }) {
    return ChatMessageDto(
      messageId: messageId ?? this.messageId,
      bookingId: bookingId ?? this.bookingId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isReadByMe: isReadByMe ?? this.isReadByMe,
      isDelivered: isDelivered ?? this.isDelivered,
      isReadByOther: isReadByOther ?? this.isReadByOther,
      createdAt: createdAt,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      isPending: isPending ?? this.isPending,
      reactions: reactions ?? this.reactions,
      attachment: attachment ?? this.attachment,
    );
  }

  @override
  List<Object?> get props => [
    messageId,
    content,
    isPending,
    reactions,
    attachment,
  ];
}

class AttachmentUploadInfo {
  final String fileId;
  final String fileName;
  final String fileUrl;
  final String contentType;
  final int fileSizeBytes;
  final String? thumbnailUrl;

  const AttachmentUploadInfo({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    required this.contentType,
    required this.fileSizeBytes,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
    'fileId': fileId,
    'fileName': fileName,
    'fileUrl': fileUrl,
    'contentType': contentType,
    'fileSizeBytes': fileSizeBytes,
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
      'thumbnailUrl': thumbnailUrl,
  };
}

class AttachmentInfo extends Equatable {
  final String fileName;
  final String fileUrl;
  final String contentType;
  final int fileSizeBytes;
  final String? thumbnailUrl;

  const AttachmentInfo({
    required this.fileName,
    required this.fileUrl,
    required this.contentType,
    required this.fileSizeBytes,
    this.thumbnailUrl,
  });

  factory AttachmentInfo.fromJson(Map<String, dynamic> json) => AttachmentInfo(
    fileName: json['fileName']?.toString() ?? '',
    fileUrl: json['fileUrl']?.toString() ?? '',
    contentType: json['contentType']?.toString() ?? 'application/octet-stream',
    fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
    thumbnailUrl: json['thumbnailUrl']?.toString(),
  );

  bool get isImage => contentType.toLowerCase().startsWith('image/');
  bool get isVideo => contentType.toLowerCase().startsWith('video/');
  bool get isAudio => contentType.toLowerCase().startsWith('audio/');
  bool get isDocument => !isImage && !isVideo && !isAudio;
  bool get isImageLike =>
      isImage || _hasImageExtension(fileName) || _hasImageExtension(fileUrl);
  bool get isVideoLike =>
      isVideo || _hasVideoExtension(fileName) || _hasVideoExtension(fileUrl);
  bool get isAudioLike =>
      isAudio || _hasAudioExtension(fileName) || _hasAudioExtension(fileUrl);
  bool get isDocumentLike => !isImageLike && !isVideoLike && !isAudioLike;
  String get previewUrl => (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
      ? thumbnailUrl!
      : fileUrl;

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1048576) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [
    fileName,
    fileUrl,
    contentType,
    fileSizeBytes,
    thumbnailUrl,
  ];
}

bool _hasImageExtension(String value) {
  final v = value.toLowerCase();
  return v.endsWith('.jpg') ||
      v.endsWith('.jpeg') ||
      v.endsWith('.png') ||
      v.endsWith('.webp') ||
      v.endsWith('.heic');
}

bool _hasVideoExtension(String value) {
  final v = value.toLowerCase();
  return v.endsWith('.mp4') || v.endsWith('.mov') || v.endsWith('.m4v');
}

bool _hasAudioExtension(String value) {
  final v = value.toLowerCase();
  return v.endsWith('.m4a') ||
      v.endsWith('.aac') ||
      v.endsWith('.mp3') ||
      v.endsWith('.ogg') ||
      v.endsWith('.wav');
}

class ChatHistoryResponse extends Equatable {
  final String conversationId;
  final List<ChatMessageDto> messages;
  final int totalCount;
  final int unreadCount;
  final bool hasMore;
  final int page;
  final int pageSize;

  const ChatHistoryResponse({
    required this.conversationId,
    required this.messages,
    this.totalCount = 0,
    this.unreadCount = 0,
    this.hasMore = false,
    this.page = 1,
    this.pageSize = 50,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final raw = data['messages'] as List? ?? [];
    return ChatHistoryResponse(
      conversationId: data['conversationId']?.toString() ?? '',
      messages: raw
          .map(
            (e) => ChatMessageDto.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      totalCount: (data['totalCount'] as num?)?.toInt() ?? 0,
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
      hasMore: data['hasMore'] as bool? ?? false,
      page: (data['page'] as num?)?.toInt() ?? 1,
      pageSize: (data['pageSize'] as num?)?.toInt() ?? 50,
    );
  }

  @override
  List<Object?> get props => [conversationId, messages.length];
}

class ConversationDetailDto extends Equatable {
  final String conversationId;
  final String bookingId;
  final String? otherPartyName;
  final String? otherPartyPhoto;
  final bool isOtherPartyOnline;

  const ConversationDetailDto({
    required this.conversationId,
    required this.bookingId,
    this.otherPartyName,
    this.otherPartyPhoto,
    this.isOtherPartyOnline = false,
  });

  factory ConversationDetailDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return ConversationDetailDto(
      conversationId: data['conversationId']?.toString() ?? '',
      bookingId: data['bookingId']?.toString() ?? '',
      otherPartyName: data['otherPartyName']?.toString(),
      otherPartyPhoto: data['otherPartyPhoto']?.toString(),
      isOtherPartyOnline: data['isOtherPartyOnline'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [conversationId, bookingId, isOtherPartyOnline];
}

class ConversationListItemDto extends Equatable {
  final String conversationId;
  final String bookingId;
  final String bookingReference;
  final int consultationType;
  final String? otherPartyName;
  final String? otherPartyPhoto;
  final String? otherPartyRole;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isActive;

  const ConversationListItemDto({
    required this.conversationId,
    required this.bookingId,
    required this.bookingReference,
    this.consultationType = 0,
    this.otherPartyName,
    this.otherPartyPhoto,
    this.otherPartyRole,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isActive = false,
  });

  factory ConversationListItemDto.fromJson(Map<String, dynamic> json) {
    return ConversationListItemDto(
      conversationId: json['conversationId']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      consultationType: (json['consultationType'] as num?)?.toInt() ?? 0,
      otherPartyName: json['otherPartyName']?.toString(),
      otherPartyPhoto: json['otherPartyPhoto']?.toString(),
      otherPartyRole: json['otherPartyRole']?.toString(),
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: _parseDate(json['lastMessageAt']),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [bookingId, lastMessage];
}

/// One row per healer/patient in GET /chat/conversations (v2 grouped inbox).
class ChatInboxEntryDto extends Equatable {
  final String otherPartyUserId;
  final String otherPartyName;
  final String? otherPartyPhoto;
  final String otherPartyRole;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int totalUnreadCount;
  final int bookingCount;

  const ChatInboxEntryDto({
    required this.otherPartyUserId,
    required this.otherPartyName,
    this.otherPartyPhoto,
    this.otherPartyRole = 'Healer',
    this.lastMessage,
    this.lastMessageAt,
    this.totalUnreadCount = 0,
    this.bookingCount = 1,
  });

  factory ChatInboxEntryDto.fromJson(Map<String, dynamic> json) {
    return ChatInboxEntryDto(
      otherPartyUserId: json['otherPartyUserId']?.toString() ?? '',
      otherPartyName: json['otherPartyName']?.toString() ?? 'Healer',
      otherPartyPhoto: json['otherPartyPhoto']?.toString(),
      otherPartyRole: json['otherPartyRole']?.toString() ?? 'Healer',
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: _parseDate(json['lastMessageAt']),
      totalUnreadCount: (json['totalUnreadCount'] as num?)?.toInt() ??
          (json['unreadCount'] as num?)?.toInt() ??
          0,
      bookingCount: (json['bookingCount'] as num?)?.toInt() ?? 1,
    );
  }

  ChatInboxEntryDto copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? totalUnreadCount,
    int? bookingCount,
  }) {
    return ChatInboxEntryDto(
      otherPartyUserId: otherPartyUserId,
      otherPartyName: otherPartyName,
      otherPartyPhoto: otherPartyPhoto,
      otherPartyRole: otherPartyRole,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      bookingCount: bookingCount ?? this.bookingCount,
    );
  }

  @override
  List<Object?> get props => [
    otherPartyUserId,
    lastMessage,
    lastMessageAt,
    totalUnreadCount,
  ];
}

class ConversationUpdatedEvent extends Equatable {
  final String bookingId;
  final String otherPartyUserId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final int unreadCount;

  const ConversationUpdatedEvent({
    required this.bookingId,
    required this.otherPartyUserId,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    this.unreadCount = 0,
  });

  factory ConversationUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return ConversationUpdatedEvent(
      bookingId: json['bookingId']?.toString() ?? '',
      otherPartyUserId: json['otherPartyUserId']?.toString() ?? '',
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: _parseDate(json['lastMessageAt']),
      lastMessageSenderId: json['lastMessageSenderId']?.toString(),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [bookingId, otherPartyUserId, lastMessageAt];
}

class ChatBookingChatDto extends Equatable {
  final String conversationId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isActive;
  final List<ChatMessageDto> messages;

  const ChatBookingChatDto({
    required this.conversationId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.isActive = false,
    this.messages = const [],
  });

  factory ChatBookingChatDto.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List? ?? [];
    return ChatBookingChatDto(
      conversationId: json['conversationId']?.toString() ?? '',
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: _parseDate(json['lastMessageAt']),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      messages: rawMessages
          .map(
            (e) => ChatMessageDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [conversationId, isActive, messages.length];
}

class ChatBookingItemDto extends Equatable {
  final String bookingId;
  final String bookingReference;
  final int consultationType;
  final DateTime? scheduledStartAt;
  final String bookingStatus;
  final int? actualDurationSeconds;
  final int? billedMinutes;
  final int? freeMinutesApplied;
  final double pricePerMinute;
  final int freeMinutes;
  final double? fixedPrice;
  final double? amountCharged;
  final double? amountRefunded;
  final double holdAmount;
  final String? conversationId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool bookingChatIsActive;
  final List<ChatBookingChatDto> chats;
  final List<ChatMessageDto> bookingMessages;

  const ChatBookingItemDto({
    required this.bookingId,
    required this.bookingReference,
    this.consultationType = 0,
    this.scheduledStartAt,
    this.bookingStatus = '',
    this.actualDurationSeconds,
    this.billedMinutes,
    this.freeMinutesApplied,
    this.pricePerMinute = 0,
    this.freeMinutes = 0,
    this.fixedPrice,
    this.amountCharged,
    this.amountRefunded,
    this.holdAmount = 0,
    this.conversationId,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.bookingChatIsActive = false,
    this.chats = const [],
    this.bookingMessages = const [],
  });

  static bool _looksLikeMessageMap(Map<String, dynamic> json) {
    return json.containsKey('messageId') ||
        (json.containsKey('content') && json.containsKey('messageType'));
  }

  static List<ChatMessageDto> _parseMessageList(List raw) {
    final messages = <ChatMessageDto>[];
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        final message = ChatMessageDto.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (message.messageId.isNotEmpty ||
            message.content.isNotEmpty ||
            message.attachment != null) {
          messages.add(message);
        }
      } catch (_) {}
    }
    messages.sort((a, b) {
      final aAt = a.createdAt;
      final bAt = b.createdAt;
      if (aAt == null && bAt == null) return 0;
      if (aAt == null) return -1;
      if (bAt == null) return 1;
      return aAt.compareTo(bAt);
    });
    return messages;
  }

  factory ChatBookingItemDto.fromJson(Map<String, dynamic> json) {
    final rawChats = json['chats'] as List? ?? [];
    final rawMessages = json['messages'] as List? ?? [];

    var parsedChats = <ChatBookingChatDto>[];
    var parsedBookingMessages = <ChatMessageDto>[];

    if (rawChats.isNotEmpty) {
      final first = Map<String, dynamic>.from(rawChats.first as Map);
      if (_looksLikeMessageMap(first)) {
        parsedBookingMessages = _parseMessageList(rawChats);
      } else {
        parsedChats = rawChats
            .map(
              (e) => ChatBookingChatDto.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }
    }

    if (rawMessages.isNotEmpty) {
      parsedBookingMessages = [
        ...parsedBookingMessages,
        ..._parseMessageList(rawMessages),
      ];
    }

    return ChatBookingItemDto(
      bookingId: json['bookingId']?.toString() ?? '',
      bookingReference: json['bookingReference']?.toString() ?? '',
      consultationType: (json['consultationType'] as num?)?.toInt() ?? 0,
      scheduledStartAt: _parseDate(json['scheduledStartAt']),
      bookingStatus: json['bookingStatus']?.toString() ?? '',
      actualDurationSeconds: (json['actualDurationSeconds'] as num?)?.toInt(),
      billedMinutes: (json['billedMinutes'] as num?)?.toInt(),
      freeMinutesApplied: (json['freeMinutesApplied'] as num?)?.toInt(),
      pricePerMinute: (json['pricePerMinute'] as num?)?.toDouble() ?? 0,
      freeMinutes: (json['freeMinutes'] as num?)?.toInt() ?? 0,
      fixedPrice: (json['fixedPrice'] as num?)?.toDouble(),
      amountCharged: (json['amountCharged'] as num?)?.toDouble(),
      amountRefunded: (json['amountRefunded'] as num?)?.toDouble(),
      holdAmount: (json['holdAmount'] as num?)?.toDouble() ?? 0,
      conversationId: json['conversationId']?.toString(),
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: _parseDate(json['lastMessageAt']),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      bookingChatIsActive: json['isActive'] as bool? ?? false,
      chats: parsedChats,
      bookingMessages: parsedBookingMessages,
    );
  }

  ChatBookingChatDto? get primaryChat {
    if (conversationId != null && conversationId!.isNotEmpty) {
      return ChatBookingChatDto(
        conversationId: conversationId!,
        lastMessage: lastMessage,
        lastMessageAt: lastMessageAt,
        unreadCount: unreadCount,
        isActive: bookingChatIsActive,
      );
    }
    return chats.isNotEmpty ? chats.first : null;
  }

  bool get isActive {
    final status = bookingStatus.toLowerCase();
    if (status == 'active') return true;
    if (status == 'confirmed' && chats.any((c) => c.isActive)) return true;
    return false;
  }

  /// Messages from GET /chat/conversations/{id} — no separate history call.
  List<ChatMessageDto> get conversationMessages {
    if (bookingMessages.isNotEmpty) {
      return bookingMessages
          .map((m) => m.copyWith(bookingId: bookingId))
          .toList();
    }
    for (final chat in chats) {
      if (chat.messages.isNotEmpty) {
        return chat.messages
            .map((m) => m.copyWith(bookingId: bookingId))
            .toList();
      }
    }
    final preview = lastMessage?.trim() ?? primaryChat?.lastMessage?.trim();
    final previewAt = lastMessageAt ?? primaryChat?.lastMessageAt;
    if (preview != null && preview.isNotEmpty) {
      return [
        ChatMessageDto(
          messageId: 'preview-$bookingId',
          bookingId: bookingId,
          senderId: 'system',
          senderName: 'System',
          senderRole: 'System',
          content: preview,
          messageType: 'System',
          createdAt: previewAt,
        ),
      ];
    }
    return const [];
  }

  String get consultationTypeLabel {
    switch (consultationType) {
      case 1:
        return 'Audio';
      case 2:
        return 'Video';
      default:
        return 'Chat';
    }
  }

  String get formattedDuration {
    final seconds = actualDurationSeconds;
    if (seconds == null) return '—';
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    if (minutes == 0) return '$remainder sec';
    if (remainder == 0) return '$minutes min';
    return '$minutes min $remainder sec';
  }

  @override
  List<Object?> get props => [bookingId, bookingReference, bookingStatus];
}

class ChatHealerBookingsResponse extends Equatable {
  final String otherPartyUserId;
  final String otherPartyName;
  final String? otherPartyPhoto;
  final String otherPartyRole;
  final List<ChatBookingItemDto> bookings;

  const ChatHealerBookingsResponse({
    required this.otherPartyUserId,
    required this.otherPartyName,
    this.otherPartyPhoto,
    this.otherPartyRole = 'Healer',
    this.bookings = const [],
  });

  factory ChatHealerBookingsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final raw = data['bookings'] as List? ?? [];
    return ChatHealerBookingsResponse(
      otherPartyUserId: data['otherPartyUserId']?.toString() ?? '',
      otherPartyName: data['otherPartyName']?.toString() ?? 'Healer',
      otherPartyPhoto: data['otherPartyPhoto']?.toString(),
      otherPartyRole: data['otherPartyRole']?.toString() ?? 'Healer',
      bookings: raw
          .map(
            (e) => ChatBookingItemDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [otherPartyUserId, bookings.length];
}

class ChatBookingMessageGroup extends Equatable {
  final ChatBookingItemDto booking;
  final List<ChatMessageDto> messages;
  final bool hasMoreHistory;
  final int historyPage;

  const ChatBookingMessageGroup({
    required this.booking,
    this.messages = const [],
    this.hasMoreHistory = false,
    this.historyPage = 1,
  });

  ChatBookingMessageGroup copyWith({
    ChatBookingItemDto? booking,
    List<ChatMessageDto>? messages,
    bool? hasMoreHistory,
    int? historyPage,
  }) {
    return ChatBookingMessageGroup(
      booking: booking ?? this.booking,
      messages: messages ?? this.messages,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      historyPage: historyPage ?? this.historyPage,
    );
  }

  @override
  List<Object?> get props => [booking.bookingId, messages.length];
}

bool _readByOtherFromJson(Map<String, dynamic> json) {
  final readBy = json['readBy'];
  if (readBy is List && readBy.isNotEmpty) return true;
  return json['isReadByOther'] as bool? ?? false;
}

AttachmentInfo? _parseAttachment(Map<String, dynamic> data) {
  final raw =
      data['attachment'] ?? data['Attachment'] ?? data['attachmentJson'];
  if (raw is Map) {
    return AttachmentInfo.fromJson(Map<String, dynamic>.from(raw));
  }
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return AttachmentInfo.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
  }
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

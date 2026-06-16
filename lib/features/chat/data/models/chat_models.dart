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
      idempotencyKey:
          (data['idempotencyKey'] ?? data['IdempotencyKey'])?.toString(),
      reactions: rawReactions
          .map(
            (e) => ChatReactionDto.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }

  ChatMessageDto copyWith({
    String? messageId,
    String? content,
    bool? isEdited,
    bool? isDeleted,
    bool? isPending,
    bool? isReadByMe,
    bool? isDelivered,
    bool? isReadByOther,
    String? idempotencyKey,
    List<ChatReactionDto>? reactions,
  }) {
    return ChatMessageDto(
      messageId: messageId ?? this.messageId,
      bookingId: bookingId,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      content: content ?? this.content,
      messageType: messageType,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isReadByMe: isReadByMe ?? this.isReadByMe,
      isDelivered: isDelivered ?? this.isDelivered,
      isReadByOther: isReadByOther ?? this.isReadByOther,
      createdAt: createdAt,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      isPending: isPending ?? this.isPending,
      reactions: reactions ?? this.reactions,
    );
  }

  @override
  List<Object?> get props => [messageId, content, isPending, reactions];
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
          .map((e) => ChatMessageDto.fromJson(Map<String, dynamic>.from(e as Map)))
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

bool _readByOtherFromJson(Map<String, dynamic> json) {
  final readBy = json['readBy'];
  if (readBy is List && readBy.isNotEmpty) return true;
  return json['isReadByOther'] as bool? ?? false;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

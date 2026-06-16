import 'package:equatable/equatable.dart';

class ChatReactionDto extends Equatable {
  final String emoji;
  final List<String> userIds;

  const ChatReactionDto({required this.emoji, this.userIds = const []});

  factory ChatReactionDto.fromJson(Map<String, dynamic> json) {
    final raw = json['userIds'] ?? json['users'];
    return ChatReactionDto(
      emoji: json['emoji']?.toString() ?? '',
      userIds: raw is List
          ? raw.map((e) => e.toString()).toList()
          : const [],
    );
  }

  bool hasUser(String userId) =>
      userId.isNotEmpty && userIds.contains(userId);

  ChatReactionDto copyWith({List<String>? userIds}) {
    return ChatReactionDto(
      emoji: emoji,
      userIds: userIds ?? this.userIds,
    );
  }

  @override
  List<Object?> get props => [emoji, userIds];
}

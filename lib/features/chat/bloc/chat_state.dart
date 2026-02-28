import 'package:equatable/equatable.dart';

enum MessageStatus { sent, delivered, read }

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isMe;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    this.text = '',
    this.imageUrl,
    required this.timestamp,
    required this.isMe,
    this.status = MessageStatus.read,
  });

  @override
  List<Object?> get props => [id, text, imageUrl, timestamp, isMe, status];
}

class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String healerName;
  final String healerImage;
  final double healerPrice;
  final double walletBalance;
  final String sessionTime;
  final double sessionCost;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.healerName = 'Dr. Liam Johnson',
    this.healerImage = 'assets/image/doctorprofile.png',
    this.healerPrice = 10,
    this.walletBalance = 150.0,
    this.sessionTime = '17:02',
    this.sessionCost = 55.0,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? healerName,
    String? healerImage,
    double? healerPrice,
    double? walletBalance,
    String? sessionTime,
    double? sessionCost,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      healerName: healerName ?? this.healerName,
      healerImage: healerImage ?? this.healerImage,
      healerPrice: healerPrice ?? this.healerPrice,
      walletBalance: walletBalance ?? this.walletBalance,
      sessionTime: sessionTime ?? this.sessionTime,
      sessionCost: sessionCost ?? this.sessionCost,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    isTyping,
    healerName,
    healerImage,
    healerPrice,
    walletBalance,
    sessionTime,
    sessionCost,
  ];
}

import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatHistory extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String text;
  const SendMessage(this.text);

  @override
  List<Object?> get props => [text];
}

class SendImageMessage extends ChatEvent {
  final String imagePath;
  const SendImageMessage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ReceiveMessage extends ChatEvent {
  final String text;
  const ReceiveMessage(this.text);

  @override
  List<Object?> get props => [text];
}

class ToggleTypingIndicator extends ChatEvent {
  final bool isTyping;
  const ToggleTypingIndicator(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

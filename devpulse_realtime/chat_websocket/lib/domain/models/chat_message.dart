class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;
}

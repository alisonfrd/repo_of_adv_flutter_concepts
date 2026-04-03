import 'package:chat_websocket/domain/models/chat_message.dart';
import 'package:chat_websocket/domain/models/connection_status.dart';

abstract interface class ChatRepository {
  Stream<List<ChatMessage>> watchMessages();

  Stream<Set<String>> watchOnlineUsers();

  Stream<ConnectionStatus> watchConnectionStatus();

  Future<void> connect({
    required String roomId,
    required String userId,
    required String userName,
  });

  Future<void> sendMessage(String content);

  Future<void> startTyping();

  Future<void> stopTyping();

  Future<void> disconnect();
}

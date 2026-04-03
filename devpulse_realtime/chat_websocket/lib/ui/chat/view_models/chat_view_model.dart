import 'package:chat_websocket/domain/models/connection_status.dart';
import 'package:chat_websocket/domain/repositories/chat_repository.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/chat_message.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatViewModel({required ChatRepository chatRepository})
    : _chatRepository = chatRepository;

  final List<ChatMessage> _messages = const [];
  final Set<String> _onlineUsers = const {};
  final ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;

  List<ChatMessage> get messages => _messages;
  Set<String> get onlineUsers => _onlineUsers;
  ConnectionStatus get connectionStatus => _connectionStatus;
}

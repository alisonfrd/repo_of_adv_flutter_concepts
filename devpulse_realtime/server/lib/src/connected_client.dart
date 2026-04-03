import 'dart:io';

class ConnectedClient {
  final String userId;
  final String userName;
  final WebSocket socket;

  const ConnectedClient({
    required this.userId,
    required this.userName,
    required this.socket,
  });

  Map<String, dynamic> toPresenceJson() {
    return {'userId': userId, 'userName': userName};
  }
}

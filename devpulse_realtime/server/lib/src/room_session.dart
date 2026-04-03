import 'dart:convert';

import 'package:realtime_contracts/realtime_contracts.dart';

import 'connected_client.dart';

class RoomSession {
  RoomSession({required this.roomId});

  final String roomId;
  final Map<String, ConnectedClient> _clientsByUserId = {};

  bool get isEmpty => _clientsByUserId.isEmpty;

  void addClient(ConnectedClient client) {
    _clientsByUserId[client.userId] = client;
  }

  void removeClient(String userId) {
    _clientsByUserId.remove(userId);
  }

  List<Map<String, dynamic>> onlineUsersJson() {
    return _clientsByUserId.values
        .map((client) => client.toPresenceJson())
        .toList(growable: false);
  }

  Future<void> broadcast(
    SocketEnvelope envelope, {
    String? excludeUserId,
  }) async {
    final encoded = jsonEncode(envelope.toJson());

    for (final entry in _clientsByUserId.entries) {
      if (entry.key == excludeUserId) continue;
      entry.value.socket.add(encoded);
    }
  }
}

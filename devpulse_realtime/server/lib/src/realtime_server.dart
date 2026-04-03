import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:realtime_contracts/realtime_contracts.dart';

import 'connected_client.dart';
import 'room_session.dart';

class RealtimeServer {
  RealtimeServer();

  final Map<String, RoomSession> _rooms = {};
  HttpServer? _httpServer;

  Future<void> start({InternetAddress? address, int port = 8080}) async {
    final bindAddress = address ?? InternetAddress.anyIPv4;

    _httpServer = await HttpServer.bind(bindAddress, port);

    print(
      'Realtime server running on ws://${bindAddress.address}:${_httpServer!.port}/ws',
    );

    await for (final request in _httpServer!) {
      await _handleRequest(request);
    }
  }

  Future<void> stop() async {
    await _httpServer?.close(force: true);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.uri.path == '/health') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write('ok');
      await request.response.close();
      return;
    }

    if (request.uri.path != '/ws') {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write('Route not found');
      await request.response.close();
      return;
    }

    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write('Expected a valid WebSocket upgrade request');
      await request.response.close();
      return;
    }

    final socket = await WebSocketTransformer.upgrade(request);
    socket.pingInterval = const Duration(seconds: 20);

    _handleSocket(socket);
  }

  void _handleSocket(WebSocket socket) {
    String? currentRoomId;
    String? currentUserId;
    String? currentUserName;
    var isCleanedUp = false;

    Future<void> cleanup() async {
      if (isCleanedUp) return;
      isCleanedUp = true;

      if (currentRoomId == null || currentUserId == null) return;

      final room = _rooms[currentRoomId];
      if (room == null) return;

      room.removeClient(currentUserId!);

      if (room.isEmpty) {
        _rooms.remove(currentRoomId);
        return;
      }

      await room.broadcast(
        _presenceEnvelope(roomId: currentRoomId!, room: room),
      );
    }

    Future<void> handleIncoming(dynamic rawMessage) async {
      if (rawMessage is! String) {
        await _sendError(
          socket,
          message: 'Only text JSON messages are supported',
        );
        return;
      }

      final envelope = _tryDecodeEnvelope(rawMessage);
      if (envelope == null) {
        await _sendError(socket, message: 'Invalid JSON envelope');
        return;
      }

      switch (envelope.type) {
        case SocketEventType.joinRoom:
          final roomId = _requiredString(envelope.payload, 'roomId');
          final userId = _requiredString(envelope.payload, 'userId');
          final userName = _requiredString(envelope.payload, 'userName');

          if (roomId == null || userId == null || userName == null) {
            await _sendError(
              socket,
              message: 'join_room requires roomId, userId and userName',
            );
            return;
          }

          if (currentRoomId != null && currentRoomId != roomId) {
            await cleanup();
          }

          currentRoomId = roomId;
          currentUserId = userId;
          currentUserName = userName;

          final room = _rooms.putIfAbsent(
            roomId,
            () => RoomSession(roomId: roomId),
          );

          room.addClient(
            ConnectedClient(userId: userId, userName: userName, socket: socket),
          );

          await _sendEnvelope(
            socket,
            SocketEnvelope(
              type: SocketEventType.roomJoined,
              timestamp: DateTime.now().toUtc(),
              payload: {
                'roomId': roomId,
                'userId': userId,
                'userName': userName,
                'onlineUsers': room.onlineUsersJson(),
              },
            ),
          );

          await room.broadcast(_presenceEnvelope(roomId: roomId, room: room));
          return;

        case SocketEventType.sendMessage:
          if (currentRoomId == null ||
              currentUserId == null ||
              currentUserName == null) {
            await _sendError(
              socket,
              message: 'You must join a room before sending messages',
            );
            return;
          }

          final content = _requiredString(envelope.payload, 'content');
          if (content == null) {
            await _sendError(socket, message: 'send_message requires content');
            return;
          }

          final room = _rooms[currentRoomId];
          if (room == null) {
            await _sendError(socket, message: 'Room not found');
            return;
          }

          final now = DateTime.now().toUtc();

          await room.broadcast(
            SocketEnvelope(
              type: SocketEventType.messageReceived,
              timestamp: now,
              payload: {
                'id': _messageId(),
                'roomId': currentRoomId,
                'senderId': currentUserId,
                'senderName': currentUserName,
                'content': content,
                'sentAt': now.toIso8601String(),
              },
            ),
          );
          return;

        case SocketEventType.typingStarted:
          if (currentRoomId == null ||
              currentUserId == null ||
              currentUserName == null) {
            return;
          }

          final room = _rooms[currentRoomId];
          if (room == null) return;

          await room.broadcast(
            SocketEnvelope(
              type: SocketEventType.typingStarted,
              timestamp: DateTime.now().toUtc(),
              payload: {
                'roomId': currentRoomId,
                'userId': currentUserId,
                'userName': currentUserName,
              },
            ),
            excludeUserId: currentUserId,
          );
          return;

        case SocketEventType.typingStopped:
          if (currentRoomId == null ||
              currentUserId == null ||
              currentUserName == null) {
            return;
          }

          final room = _rooms[currentRoomId];
          if (room == null) return;

          await room.broadcast(
            SocketEnvelope(
              type: SocketEventType.typingStopped,
              timestamp: DateTime.now().toUtc(),
              payload: {
                'roomId': currentRoomId,
                'userId': currentUserId,
                'userName': currentUserName,
              },
            ),
            excludeUserId: currentUserId,
          );
          return;

        case SocketEventType.roomJoined:
        case SocketEventType.messageReceived:
        case SocketEventType.presenceUpdated:
        case SocketEventType.error:
          await _sendError(
            socket,
            message: 'Unsupported client event: ${envelope.type.wireValue}',
          );
          return;
      }
    }

    unawaited(() async {
      try {
        await for (final rawMessage in socket) {
          await handleIncoming(rawMessage);
        }
      } catch (error, stackTrace) {
        print('Socket error: $error');
        print(stackTrace);
      } finally {
        await cleanup();
      }
    }());
  }

  SocketEnvelope _presenceEnvelope({
    required String roomId,
    required RoomSession room,
  }) {
    return SocketEnvelope(
      type: SocketEventType.presenceUpdated,
      timestamp: DateTime.now().toUtc(),
      payload: {'roomId': roomId, 'onlineUsers': room.onlineUsersJson()},
    );
  }

  Future<void> _sendEnvelope(WebSocket socket, SocketEnvelope envelope) async {
    socket.add(jsonEncode(envelope.toJson()));
  }

  Future<void> _sendError(WebSocket socket, {required String message}) async {
    await _sendEnvelope(
      socket,
      SocketEnvelope(
        type: SocketEventType.error,
        timestamp: DateTime.now().toUtc(),
        payload: {'message': message},
      ),
    );
  }

  SocketEnvelope? _tryDecodeEnvelope(String rawMessage) {
    try {
      final decoded = jsonDecode(rawMessage);
      if (decoded is! Map) return null;

      return SocketEnvelope.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  String? _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is! String) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    return trimmed;
  }

  String _messageId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}

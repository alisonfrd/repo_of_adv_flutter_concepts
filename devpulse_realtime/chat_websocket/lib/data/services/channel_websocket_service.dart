import 'dart:async';
import 'dart:convert';

import 'package:realtime_contracts/realtime_contracts.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'websocket_service.dart';

class ChannelWebsocketService implements WebsocketService {
  final StreamController<SocketEnvelope> _eventsController =
      StreamController<SocketEnvelope>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  bool _manualDisconnect = false;

  @override
  Future<void> connect(Uri uri) async {
    await disconnect();

    _manualDisconnect = false;
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;
    _subscription = channel.stream.listen(
      (rawMessage) {
        if (rawMessage is! String) {
          const FormatException('Only text WebSocket messages are supported');
          return;
        }

        final decoded = jsonDecode(rawMessage);
        if (decoded is! Map) {
          _eventsController.addError(
            const FormatException('Invalid JSON envelop'),
          );
          return;
        }
        final envelope = SocketEnvelope.fromJson(
          Map<String, dynamic>.from(decoded),
        );

        _eventsController.add(envelope);
      },
      onError: _eventsController.addError,
      onDone: () {
        if (_manualDisconnect) return;

        _eventsController.addError(
          SocketDisconnectedException(
            closeCode: channel.closeCode,
            closeReason: channel.closeReason,
          ),
        );
      },
      cancelOnError: false,
    );
  }

  @override
  Future<void> disconnect({int? code, String? reason}) async {
    _manualDisconnect = true;

    await _subscription?.cancel();
    _subscription = null;

    final channel = _channel;
    _channel = null;

    await channel?.sink.close(code ?? status.normalClosure, reason);
  }

  @override
  Stream<SocketEnvelope> get events => _eventsController.stream;

  @override
  Future<void> send(SocketEnvelope envelope) async {
    final channel = _channel;
    if (channel == null) {
      throw StateError('Socket is not connected');
    }

    channel.sink.add(jsonEncode(envelope.toJson()));
  }

  Future<void> dispose() async {
    await disconnect(code: status.goingAway, reason: 'Application disposed');
    await _eventsController.close();
  }
}

class SocketDisconnectedException implements Exception {
  final int? closeCode;
  final String? closeReason;

  SocketDisconnectedException({
    required this.closeCode,
    required this.closeReason,
  });

  @override
  String toString() {
    return 'SocketDisconnectedException(closeCode: $closeCode, closeReason: $closeReason)';
  }
}

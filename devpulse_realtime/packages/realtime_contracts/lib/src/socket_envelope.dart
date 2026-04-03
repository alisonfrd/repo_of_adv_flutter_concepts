import 'socket_event_type.dart';

class SocketEnvelope {
  final SocketEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> payload;

  SocketEnvelope({
    required this.type,
    required this.timestamp,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.wireValue,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'payload': payload,
    };
  }

  factory SocketEnvelope.fromJson(Map<String, dynamic> json) {
    return SocketEnvelope(
      type: SocketEventType.fromWire(json['type'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
    );
  }
}

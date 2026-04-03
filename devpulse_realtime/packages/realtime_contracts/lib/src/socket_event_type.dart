enum SocketEventType {
  joinRoom('join_room'),
  roomJoined('room_joined'),
  sendMessage('send_message'),
  messageReceived('message_received'),
  typingStarted('typing_started'),
  typingStopped('typing_stopped'),
  presenceUpdated('presence_updated'),
  error('error');

  const SocketEventType(this.wireValue);

  final String wireValue;

  static SocketEventType fromWire(String value) {
    return SocketEventType.values.firstWhere(
      (type) => type.wireValue == value,
      orElse: () => SocketEventType.error,
    );
  }
}

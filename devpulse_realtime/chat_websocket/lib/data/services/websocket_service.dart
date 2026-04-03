import 'package:realtime_contracts/realtime_contracts.dart';

abstract interface class WebsocketService {
  Stream<SocketEnvelope> get events;

  Future<void> connect(Uri uri);

  Future<void> send(SocketEnvelope envelope);

  Future<void> disconnect({int? code, String? reason});
}

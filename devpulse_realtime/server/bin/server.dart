import 'package:server/server.dart';

Future<void> main() async {
  final server = RealtimeServer();
  await server.start();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_lab/features/profile/domain/user.dart';

final appNameProvider = Provider<String>((ref) {
  return 'RiverPod Lab';
});

final currentUserProvider = Provider<User>((ref) {
  return const User(
    id: 'u_001',
    email: 'alison@email.com',
    role: 'Flutter develop',
    name: 'Alison',
    level: 1,
  );
});

final userGreetingProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  final appName = ref.watch(appNameProvider);

  return 'Olá, ${user.name}. Bem-vindo ao $appName';
});

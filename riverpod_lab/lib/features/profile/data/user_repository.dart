import 'package:riverpod_lab/features/profile/domain/user.dart';

class UserRepository {
  Future<User> fechMe() async {
    await Future.delayed(const Duration(seconds: 1));

    return const User(
      id: 'u_001',
      name: 'Alison',
      email: 'alison@email.com',
      role: 'Flutter Developer',
      level: 3,
    );
  }
}

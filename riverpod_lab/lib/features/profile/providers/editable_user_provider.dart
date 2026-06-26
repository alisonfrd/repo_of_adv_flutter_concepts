import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user.dart';

class EditableUserProvider extends Notifier<User> {
  @override
  User build() {
    return const User(
      id: 'u_001',
      name: 'Alison',
      email: 'alison@email.com',
      role: 'Flutter Developer',
      level: 1,
    );
  }

  void changeName(String name) {
    state = User(
      id: state.id,
      email: state.email,
      role: state.role,
      name: name,
      level: state.level,
    );
  }

  void increaseLevel() {
    state = User(
      id: state.id,
      email: state.email,
      role: state.role,
      name: state.name,
      level: state.level + 1,
    );
  }
}

final editableUserProvider = NotifierProvider<EditableUserProvider, User>(
  EditableUserProvider.new,
);

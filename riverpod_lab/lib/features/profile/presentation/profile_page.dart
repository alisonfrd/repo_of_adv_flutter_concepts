import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_lab/features/profile/domain/providers/profile_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appName = ref.watch(appNameProvider);
    final user = ref.watch(currentUserProvider);
    final gretting = ref.watch(userGreetingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(appName)),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(gretting, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('Nome: ${user.name}'),
                Text('Email: ${user.email}'),
                Text('Cargo: ${user.role}'),
                Text('Nível: ${user.level}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

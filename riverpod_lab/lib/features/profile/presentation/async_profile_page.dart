import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_lab/features/profile/domain/providers/profile_providers.dart';

class AsyncProfilePage extends ConsumerWidget {
  const AsyncProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(asyncCurrentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil Assíncrono')),
      body: Center(
        child: switch (asyncUser) {
          AsyncData(:final value) => Padding(
            padding: const EdgeInsetsGeometry.all(16),
            child: Card(
              child: ListTile(
                title: Text(value.name),
                subtitle: Text('${value.email} • ${value.role}'),
                trailing: Text('Nível ${value.level}'),
              ),
            ),
          ),
          AsyncError(:final error) => Text('Error: $error'),
          _ => const CircularProgressIndicator(),
        },
      ),
    );
  }
}

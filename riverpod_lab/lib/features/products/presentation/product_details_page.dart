import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_lab/features/products/providers/product_providers.dart';

class ProductDetailsPage extends ConsumerWidget {
  final String productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do produto')),

      body: Center(
        child: switch (productAsync) {
          AsyncData(:final value) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value.description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'R\$ ${value.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AsyncError(:final error) => Center(child: Text('Erro: $error')),
          _ => Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

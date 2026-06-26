import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../providers/product_providers.dart';
import 'product_details_page.dart';

final productQueryProvider = StateProvider<String>((ref) {
  return '';
});

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(productQueryProvider);
    final productsAsync = ref.watch(productSearchProvider(query));
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar Produto',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(productQueryProvider.notifier).state = value;
              },
            ),
          ),
          RefreshIndicator(
            onRefresh: () async {
              print('Entrou na funcao');
              await ref.refresh(productSearchProvider(query).future);
            },
            child: switch (productsAsync) {
              AsyncData(:final value) => ListView.builder(
                shrinkWrap: true,

                itemCount: value.length,
                itemBuilder: (context, index) {
                  final product = value[index];

                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('R\$ ${product.price.toStringAsFixed(2)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailsPage(productId: product.id),
                        ),
                      );
                    },
                  );
                },
              ),
              AsyncError(:final error) => Center(child: Text('Erro: $error')),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          ref.invalidate(productSearchProvider(query));
        },
      ),
    );
  }
}

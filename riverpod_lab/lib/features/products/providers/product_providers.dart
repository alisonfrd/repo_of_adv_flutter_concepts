import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_lab/features/products/data/products_repository.dart';
import 'package:riverpod_lab/features/products/domain/product.dart';

final productRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository();
});

final productsProvider = FutureProvider<List<Product>>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProducts();
});

final productDetailsProvider = FutureProvider.autoDispose
    .family<Product, String>((ref, productId) {
      final repository = ref.watch(productRepositoryProvider);

      return repository.fetchProductById(productId);
    });

final productSearchProvider = FutureProvider.autoDispose
    .family<List<Product>, String>((ref, query) {
      final repository = ref.watch(productRepositoryProvider);
      if (query.trim().isEmpty) {
        return repository.fetchProducts();
      }
      return repository.searchProducts(query);
    });

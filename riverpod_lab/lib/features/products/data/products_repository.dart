import '../domain/product.dart';

class ProductsRepository {
  final List<Product> _products = const [
    Product(
      id: 'p1',
      name: 'Flutter Clean Architecture',
      description: 'Curso avançado de arquitetura Flutter.',
      price: 199.90,
    ),
    Product(
      id: 'p2',
      name: 'Riverpod Pros',
      description: 'Curso focado em estado, cache e testes.',
      price: 149.90,
    ),
    Product(
      id: 'p3',
      name: 'Dart Avançado',
      description: 'Curso sobre patterns, records, mixins e extensions.',
      price: 129.90,
    ),
  ];

  Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _products;
  }

  Future<Product> fetchProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _products.firstWhere(
      (product) => product.id == id,
      orElse: () => throw Exception('Produto não encontrado'),
    );
  }

  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final normalizedQuery = query.toLowerCase();

    return _products.where((product) {
      return product.name.toLowerCase().contains(normalizedQuery) ||
          product.description.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}

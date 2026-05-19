import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/database_helper.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(DatabaseHelper.instance);
});

final productsProvider = StateNotifierProvider<ProductNotifier, List<ProductModel>>((ref) {
  return ProductNotifier(ref.watch(productRepositoryProvider));
});

class ProductNotifier extends StateNotifier<List<ProductModel>> {
  final ProductRepository _repository;

  ProductNotifier(this._repository) : super([]) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = await _repository.getProducts();
  }

  Future<void> addProduct(ProductModel product) async {
    await _repository.addProduct(product);
    await loadProducts();
  }

  Future<void> updateProduct(ProductModel product) async {
    await _repository.updateProduct(product);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _repository.deleteProduct(id);
    await loadProducts();
  }

  Future<void> updateStock(int id, double quantity) async {
    await _repository.updateStock(id, quantity);
    await loadProducts();
  }
}

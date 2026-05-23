import 'package:chaudhary_traders/features/products/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<int> addProduct(ProductModel p);
  Future<void> updateProduct(ProductModel p);
  Future<void> deleteProduct(int id);

  Future<int> updateStock(int id, double quantity);
}

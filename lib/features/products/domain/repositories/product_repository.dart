import '../../../products/data/models/product_model.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProductById(int id);
  Future<int> addProduct(ProductModel p);
  Future<int> updateProduct(ProductModel p);
  Future<int> deleteProduct(int id);
  Future<int> updateStock(int id, double quantity);
}

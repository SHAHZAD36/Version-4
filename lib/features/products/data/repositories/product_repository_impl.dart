import '../../../../core/utils/database_helper.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper dbHelper;

  ProductRepositoryImpl(this.dbHelper);

  @override
  Future<List<ProductModel>> getProducts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => ProductModel.fromMap(maps[i]));
  }

  @override
  Future<ProductModel?> getProductById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ProductModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> addProduct(ProductModel product) async {
    final db = await dbHelper.database;
    return await db.insert('products', product.toMap());
  }

  @override
  Future<int> updateProduct(ProductModel product) async {
    final db = await dbHelper.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  @override
  Future<int> deleteProduct(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> updateStock(int id, double quantity) async {
    final db = await dbHelper.database;
    final product = await getProductById(id);
    if (product != null) {
      final newStock = product.currentStock + quantity;
      return await db.update(
        'products',
        {'current_stock': newStock},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }
}

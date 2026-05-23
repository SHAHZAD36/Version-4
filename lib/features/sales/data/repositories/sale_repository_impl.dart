import '../../../../core/utils/database_helper.dart'; // Correctly links to your database
import '../models/sale_model.dart';                // Correctly links to the Sale Model
import '../../domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final DatabaseHelper databaseHelper;

  SaleRepositoryImpl(this.databaseHelper);

  @override
  Future<List<SaleModel>> getSales() async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('sales', orderBy: 'id DESC');
    return maps.map((item) => SaleModel.fromJson(item)).toList();
  }

  // Logic to refresh and get only Today's sales (Daily Refresh)
  @override
  Future<List<SaleModel>> getTodaySales(String date) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'sales', 
      where: 'date LIKE ?', 
      whereArgs: ['$date%']
    );
    return maps.map((item) => SaleModel.fromJson(item)).toList();
  }

  @override
  Future<void> createSale(SaleModel sale, List<SaleItemModel> items) async {
    final db = await databaseHelper.database;
    await db.transaction((txn) async {
      int saleId = await txn.insert('sales', sale.toJson());
      for (var item in items) {
        await txn.insert('sale_items', {
          ...item.toJson(),
          'sale_id': saleId,
        });
      }
    });
  }

  @override
  Future<void> deleteSale(int id) async {
    final db = await databaseHelper.database;
    await db.delete('sales', where: 'id = ?', whereArgs: [id]);
    await db.delete('sale_items', where: 'sale_id = ?', whereArgs: [id]);
  }

  @override
  Future<void> updateSale(SaleModel sale) async {
    final db = await databaseHelper.database;
    await db.update(
      'sales', 
      sale.toJson(), 
      where: 'id = ?', 
      whereArgs: [sale.id]
    );
  }
}

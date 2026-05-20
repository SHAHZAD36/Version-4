import '../../../../core/utils/database_helper.dart';
import '../models/sale_model.dart';
import '../../domain/repositories/sale_repository.dart';

class SaleRepositoryImpl implements SaleRepository {
  final DatabaseHelper databaseHelper;
  SaleRepositoryImpl(this.databaseHelper);

  @override
  Future<List<SaleModel>> getSales() async {
    final db = await databaseHelper.database;
    final maps = await db.query('sales', orderBy: 'id DESC');
    return maps.map((item) => SaleModel.fromJson(item)).toList();
  }

  @override
  Future<List<SaleModel>> getTodaySales(String date) async {
    final db = await databaseHelper.database;
    final maps = await db.query('sales', where: 'date LIKE ?', whereArgs: ['$date%']);
    return maps.map((item) => SaleModel.fromJson(item)).toList();
  }

  @override
  Future<void> createSale(SaleModel sale, List<SaleItemModel> items) async {
    final db = await databaseHelper.database;
    await db.transaction((txn) async {
      // 1. Insert sale
      int saleId = await txn.insert('sales', sale.toJson());
      // 2. Insert sale items + deduct stock
      for (var item in items) {
        await txn.insert('sale_items', {...item.toJson(), 'sale_id': saleId});
        // DEDUCT STOCK — this was the missing piece!
        await txn.execute(
          'UPDATE products SET current_stock = current_stock - ? WHERE id = ?',
          [item.quantity, item.productId],
        );
      }
      // 3. Update customer balance if Credit sale
      if (sale.paymentType == 'Credit') {
        await txn.execute(
          'UPDATE customers SET current_balance = current_balance + ? WHERE id = ?',
          [sale.netAmount, sale.customerId],
        );
      }
    });
  }

  @override
  Future<void> deleteSale(int id) async {
    final db = await databaseHelper.database;
    // Restore stock before deleting
    final items = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [id]);
    await db.transaction((txn) async {
      for (var item in items) {
        await txn.execute(
          'UPDATE products SET current_stock = current_stock + ? WHERE id = ?',
          [item['quantity'], item['product_id']],
        );
      }
      await txn.delete('sale_items', where: 'sale_id = ?', whereArgs: [id]);
      await txn.delete('sales', where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<void> updateSale(SaleModel sale) async {
    final db = await databaseHelper.database;
    await db.update('sales', sale.toJson(), where: 'id = ?', whereArgs: [sale.id]);
  }
}

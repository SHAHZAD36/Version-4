import '../../../../core/utils/database_helper.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../models/purchase_model.dart';
class PurchaseRepositoryImpl implements PurchaseRepository {
  final DatabaseHelper dbHelper;
  PurchaseRepositoryImpl(this.dbHelper);
  @override Future<List<PurchaseModel>> getPurchases() async {
    return (await (await dbHelper.database).query('purchases', orderBy: 'date DESC')).map((m) => PurchaseModel.fromMap(m)).toList();
  }
  @override Future<int> addPurchase(PurchaseModel p) async {
    final db = await dbHelper.database;
    return db.transaction((txn) async {
      final id = await txn.insert('purchases', p.toMap());
      await txn.execute('UPDATE products SET current_stock = current_stock + ? WHERE id = ?', [p.quantity, p.productId]);
      return id;
    });
  }
}

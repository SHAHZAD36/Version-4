import '../../../../core/utils/database_helper.dart';
import '../../domain/repositories/collection_repository.dart';
import '../models/collection_model.dart';
class CollectionRepositoryImpl implements CollectionRepository {
  final DatabaseHelper dbHelper;
  CollectionRepositoryImpl(this.dbHelper);
  @override Future<List<CollectionModel>> getCollections() async {
    return (await (await dbHelper.database).query('collections', orderBy: 'date DESC')).map((m) => CollectionModel.fromMap(m)).toList();
  }
  @override Future<int> addCollection(CollectionModel c) async {
    final db = await dbHelper.database;
    return db.transaction((txn) async {
      final id = await txn.insert('collections', c.toMap());
      await txn.execute('UPDATE customers SET current_balance = current_balance - ? WHERE id = ?', [c.amount, c.customerId]);
      return id;
    });
  }
}

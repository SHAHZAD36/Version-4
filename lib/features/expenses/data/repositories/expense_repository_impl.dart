import '../../../../core/utils/database_helper.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';
class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper dbHelper;
  ExpenseRepositoryImpl(this.dbHelper);
  @override Future<List<ExpenseModel>> getExpenses() async {
    final db = await dbHelper.database;
    return (await db.query('expenses', orderBy: 'date DESC')).map((m) => ExpenseModel.fromMap(m)).toList();
  }
  @override Future<int> addExpense(ExpenseModel e) async => (await dbHelper.database).insert('expenses', e.toMap());
  @override Future<void> deleteExpense(int id) async => (await dbHelper.database).delete('expenses', where: 'id=?', whereArgs: [id]);
}

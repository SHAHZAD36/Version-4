import '../../../../core/utils/database_helper.dart';
import '../../domain/repositories/cash_book_repository.dart';
import '../models/cash_book_model.dart';
class CashBookRepositoryImpl implements CashBookRepository {
  final DatabaseHelper dbHelper;
  CashBookRepositoryImpl(this.dbHelper);
  @override Future<List<CashBookModel>> getEntries() async {
    return (await (await dbHelper.database).query('cash_book', orderBy: 'date DESC')).map((m) => CashBookModel.fromMap(m)).toList();
  }
  @override Future<int> addEntry(CashBookModel e) async => (await dbHelper.database).insert('cash_book', e.toMap());
}

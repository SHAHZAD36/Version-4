import '../../data/models/cash_book_model.dart';
abstract class CashBookRepository {
  Future<List<CashBookModel>> getEntries();
  Future<int> addEntry(CashBookModel e);
}

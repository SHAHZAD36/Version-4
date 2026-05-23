import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/database_helper.dart';
import '../../data/models/cash_book_model.dart';
import '../../data/repositories/cash_book_repository_impl.dart';
final cashBookRepoProvider = Provider((_) => CashBookRepositoryImpl(DatabaseHelper.instance));
final cashBookProvider = StateNotifierProvider<CashBookNotifier, List<CashBookModel>>((ref) => CashBookNotifier(ref.watch(cashBookRepoProvider)));
class CashBookNotifier extends StateNotifier<List<CashBookModel>> {
  final CashBookRepositoryImpl _r;
  CashBookNotifier(this._r) : super([]) { load(); }
  Future<void> load() async { state = await _r.getEntries(); }
  Future<void> add(CashBookModel e) async { await _r.addEntry(e); await load(); }
}

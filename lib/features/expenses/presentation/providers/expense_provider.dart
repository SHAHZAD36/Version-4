import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/database_helper.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository_impl.dart';
final expenseRepoProvider = Provider((_) => ExpenseRepositoryImpl(DatabaseHelper.instance));
final expensesProvider = StateNotifierProvider<ExpenseNotifier, List<ExpenseModel>>((ref) => ExpenseNotifier(ref.watch(expenseRepoProvider)));
class ExpenseNotifier extends StateNotifier<List<ExpenseModel>> {
  final ExpenseRepositoryImpl _r;
  ExpenseNotifier(this._r) : super([]) { load(); }
  Future<void> load() async { state = await _r.getExpenses(); }
  Future<void> add(ExpenseModel e) async { await _r.addExpense(e); await load(); }
  Future<void> delete(int id) async { await _r.deleteExpense(id); await load(); }
}

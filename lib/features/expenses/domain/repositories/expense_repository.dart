import '../../data/models/expense_model.dart';
abstract class ExpenseRepository {
  Future<List<ExpenseModel>> getExpenses();
  Future<int> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
}

import '../../../../core/utils/database_helper.dart';
import '../../domain/repositories/customer_repository.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final DatabaseHelper dbHelper;

  CustomerRepositoryImpl(this.dbHelper);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) => CustomerModel.fromMap(maps[i]));
  }

  @override
  Future<CustomerModel?> getCustomerById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CustomerModel.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> addCustomer(CustomerModel customer) async {
    final db = await dbHelper.database;
    return await db.insert('customers', customer.toMap());
  }

  @override
  Future<int> updateCustomer(CustomerModel customer) async {
    final db = await dbHelper.database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  @override
  Future<int> deleteCustomer(int id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> updateBalance(int id, double amount) async {
    final db = await dbHelper.database;
    final customer = await getCustomerById(id);
    if (customer != null) {
      final newBalance = customer.currentBalance + amount;
      return await db.update(
        'customers',
        {'current_balance': newBalance},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    return 0;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/database_helper.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(DatabaseHelper.instance);
});

final customersProvider = StateNotifierProvider<CustomerNotifier, List<CustomerModel>>((ref) {
  return CustomerNotifier(ref.watch(customerRepositoryProvider));
});

class CustomerNotifier extends StateNotifier<List<CustomerModel>> {
  final CustomerRepository _repository;

  CustomerNotifier(this._repository) : super([]) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = await _repository.getCustomers();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _repository.addCustomer(customer);
    await loadCustomers();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _repository.updateCustomer(customer);
    await loadCustomers();
  }

  Future<void> deleteCustomer(int id) async {
    await _repository.deleteCustomer(id);
    await loadCustomers();
  }
}

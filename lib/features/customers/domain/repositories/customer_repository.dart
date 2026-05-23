import '../../data/models/customer_model.dart';
abstract class CustomerRepository {
  Future<List<CustomerModel>> getCustomers();
  Future<int> addCustomer(CustomerModel c);
  Future<void> updateCustomer(CustomerModel c);
  Future<void> deleteCustomer(int id);
}

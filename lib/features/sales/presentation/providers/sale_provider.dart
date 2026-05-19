import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/database_helper.dart';
import '../../data/models/sale_model.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepositoryImpl(DatabaseHelper.instance);
});

final salesProvider = StateNotifierProvider<SaleNotifier, List<SaleModel>>((ref) {
  return SaleNotifier(ref.watch(saleRepositoryProvider), ref);
});

class SaleNotifier extends StateNotifier<List<SaleModel>> {
  final SaleRepository _repository;
  final Ref _ref;

  SaleNotifier(this._repository, this._ref) : super([]) {
    loadSales();

    // Add this inside the SaleNotifier class
Future<void> deleteSale(int id) async {
  final repository = ref.read(saleRepositoryProvider); // Make sure your repository provider name matches
await _repository.deleteSale(id);
state = await _repository.getSales();
}
  }

  Future<void> loadSales() async {
    state = await _repository.getSales();
  }

  Future<void> createSale(SaleModel sale, List<SaleItemModel> items) async {
    await _repository.createSale(sale, items);
    await loadSales();
    // Refresh products and customers to reflect stock and balance changes
    _ref.read(productsProvider.notifier).loadProducts();
    _ref.read(customersProvider.notifier).loadCustomers();
  }
}

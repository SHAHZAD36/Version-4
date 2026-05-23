import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sale_model.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../../../core/utils/database_helper.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

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
  }

  Future<void> loadSales() async {
    state = await _repository.getSales();
  }

  Future<void> createSale(SaleModel sale, List<SaleItemModel> items) async {
    await _repository.createSale(sale, items);
    await loadSales();
    // Refresh dashboard + products after sale
    _ref.read(productsProvider.notifier).loadProducts();
    _ref.read(dashboardProvider.notifier).loadStats();
  }

  Future<void> deleteSale(int id) async {
    await _repository.deleteSale(id);
    await loadSales();
    // Refresh dashboard + products after delete
    _ref.read(productsProvider.notifier).loadProducts();
    _ref.read(dashboardProvider.notifier).loadStats();
  }
}

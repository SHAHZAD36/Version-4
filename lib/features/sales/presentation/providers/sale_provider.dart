import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sale_model.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../../../core/utils/database_helper.dart';

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepositoryImpl(DatabaseHelper.instance);
});

final salesProvider = StateNotifierProvider<SaleNotifier, List<SaleModel>>((ref) {
  return SaleNotifier(ref.watch(saleRepositoryProvider));
});

class SaleNotifier extends StateNotifier<List<SaleModel>> {
  final SaleRepository _repository;

  SaleNotifier(this._repository) : super([]) {
    loadSales();
  }

  Future<void> loadSales() async {
    state = await _repository.getSales();
  }

  // CORRECTED DELETE METHOD:
  Future<void> deleteSale(int id) async {
    await _repository.deleteSale(id); // Use _repository directly
    await loadSales(); // Refresh the list
  }

  Future<void> createSale(SaleModel sale, List<SaleItemModel> items) async {
    await _repository.createSale(sale, items);
    await loadSales();
  }
}

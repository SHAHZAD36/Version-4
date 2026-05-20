import '../../data/models/sale_model.dart';

abstract class SaleRepository {
  Future<List<SaleModel>> getSales();
  Future<List<SaleModel>> getTodaySales(String date);
  Future<void> createSale(SaleModel sale, List<SaleItemModel> items);
  Future<void> deleteSale(int id);
  Future<void> updateSale(SaleModel sale);
}

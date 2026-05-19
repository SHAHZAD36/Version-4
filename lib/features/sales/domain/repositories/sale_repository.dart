import '../../data/models/sale_model.dart';
abstract class SaleRepository {
  Future<List<SaleModel>> getSales();
  Future<int> createSale(SaleModel sale, List<SaleItemModel> items);
  Future<List<SaleItemModel>> getSaleItems(int saleId);
}

import '../../data/models/sale_model.dart'; // IMPORTANT: This line was missing

abstract class SaleRepository {
  Future<List<SaleModel>> getSales();
  Future<void> createSale(SaleModel sale, List<SaleItemModel> items);
  Future<void> deleteSale(int id);
  // Add this for your 12 AM / Daily refresh feature
  Future<List<SaleModel>> getTodaySales(String date); 
}

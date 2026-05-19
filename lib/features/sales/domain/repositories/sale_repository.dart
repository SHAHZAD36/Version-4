abstract class SaleRepository {
  Future<List<SaleModel>> getSales();
  Future<void> createSale(SaleModel sale, List<SaleItemModel> items);
  // ADD THIS LINE:
  Future<void> deleteSale(int id); 
  // ... any other existing methods
}

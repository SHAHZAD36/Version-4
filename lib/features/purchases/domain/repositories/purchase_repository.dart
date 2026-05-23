import '../../data/models/purchase_model.dart';
abstract class PurchaseRepository {
  Future<List<PurchaseModel>> getPurchases();
  Future<int> addPurchase(PurchaseModel p);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/database_helper.dart';
import '../../data/models/purchase_model.dart';
import '../../data/repositories/purchase_repository_impl.dart';
import '../../../products/presentation/providers/product_provider.dart';
final purchaseRepoProvider = Provider((_) => PurchaseRepositoryImpl(DatabaseHelper.instance));
final purchasesProvider = StateNotifierProvider<PurchaseNotifier, List<PurchaseModel>>((ref) => PurchaseNotifier(ref.watch(purchaseRepoProvider), ref));
class PurchaseNotifier extends StateNotifier<List<PurchaseModel>> {
  final PurchaseRepositoryImpl _r; final Ref _ref;
  PurchaseNotifier(this._r, this._ref) : super([]) { load(); }
  Future<void> load() async { state = await _r.getPurchases(); }
  Future<void> add(PurchaseModel p) async { await _r.addPurchase(p); await load(); _ref.read(productsProvider.notifier).loadProducts(); }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/database_helper.dart';
import '../../data/models/collection_model.dart';
import '../../data/repositories/collection_repository_impl.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
final collectionRepoProvider = Provider((_) => CollectionRepositoryImpl(DatabaseHelper.instance));
final collectionsProvider = StateNotifierProvider<CollectionNotifier, List<CollectionModel>>((ref) => CollectionNotifier(ref.watch(collectionRepoProvider), ref));
class CollectionNotifier extends StateNotifier<List<CollectionModel>> {
  final CollectionRepositoryImpl _r; final Ref _ref;
  CollectionNotifier(this._r, this._ref) : super([]) { load(); }
  Future<void> load() async { state = await _r.getCollections(); }
  Future<void> add(CollectionModel c) async { await _r.addCollection(c); await load(); _ref.read(customersProvider.notifier).loadCustomers(); }
}

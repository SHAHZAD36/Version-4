import '../../data/models/collection_model.dart';
abstract class CollectionRepository {
  Future<List<CollectionModel>> getCollections();
  Future<int> addCollection(CollectionModel c);
}

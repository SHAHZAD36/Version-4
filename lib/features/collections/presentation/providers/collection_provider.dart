import 'package:flutter/material.dart';  // <-- YEH ADD KARO
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/utils/database_helper.dart';
import '../../data/models/collection_model.dart';

class CollectionNotifier extends StateNotifier<List<CollectionModel>> {
  CollectionNotifier() : super([]) {
    loadCollections();
  }

  Future loadCollections() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query('collections', orderBy: 'id DESC');
      state = result.map((e) => CollectionModel.fromMap(e)).toList();
    } catch (e) {
      state = [];
    }
  }

  Future addCollection(CollectionModel collection) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final id = await db.insert('collections', collection.toMap());
      
      // Update customer balance
      await db.rawUpdate(
        'UPDATE customers SET current_balance = current_balance - ? WHERE id = ?',
        [collection.amount, collection.customerId]
      );
      
      await loadCollections();
    } catch (e) {
      debugPrint('Error adding collection: $e');
    }
  }

  Future deleteCollection(int id) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final collection = await db.query('collections', where: 'id = ?', whereArgs: [id]);
      
      if (collection.isNotEmpty) {
        final amount = collection.first['amount'] as double;
        final customerId = collection.first['customer_id'] as int;
        
        // Restore customer balance
        await db.rawUpdate(
          'UPDATE customers SET current_balance = current_balance + ? WHERE id = ?',
          [amount, customerId]
        );
      }
      
      await db.delete('collections', where: 'id = ?', whereArgs: [id]);
      await loadCollections();
    } catch (e) {
      debugPrint('Error deleting collection: $e');
    }
  }
}

final collectionsProvider = StateNotifierProvider<CollectionNotifier, List<CollectionModel>>((ref) {
  return CollectionNotifier();
});

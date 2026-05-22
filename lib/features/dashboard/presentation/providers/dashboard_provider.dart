import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/utils/database_helper.dart';

class DashboardStats {
  final double todaySales;
  final double todayCollections;
  final double totalReceivable;
  final double totalStockValue;
  final List<Map<String, dynamic>> recentSales;
  final List<Map<String, dynamic>> lowStockProducts;

  DashboardStats({
    required this.todaySales,
    required this.todayCollections,
    required this.totalReceivable,
    required this.totalStockValue,
    required this.recentSales,
    required this.lowStockProducts,
  });
}

class DashboardNotifier extends StateNotifier<AsyncValue<DashboardStats>> {
  DashboardNotifier() : super(const AsyncValue.loading()) {
    loadStats();
  }

  Future loadStats() async {
    state = const AsyncValue.loading();
    try {
      final db = await DatabaseHelper.instance.database;
      final today = DateTime.now();
      final todayStr = '${today.day.toString().padLeft(2, '0')}-${today.month.toString().padLeft(2, '0')}-${today.year}';

      // Today's sales
      final salesResult = await db.rawQuery(
        "SELECT SUM(net_amount) as total FROM sales WHERE date LIKE ?",
        ['$todayStr%']
      );
      final todaySales = (salesResult.first['total'] as num?)?.toDouble() ?? 0;

      // Today's collections
      final collectionsResult = await db.rawQuery(
        "SELECT SUM(amount) as total FROM collections WHERE date LIKE ?",
        ['$todayStr%']
      );
      final todayCollections = (collectionsResult.first['total'] as num?)?.toDouble() ?? 0;

      // Total receivable
      final receivableResult = await db.rawQuery(
        "SELECT SUM(current_balance) as total FROM customers WHERE current_balance > 0"
      );
      final totalReceivable = (receivableResult.first['total'] as num?)?.toDouble() ?? 0;

      // Total stock value
      final stockResult = await db.rawQuery(
        "SELECT SUM(current_stock * sale_price) as total FROM products"
      );
      final totalStockValue = (stockResult.first['total'] as num?)?.toDouble() ?? 0;

      // Recent sales (last 10)
      final recentSalesResult = await db.rawQuery(
        '''SELECT s.*, c.shop_name 
           FROM sales s 
           LEFT JOIN customers c ON s.customer_id = c.id 
           ORDER BY s.id DESC LIMIT 10'''
      );

      // Low stock products
      final lowStockResult = await db.rawQuery(
        "SELECT * FROM products WHERE current_stock <= min_stock_level ORDER BY current_stock ASC LIMIT 10"
      );

      state = AsyncValue.data(DashboardStats(
        todaySales: todaySales,
        todayCollections: todayCollections,
        totalReceivable: totalReceivable,
        totalStockValue: totalStockValue,
        recentSales: recentSalesResult,
        lowStockProducts: lowStockResult,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardStats>>((ref) {
  return DashboardNotifier();
});

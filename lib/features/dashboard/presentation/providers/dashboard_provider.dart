import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final DatabaseHelper _db;
  DashboardNotifier(this._db) : super(const AsyncValue.loading()) { loadStats(); }

  Future<void> loadStats() async {
    try {
      state = const AsyncValue.loading();
      final db = await _db.database;
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

      final s1 = await db.rawQuery("SELECT COALESCE(SUM(net_amount),0) as t FROM sales WHERE date LIKE ?", ['%$todayStr%']);
      final s2 = await db.rawQuery("SELECT COALESCE(SUM(amount),0) as t FROM collections WHERE date LIKE ?", ['%$todayStr%']);
      final s3 = await db.rawQuery("SELECT COALESCE(SUM(current_balance),0) as t FROM customers WHERE current_balance > 0");
      final s4 = await db.rawQuery("SELECT COALESCE(SUM(current_stock * sale_price),0) as t FROM products");
      final lowStock = await db.rawQuery("SELECT * FROM products WHERE current_stock <= min_stock_level LIMIT 5");
      final recent = await db.rawQuery('''SELECT s.id, s.date, s.net_amount, s.payment_type, c.shop_name 
        FROM sales s LEFT JOIN customers c ON s.customer_id = c.id ORDER BY s.id DESC LIMIT 5''');

      state = AsyncValue.data(DashboardStats(
        todaySales: (s1.first['t'] as num).toDouble(),
        todayCollections: (s2.first['t'] as num).toDouble(),
        totalReceivable: (s3.first['t'] as num).toDouble(),
        totalStockValue: (s4.first['t'] as num).toDouble(),
        recentSales: List<Map<String, dynamic>>.from(recent),
        lowStockProducts: List<Map<String, dynamic>>.from(lowStock),
      ));
    } catch (e, st) { state = AsyncValue.error(e, st); }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardStats>>((ref) {
  return DashboardNotifier(DatabaseHelper.instance);
});

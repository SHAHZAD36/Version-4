import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../products/presentation/screens/product_list_screen.dart';
import '../../../customers/presentation/screens/customer_list_screen.dart';
import '../../../sales/presentation/screens/new_sale_screen.dart';
import '../../../expenses/presentation/screens/expense_list_screen.dart';
import '../../../purchases/presentation/screens/purchase_list_screen.dart';
import '../../../collections/presentation/screens/collection_list_screen.dart';
import '../../../cash_book/presentation/screens/cash_book_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getText(lang, 'app_title')),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(dashboardProvider.notifier).loadStats()),
        ],
      ),
      drawer: _buildDrawer(context, lang),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${AppStrings.getText(lang, 'error')}: $e')),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.read(dashboardProvider.notifier).loadStats(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // BANNER
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/images/banner.png', width: double.infinity, height: 120, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120, width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFFF9A825)]),
                    ),
                    child: Center(child: Text(AppStrings.getText(lang, 'app_title'),
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _summaryGrid(context, stats, lang),
              const SizedBox(height: 24),
              Text(AppStrings.getText(lang, 'recent_sales'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _recentSales(stats, lang),
              const SizedBox(height: 24),
              Text(AppStrings.getText(lang, 'low_stock'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _lowStock(stats, lang),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NewSaleScreen())),
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(AppStrings.getText(lang, 'new_sale')),
      ),
    );
  }

  Widget _summaryGrid(BuildContext context, DashboardStats s, AppLanguage lang) {
    final f = NumberFormat('#,##0');
    return GridView.count(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
      children: [
        _card(context, AppStrings.getText(lang, 'today_sales'), 'Rs. ${f.format(s.todaySales)}', Icons.trending_up, Colors.blue),
        _card(context, AppStrings.getText(lang, 'today_collections'), 'Rs. ${f.format(s.todayCollections)}', Icons.account_balance_wallet, Colors.green),
        _card(context, AppStrings.getText(lang, 'total_receivable'), 'Rs. ${f.format(s.totalReceivable)}', Icons.pending_actions, Colors.orange),
        _card(context, AppStrings.getText(lang, 'stock_value'), 'Rs. ${f.format(s.totalStockValue)}', Icons.inventory_2, Colors.purple),
      ],
    );
  }

  Widget _card(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(12), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28), const Spacer(),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600]), overflow: TextOverflow.ellipsis),
        ],
      )),
    );
  }

  Widget _recentSales(DashboardStats s, AppLanguage lang) {
    if (s.recentSales.isEmpty) return Card(child: Padding(padding: const EdgeInsets.all(16),
        child: Center(child: Text(AppStrings.getText(lang, 'no_sales')))));
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: s.recentSales.length, separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final sale = s.recentSales[i];
          final isCash = sale['payment_type'] == 'Cash';
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isCash ? Colors.green[100] : Colors.orange[100],
              child: Icon(isCash ? Icons.payments : Icons.credit_card,
                  color: isCash ? Colors.green : Colors.orange, size: 20),
            ),
            title: Text(sale['shop_name'] ?? AppStrings.getText(lang, 'unknown'), style: const TextStyle(fontSize: 14)),
            subtitle: Text(sale['date'] ?? '', style: const TextStyle(fontSize: 11)),
            trailing: Text('Rs. ${NumberFormat('#,##0').format(sale['net_amount'])}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _lowStock(DashboardStats s, AppLanguage lang) {
    if (s.lowStockProducts.isEmpty) {
      return Card(child: Padding(padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.check_circle, color: Colors.green), const SizedBox(width: 8),
          Text(AppStrings.getText(lang, 'stock_ok')),
        ])));
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: s.lowStockProducts.length, separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final p = s.lowStockProducts[i];
          return ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE),
                child: Icon(Icons.warning_amber, color: Colors.red, size: 20)),
            title: Text(p['name'] ?? '', style: const TextStyle(fontSize: 14)),
            subtitle: Text(p['brand'] ?? ''),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${p['current_stock']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              Text('min: ${p['min_stock_level']}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLanguage lang) {
    return Drawer(child: ListView(padding: EdgeInsets.zero, children: [
      DrawerHeader(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
          Image.asset('assets/icons/icon.png', height: 48, width: 48,
              errorBuilder: (_, __, ___) => const Icon(Icons.storefront, color: Colors.white, size: 48)),
          const SizedBox(height: 8),
          Text(AppStrings.getText(lang, 'app_title'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
          Text(AppStrings.getText(lang, 'inventory_title'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
        ]),
      ),
      _tile(context, Icons.dashboard, AppStrings.getText(lang, 'dashboard'), () => Navigator.pop(context)),
      _tile(context, Icons.inventory_2, AppStrings.getText(lang, 'products'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen())); }),
      _tile(context, Icons.people, AppStrings.getText(lang, 'customers'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerListScreen())); }),
      _tile(context, Icons.point_of_sale, AppStrings.getText(lang, 'sales'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const NewSaleScreen())); }),
      _tile(context, Icons.shopping_cart, AppStrings.getText(lang, 'purchases'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseListScreen())); }),
      _tile(context, Icons.account_balance_wallet, AppStrings.getText(lang, 'collections'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CollectionListScreen())); }),
      _tile(context, Icons.money_off, AppStrings.getText(lang, 'expenses'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseListScreen())); }),
      _tile(context, Icons.book, AppStrings.getText(lang, 'cash_book'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const CashBookScreen())); }),
      const Divider(),
      _tile(context, Icons.bar_chart, AppStrings.getText(lang, 'reports'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())); }),
      _tile(context, Icons.settings, AppStrings.getText(lang, 'settings'), () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); }),
    ]));
  }

  ListTile _tile(BuildContext context, IconData icon, String title, VoidCallback onTap) =>
      ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
}

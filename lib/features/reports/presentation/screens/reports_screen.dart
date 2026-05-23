import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/utils/database_helper.dart';
import 'report_service.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});
  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  Map<String, double> _summary = {};
  bool _loading = true;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);
    final db = await DatabaseHelper.instance.database;
    final s1 = await db.rawQuery("SELECT COALESCE(SUM(net_amount),0) as t FROM sales");
    final s2 = await db.rawQuery("SELECT COALESCE(SUM(amount),0) as t FROM collections");
    final s3 = await db.rawQuery("SELECT COALESCE(SUM(amount),0) as t FROM expenses");
    final s4 = await db.rawQuery("SELECT COALESCE(SUM(total_cost),0) as t FROM purchases");
    final s5 = await db.rawQuery("SELECT COALESCE(SUM(current_balance),0) as t FROM customers WHERE current_balance > 0");
    setState(() {
      _summary = {
        'sales': (s1.first['t'] as num).toDouble(),
        'collections': (s2.first['t'] as num).toDouble(),
        'expenses': (s3.first['t'] as num).toDouble(),
        'purchases': (s4.first['t'] as num).toDouble(),
        'receivable': (s5.first['t'] as num).toDouble(),
      };
      _loading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchData(String table,
      {String? joinCustomer}) async {
    final db = await DatabaseHelper.instance.database;
    if (joinCustomer == 'sales') {
      return await db.rawQuery(
          'SELECT s.*, c.shop_name FROM sales s LEFT JOIN customers c ON s.customer_id = c.id ORDER BY s.id DESC');
    }
    return await db.query(table, orderBy: 'id DESC');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final fmt = NumberFormat('#,##0');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getText(lang, 'reports')),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSummary),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Summary cards
                _summaryCard('Total Sales', _summary['sales'] ?? 0, Icons.trending_up, Colors.blue, fmt),
                _summaryCard('Total Collections', _summary['collections'] ?? 0, Icons.account_balance_wallet, Colors.green, fmt),
                _summaryCard('Total Receivable', _summary['receivable'] ?? 0, Icons.pending_actions, Colors.orange, fmt),
                _summaryCard('Total Purchases', _summary['purchases'] ?? 0, Icons.shopping_cart, Colors.purple, fmt),
                _summaryCard('Total Expenses', _summary['expenses'] ?? 0, Icons.money_off, Colors.red, fmt),
                _summaryCard('Net Profit (Est.)',
                    (_summary['sales'] ?? 0) - (_summary['purchases'] ?? 0) - (_summary['expenses'] ?? 0),
                    Icons.bar_chart, Colors.teal, fmt),
                const Divider(height: 32),
                const Text('Generate Reports',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                // Report cards
                _reportCard(
                  title: 'Sales Report',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                  onPDF: () async {
                    final data = await _fetchData('sales', joinCustomer: 'sales');
                    await ReportService.generateSalesPDF(data);
                  },
                  onExcel: () async {
                    final data = await _fetchData('sales', joinCustomer: 'sales');
                    await ReportService.generateSalesExcel(data);
                  },
                ),
                const SizedBox(height: 10),
                _reportCard(
                  title: 'Purchase Report',
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                  onPDF: () async {
                    final data = await _fetchData('purchases');
                    await ReportService.generatePurchasesPDF(data);
                  },
                  onExcel: null,
                ),
                const SizedBox(height: 10),
                _reportCard(
                  title: 'Expense Report',
                  icon: Icons.money_off,
                  color: Colors.red,
                  onPDF: () async {
                    final data = await _fetchData('expenses');
                    await ReportService.generateExpensesPDF(data);
                  },
                  onExcel: () async {
                    final data = await _fetchData('expenses');
                    await ReportService.generateExpensesExcel(data);
                  },
                ),
                const SizedBox(height: 10),
                _reportCard(
                  title: 'Stock Report',
                  icon: Icons.inventory_2,
                  color: Colors.purple,
                  onPDF: () async {
                    final data = await _fetchData('products');
                    await ReportService.generateStockPDF(data);
                  },
                  onExcel: () async {
                    final data = await _fetchData('products');
                    await ReportService.generateStockExcel(data);
                  },
                ),
                const SizedBox(height: 24),
              ]),
            ),
    );
  }

  Widget _summaryCard(String title, double value, IconData icon, Color color, NumberFormat fmt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text('Rs. ${fmt.format(value)}',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required IconData icon,
    required Color color,
    required Future<void> Function() onPDF,
    Future<void> Function()? onExcel,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold))),
          // PDF button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              _showLoading();
              await onPDF();
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.picture_as_pdf, size: 16),
            label: const Text('PDF', style: TextStyle(fontSize: 12)),
          ),
          if (onExcel != null) ...[
            const SizedBox(width: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[50],
                foregroundColor: Colors.green[800],
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                _showLoading();
                await onExcel!();
                if (mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.table_chart, size: 16),
              label: const Text('Excel', style: TextStyle(fontSize: 12)),
            ),
          ],
        ]),
      ),
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}

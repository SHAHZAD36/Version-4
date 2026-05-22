import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_strings.dart';  // <-- YEH ADD KARO
import '../../../../core/providers/language_provider.dart';
import 'report_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getText(lang, 'reports')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ReportCard(
            icon: Icons.trending_up,
            title: 'Sales Report',
            subtitle: 'View and generate sales reports',
            color: Colors.blue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sales Report - Feature Coming Soon')),
              );
            },
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.shopping_cart,
            title: 'Purchase Report',
            subtitle: 'View and generate purchase reports',
            color: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase Report - Feature Coming Soon')),
              );
            },
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.money_off,
            title: 'Expense Report',
            subtitle: 'View and generate expense reports',
            color: Colors.red,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense Report - Feature Coming Soon')),
              );
            },
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.account_balance_wallet,
            title: 'Collection Report',
            subtitle: 'View and generate collection reports',
            color: Colors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Collection Report - Feature Coming Soon')),
              );
            },
          ),
          const SizedBox(height: 12),
          _ReportCard(
            icon: Icons.inventory_2,
            title: 'Stock Report',
            subtitle: 'View current stock levels and valuation',
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock Report - Feature Coming Soon')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

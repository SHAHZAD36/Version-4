import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sale_model.dart';
import '../providers/sale_provider.dart';
import '../../../customers/presentation/providers/customer_provider.dart';

class SaleCard extends ConsumerWidget {
  final SaleModel sale;
  const SaleCard({super.key, required this.sale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);
    final customer = customers.firstWhere(
      (c) => c.id == sale.customerId,
      orElse: () => customers.isNotEmpty ? customers.first : throw Exception('No customers'),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sale.paymentType == 'Cash' ? Colors.green[100] : Colors.orange[100],
          child: Icon(
            sale.paymentType == 'Cash' ? Icons.payments : Icons.credit_card,
            color: sale.paymentType == 'Cash' ? Colors.green : Colors.orange,
            size: 20,
          ),
        ),
        title: Text(customers.any((c) => c.id == sale.customerId)
            ? customer.shopName
            : 'Customer #${sale.customerId}'),
        subtitle: Text(sale.date, style: const TextStyle(fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rs. ${sale.netAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  _showDeleteConfirmation(context, ref, sale.id!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Sale?'),
        content: const Text('This will also restore the stock. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(salesProvider.notifier).deleteSale(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

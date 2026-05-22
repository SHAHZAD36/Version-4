import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/collection_provider.dart';
import '../../data/models/collection_model.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/localization/app_strings.dart';  // <-- YEH ADD KARO

class CollectionListScreen extends ConsumerWidget {
  const CollectionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    final customers = ref.watch(customersProvider);
    final lang = ref.watch(languageProvider);
    final total = collections.fold(0.0, (s, e) => s + e.amount);
    final fmt = NumberFormat('#,##0');

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getText(lang, 'collections')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${AppStrings.getText(lang, 'total_collection')}: Rs. ${fmt.format(total)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
      body: collections.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(AppStrings.getText(lang, 'no_collections')),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddCollectionDialog(context, ref, lang),
                    child: Text(AppStrings.getText(lang, 'new_collection')),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: collections.length,
              itemBuilder: (ctx, i) {
                final c = collections[i];
                final customerName = customers.any((cust) => cust.id == c.customerId)
                    ? customers.firstWhere((cust) => cust.id == c.customerId).shopName
                    : AppStrings.getText(lang, 'unknown');
                    
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.payments, color: Colors.white),
                    ),
                    title: Text(customerName),
                    subtitle: Text(c.date),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rs. ${fmt.format(c.amount)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, ref, c, lang),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCollectionDialog(context, ref, lang),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCollectionDialog(BuildContext context, WidgetRef ref, AppLanguage lang) {
    final customers = ref.read(customersProvider);
    int? selectedCustomerId;
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppStrings.getText(lang, 'new_collection')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: AppStrings.getText(lang, 'select_customer'),
                ),
                value: selectedCustomerId,
                items: customers.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text('${c.shopName} (Bal: Rs. ${c.currentBalance})'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedCustomerId = val),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.getText(lang, 'amount'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getText(lang, 'cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCustomerId == null || amountCtrl.text.isEmpty) return;
                
                ref.read(collectionsProvider.notifier).addCollection(
                  CollectionModel(
                    customerId: selectedCustomerId!,
                    date: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
                    amount: double.tryParse(amountCtrl.text) ?? 0,
                    notes: noteCtrl.text,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.getText(lang, 'collection_saved'))),
                );
              },
              child: Text(AppStrings.getText(lang, 'save')),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, CollectionModel collection, AppLanguage lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getText(lang, 'delete')),
        content: Text('${AppStrings.getText(lang, 'delete')} this collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getText(lang, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(collectionsProvider.notifier).deleteCollection(collection.id!);
              Navigator.pop(context);
            },
            child: Text(AppStrings.getText(lang, 'delete')),
          ),
        ],
      ),
    );
  }
}

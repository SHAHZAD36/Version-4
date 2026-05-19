import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/collection_provider.dart';
import '../../data/models/collection_model.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../customers/data/models/customer_model.dart';

class CollectionListScreen extends ConsumerWidget {
  const CollectionListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    final total = collections.fold(0.0, (s, c) => s + c.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('وصولیاں (Collections)'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(40),
          child: Padding(padding: const EdgeInsets.all(8),
            child: Text('کل وصولی: Rs. ${NumberFormat('#,##0').format(total)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))))),
      body: collections.isEmpty
          ? const Center(child: Text('کوئی وصولی نہیں'))
          : ListView.builder(
              itemCount: collections.length,
              itemBuilder: (ctx, i) {
                final c = collections[i];
                return Card(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.payments, color: Colors.green)),
                    title: Text('Customer ID: ${c.customerId}'),
                    subtitle: Text('${c.paymentMethod} | ${c.date}'),
                    trailing: Text('Rs. ${NumberFormat('#,##0').format(c.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  ));
              }),
      floatingActionButton: FloatingActionButton(onPressed: () => _addDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  void _addDialog(BuildContext context, WidgetRef ref) {
    final customers = ref.read(customersProvider);
    CustomerModel? selectedCustomer;
    final amtCtrl = TextEditingController();
    String method = 'Cash';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('نئی وصولی'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<CustomerModel>(
            decoration: const InputDecoration(labelText: 'کسٹمر'),
            items: customers.map((c) => DropdownMenuItem(value: c, child: Text('${c.shopName} (Rs. ${c.currentBalance})'))).toList(),
            onChanged: (c) => setState(() => selectedCustomer = c),
          ),
          TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رقم (Amount)')),
          DropdownButtonFormField<String>(
            value: method,
            decoration: const InputDecoration(labelText: 'ادائیگی طریقہ'),
            items: ['Cash', 'Bank Transfer', 'Cheque'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) => setState(() => method = v!),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('کینسل')),
          ElevatedButton(onPressed: () {
            if (selectedCustomer == null) return;
            ref.read(collectionsProvider.notifier).add(CollectionModel(
              customerId: selectedCustomer!.id!, date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              amount: double.tryParse(amtCtrl.text) ?? 0, paymentMethod: method));
            Navigator.pop(ctx);
          }, child: const Text('محفوظ کریں')),
        ],
      ),
    ));
  }
}

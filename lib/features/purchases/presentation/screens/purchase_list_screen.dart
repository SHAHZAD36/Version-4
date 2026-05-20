import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/purchase_provider.dart';
import '../../data/models/purchase_model.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../products/data/models/product_model.dart';

class PurchaseListScreen extends ConsumerWidget {
  const PurchaseListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = ref.watch(purchasesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('خریداری (Purchases)')),
      body: purchases.isEmpty
          ? const Center(child: Text('کوئی خریداری نہیں'))
          : ListView.builder(
              itemCount: purchases.length,
              itemBuilder: (ctx, i) {
                final p = purchases[i];
                return Card(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.shopping_cart)),
                    title: Text('Product ID: ${p.productId}'),
                    subtitle: Text('${p.supplierName ?? ""} | ${p.date}'),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${p.quantity} units', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Rs. ${NumberFormat('#,##0').format(p.totalCost)}'),
                    ]),
                  ));
              }),
      floatingActionButton: FloatingActionButton(onPressed: () => _addDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  void _addDialog(BuildContext context, WidgetRef ref) {
    final products = ref.read(productsProvider);
    ProductModel? selectedProduct;
    final supCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('نئی خریداری'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<ProductModel>(
            decoration: const InputDecoration(labelText: 'پروڈکٹ'),
            items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
            onChanged: (p) => setState(() => selectedProduct = p),
          ),
          TextField(controller: supCtrl, decoration: const InputDecoration(labelText: 'سپلائر (Supplier)')),
          TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مقدار (Qty)')),
          TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت (Cost Price)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('کینسل')),
          ElevatedButton(onPressed: () {
            if (selectedProduct == null) return;
            final qty = double.tryParse(qtyCtrl.text) ?? 0;
            final price = double.tryParse(priceCtrl.text) ?? 0;
            ref.read(purchasesProvider.notifier).add(PurchaseModel(
              productId: selectedProduct!.id!, supplierName: supCtrl.text,
              date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              quantity: qty, costPrice: price, totalCost: qty * price));
            Navigator.pop(ctx);
          }, child: const Text('محفوظ کریں')),
        ],
      ),
    ));
  }
}

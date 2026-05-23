import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider);
    final total = expenses.fold(0.0, (s, e) => s + e.amount);
    return Scaffold(
      appBar: AppBar(title: const Text('اخراجات (Expenses)'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(40),
          child: Padding(padding: const EdgeInsets.all(8),
            child: Text('کل: Rs. ${NumberFormat('#,##0').format(total)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))))),
      body: expenses.isEmpty
          ? const Center(child: Text('کوئی اخراجات نہیں'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (ctx, i) {
                final e = expenses[i];
                return Card(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.money_off)),
                    title: Text(e.category),
                    subtitle: Text(e.description ?? e.date),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Rs. ${NumberFormat('#,##0').format(e.amount)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => ref.read(expensesProvider.notifier).delete(e.id!)),
                    ]),
                  ));
              }),
      floatingActionButton: FloatingActionButton(onPressed: () => _addDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  void _addDialog(BuildContext context, WidgetRef ref) {
    final catCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('نیا خرچ شامل کریں'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'قسم (Category)')),
        TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'رقم (Amount)')),
        TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'تفصیل (Description)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('کینسل')),
        ElevatedButton(onPressed: () {
          ref.read(expensesProvider.notifier).add(ExpenseModel(
            category: catCtrl.text, amount: double.tryParse(amtCtrl.text) ?? 0,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()), description: descCtrl.text));
          Navigator.pop(context);
        }, child: const Text('محفوظ کریں')),
      ],
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/cash_book_provider.dart';
import '../../data/models/cash_book_model.dart';

class CashBookScreen extends ConsumerWidget {
  const CashBookScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(cashBookProvider);
    final closing = entries.isEmpty ? 0.0 : entries.first.closingCash;
    return Scaffold(
      appBar: AppBar(title: const Text('کیش بک (Cash Book)'),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(40),
          child: Padding(padding: const EdgeInsets.all(8),
            child: Text('موجودہ بیلنس: Rs. ${NumberFormat('#,##0').format(closing)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))))),
      body: entries.isEmpty
          ? const Center(child: Text('کوئی اندراج نہیں'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (ctx, i) {
                final e = entries[i];
                return Card(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(e.date),
                    subtitle: Text(e.notes ?? ''),
                    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('آمد: Rs. ${NumberFormat('#,##0').format(e.cashIn)}', style: const TextStyle(color: Colors.green, fontSize: 12)),
                      Text('خرچ: Rs. ${NumberFormat('#,##0').format(e.cashOut)}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                      Text('بیلنس: Rs. ${NumberFormat('#,##0').format(e.closingCash)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ]),
                  ));
              }),
      floatingActionButton: FloatingActionButton(onPressed: () => _addDialog(context, ref), child: const Icon(Icons.add)),
    );
  }

  void _addDialog(BuildContext context, WidgetRef ref) {
    final inCtrl = TextEditingController();
    final outCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final entries = ref.read(cashBookProvider);
    final opening = entries.isEmpty ? 0.0 : entries.first.closingCash;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('نیا اندراج'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('افتتاحی بیلنس: Rs. ${NumberFormat('#,##0').format(opening)}'),
        const SizedBox(height: 8),
        TextField(controller: inCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'آمد (Cash In)')),
        TextField(controller: outCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'خرچ (Cash Out)')),
        TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'نوٹ')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('کینسل')),
        ElevatedButton(onPressed: () {
          final cashIn = double.tryParse(inCtrl.text) ?? 0;
          final cashOut = double.tryParse(outCtrl.text) ?? 0;
          ref.read(cashBookProvider.notifier).add(CashBookModel(
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            openingCash: opening, cashIn: cashIn, cashOut: cashOut,
            closingCash: opening + cashIn - cashOut, notes: noteCtrl.text));
          Navigator.pop(context);
        }, child: const Text('محفوظ کریں')),
      ],
    ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sale_provider.dart';
import '../../data/models/sale_model.dart';
import '../../domain/services/bill_service.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../products/data/models/product_model.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/localization/app_strings.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key});
  @override
  ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
}

class _NewSaleScreenState extends ConsumerState<NewSaleScreen> {
  CustomerModel? selectedCustomer;
  List<Map<String, dynamic>> cartItems = [];
  double totalAmount = 0;
  double discount = 0;
  String paymentType = 'Cash';

  void _calculateTotal() {
    totalAmount = cartItems.fold(0, (sum, item) => sum + (item['total'] as double));
    setState(() {});
  }

  void _addItem(ProductModel product, double quantity) {
    final idx = cartItems.indexWhere((i) => i['product_id'] == product.id);
    if (idx >= 0) {
      cartItems[idx]['quantity'] = (cartItems[idx]['quantity'] as double) + quantity;
      cartItems[idx]['total'] = (cartItems[idx]['quantity'] as double) * product.salePrice;
    } else {
      cartItems.add({
        'product_id': product.id,
        'name': product.name,
        'quantity': quantity,
        'rate': product.salePrice,
        'total': quantity * product.salePrice,
      });
    }
    _calculateTotal();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider);
    final products = ref.watch(productsProvider);
    final lang = ref.watch(languageProvider);
    final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final allSales = ref.watch(salesProvider);
    final todaysSales = allSales.where((s) => s.date.contains(todayStr)).toList();
    final fmt = NumberFormat('#,##0');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.getText(lang, 'new_sale')),
          bottom: TabBar(tabs: [
            Tab(text: AppStrings.getText(lang, 'new_entry')),
            Tab(text: AppStrings.getText(lang, 'today_history')),
          ]),
        ),
        body: TabBarView(children: [
          _buildNewEntryForm(customers, products, lang, fmt),
          _buildTodayHistory(todaysSales, customers, lang, fmt),
        ]),
      ),
    );
  }

  Widget _buildNewEntryForm(List<CustomerModel> customers, List<ProductModel> products, AppLanguage lang, NumberFormat fmt) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        DropdownButtonFormField<CustomerModel>(
          decoration: InputDecoration(labelText: AppStrings.getText(lang, 'select_customer')),
          value: selectedCustomer,
          items: customers.map<DropdownMenuItem<CustomerModel>>(
              (c) => DropdownMenuItem(value: c, child: Text(c.shopName))).toList(),
          onChanged: (val) => setState(() => selectedCustomer = val),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ProductModel>(
          decoration: InputDecoration(labelText: AppStrings.getText(lang, 'select_product')),
          items: products.map<DropdownMenuItem<ProductModel>>((p) => DropdownMenuItem(
            value: p,
            child: Text('${p.name} (Rs. ${fmt.format(p.salePrice)}) - Stock: ${p.currentStock.toStringAsFixed(0)}'),
          )).toList(),
          onChanged: (p) { if (p != null) _showQtyDialog(p, lang); },
        ),
        const Divider(height: 32),
        Expanded(
          child: cartItems.isEmpty
              ? Center(child: Text(AppStrings.getText(lang, 'no_sales')))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, i) {
                    final item = cartItems[i];
                    return Card(
                      child: ListTile(
                        title: Text(item['name']),
                        subtitle: Text('${item['quantity']} x Rs. ${fmt.format(item['rate'])}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('Rs. ${fmt.format(item['total'])}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                            onPressed: () {
                              setState(() => cartItems.removeAt(i));
                              _calculateTotal();
                            },
                          ),
                        ]),
                      ),
                    );
                  }),
        ),
        if (cartItems.isNotEmpty) ...[
          const Divider(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppStrings.getText(lang, 'total'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Rs. ${fmt.format(totalAmount - discount)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppStrings.getText(lang, 'payment_type')),
            DropdownButton<String>(
              value: paymentType,
              items: [
                DropdownMenuItem(value: 'Cash', child: Text(AppStrings.getText(lang, 'cash'))),
                DropdownMenuItem(value: 'Credit', child: Text(AppStrings.getText(lang, 'credit'))),
              ],
              onChanged: (val) => setState(() => paymentType = val!),
            ),
          ]),
        ],
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          onPressed: selectedCustomer == null || cartItems.isEmpty ? null : _saveAndPrint,
          child: const Text('Save & Print Bill'),
        ),
      ]),
    );
  }

  Widget _buildTodayHistory(List<SaleModel> sales, List<CustomerModel> customers, AppLanguage lang, NumberFormat fmt) {
    if (sales.isEmpty) {
      return Center(child: Text(AppStrings.getText(lang, 'no_sales')));
    }
    return ListView.builder(
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        final customerName = customers.any((c) => c.id == sale.customerId)
            ? customers.firstWhere((c) => c.id == sale.customerId).shopName
            : 'Customer #${sale.customerId}';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: sale.paymentType == 'Cash' ? Colors.green[100] : Colors.orange[100],
              child: Icon(sale.paymentType == 'Cash' ? Icons.payments : Icons.credit_card,
                  color: sale.paymentType == 'Cash' ? Colors.green : Colors.orange, size: 18),
            ),
            title: Text(customerName),
            subtitle: Text('Rs. ${fmt.format(sale.netAmount)} • ${sale.paymentType}'),
            trailing: PopupMenuButton<String>(
              onSelected: (val) async {
                if (val == 'delete') {
                  await ref.read(salesProvider.notifier).deleteSale(sale.id!);
                }
              },
              itemBuilder: (c) => [
                const PopupMenuItem(value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ])),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveAndPrint() async {
    final lang = ref.read(languageProvider);
    final sale = SaleModel(
      customerId: selectedCustomer!.id!,
      date: DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now()),
      totalAmount: totalAmount,
      discount: discount,
      netAmount: totalAmount - discount,
      paymentType: paymentType,
    );
    final items = cartItems.map((item) => SaleItemModel(
      saleId: 0,
      productId: item['product_id'],
      quantity: item['quantity'],
      rate: item['rate'],
      total: item['total'],
    )).toList();

    await ref.read(salesProvider.notifier).createSale(sale, items);
    await BillService.generateSingleBill(sale, selectedCustomer!.shopName, cartItems);

    if (mounted) {
      setState(() { cartItems.clear(); totalAmount = 0; discount = 0; });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.getText(lang, 'sale_saved'))));
    }
  }

  void _showQtyDialog(ProductModel product, AppLanguage lang) {
    final ctrl = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product.name),
        content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: AppStrings.getText(lang, 'qty'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getText(lang, 'cancel'))),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(ctrl.text) ?? 1;
              _addItem(product, qty);
              Navigator.pop(context);
            },
            child: Text(AppStrings.getText(lang, 'save')),
          ),
        ],
      ),
    );
  }
}

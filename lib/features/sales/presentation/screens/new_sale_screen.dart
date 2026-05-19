import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import '../providers/sale_provider.dart';
import '../../data/models/sale_model.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../products/data/models/product_model.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/localization/app_strings.dart';

class NewSaleScreen extends ConsumerStatefulWidget {
  const NewSaleScreen({super.key});
  @override ConsumerState<NewSaleScreen> createState() => _NewSaleScreenState();
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
    
    // logic to get only TODAY'S sales for the reset effect
    final todayStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final allSales = ref.watch(salesProvider);
    final todaysSales = allSales.where((s) => s.date.contains(todayStr)).toList();

    final fmt = NumberFormat('#,##0');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.getText(lang, 'new_sale')),
          bottom: const TabBar(
            tabs: [Tab(text: "New Entry"), Tab(text: "Today's History")],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: NEW ENTRY SCREEN
            _buildNewEntryForm(customers, products, lang, fmt),
            
            // TAB 2: TODAY'S SALES (Daily Refresh Logic)
            _buildTodayHistory(todaysSales, lang, fmt),
          ],
        ),
      ),
    );
  }

  Widget _buildNewEntryForm(customers, products, lang, fmt) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        DropdownButtonFormField<CustomerModel>(
          decoration: InputDecoration(labelText: AppStrings.getText(lang, 'select_customer')),
          value: selectedCustomer,
          items: customers.map<DropdownMenuItem<CustomerModel>>((c) => DropdownMenuItem(value: c, child: Text(c.shopName))).toList(),
          onChanged: (val) => setState(() => selectedCustomer = val),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<ProductModel>(
          decoration: InputDecoration(labelText: AppStrings.getText(lang, 'select_product')),
          items: products.map<DropdownMenuItem<ProductModel>>((p) => DropdownMenuItem(
            value: p,
            child: Text('${p.name} (Rs. ${fmt.format(p.salePrice)})'),
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () { setState(() => cartItems.removeAt(i)); _calculateTotal(); },
                        ),
                      ),
                    );
                  }),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          onPressed: selectedCustomer == null || cartItems.isEmpty ? null : _saveAndPrint,
          child: const Text("Save and Print Bill"),
        ),
      ]),
    );
  }

  Widget _buildTodayHistory(List<SaleModel> sales, lang, fmt) {
    return sales.isEmpty 
    ? const Center(child: Text("No sales recorded today yet."))
    : ListView.builder(
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text("Sale ID: ${sale.id}"),
            subtitle: Text("Total: Rs. ${fmt.format(sale.netAmount)}\nTime: ${sale.date.split(' ')[1]}"),
            trailing: PopupMenuButton<String>(
              onSelected: (val) async {
                if(val == 'delete') {
                  // logic to delete
                  await ref.read(salesProvider.notifier).deleteSale(sale.id!);
                } else if (val == 'print') {
                  _generatePDFBill(sale);
                }
              },
              itemBuilder: (c) => [
                const PopupMenuItem(value: 'print', child: Text("Re-Print Bill")),
                const PopupMenuItem(value: 'delete', child: Text("Delete", style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        );
      },
    );
  }

  // UPDATED SAVE LOGIC WITH BILL GENERATION
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

    // 1. Save to Database
    await ref.read(salesProvider.notifier).createSale(sale, items);
    
    // 2. Generate and Print Bill immediately
    await _generatePDFBill(sale);

    if (mounted) {
      setState(() { cartItems.clear(); totalAmount = 0; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.getText(lang, 'sale_saved'))));
    }
  }

  // LOGO & BILL GENERATION FUNCTION
  Future<void> _generatePDFBill(SaleModel sale) async {
    final pdf = pw.Document();
    
    // Try to load logo - Important: image must be in assets/images/logo.png
    pw.MemoryImage? logoImage;
    try {
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      debugPrint("Logo not found");
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlign.center,
          children: [
            if(logoImage != null) pw.Image(logoImage, width: 80),
            pw.Text("CHAUDHARY TRADERS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
            pw.Divider(),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
               pw.Text("Date: ${sale.date.split(' ')[0]}"),
               pw.Text("Time: ${sale.date.split(' ')[1]}"),
            ]),
            pw.Divider(),
            ...cartItems.map((item) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("${item['name']} x${item['quantity']}"),
                pw.Text("Rs. ${item['total']}"),
              ]
            )).toList(),
            pw.Divider(),
            pw.Text("NET AMOUNT: Rs. ${sale.netAmount}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // Logic for the Pop-up Qty Dialog
  void _showQtyDialog(ProductModel product, AppLanguage lang) {
    final ctrl = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product.name),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: AppStrings.getText(lang, 'qty'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.getText(lang, 'cancel'))),
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
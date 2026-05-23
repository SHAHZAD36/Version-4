import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/sale_provider.dart';
import '../../data/models/sale_model.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../products/data/models/product_model.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/database_helper.dart';

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
  final _customerSearchCtrl = TextEditingController();
  String _customerSearchQuery = '';

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

    // Filter customers by search
    final filteredCustomers = _customerSearchQuery.isEmpty
        ? customers
        : customers.where((c) =>
            c.shopName.toLowerCase().contains(_customerSearchQuery.toLowerCase()) ||
            (c.ownerName?.toLowerCase().contains(_customerSearchQuery.toLowerCase()) ?? false) ||
            (c.phone?.contains(_customerSearchQuery) ?? false)).toList();

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
          _buildNewEntryForm(filteredCustomers, customers, products, lang, fmt),
          _buildTodayHistory(todaysSales, customers, lang, fmt),
        ]),
      ),
    );
  }

  Widget _buildNewEntryForm(List<CustomerModel> filteredCustomers,
      List<CustomerModel> allCustomers, List<ProductModel> products,
      AppLanguage lang, NumberFormat fmt) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        // Customer search field
        TextField(
          controller: _customerSearchCtrl,
          decoration: InputDecoration(
            labelText: AppStrings.getText(lang, 'select_customer'),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _customerSearchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _customerSearchCtrl.clear();
                      setState(() => _customerSearchQuery = '');
                    })
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (v) => setState(() => _customerSearchQuery = v),
        ),
        // Customer list dropdown
        if (_customerSearchQuery.isNotEmpty && selectedCustomer == null)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredCustomers.length,
              itemBuilder: (context, i) {
                final c = filteredCustomers[i];
                return ListTile(
                  dense: true,
                  title: Text(c.shopName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${c.ownerName ?? ''} • ${c.phone ?? ''}'),
                  onTap: () {
                    setState(() {
                      selectedCustomer = c;
                      _customerSearchCtrl.text = c.shopName;
                      _customerSearchQuery = '';
                    });
                  },
                );
              },
            ),
          ),
        // Selected customer info card
        if (selectedCustomer != null) ...[
          const SizedBox(height: 8),
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                const Icon(Icons.person, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(selectedCustomer!.shopName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (selectedCustomer!.ownerName != null)
                    Text(selectedCustomer!.ownerName!, style: const TextStyle(fontSize: 12)),
                  if (selectedCustomer!.phone != null)
                    Text(selectedCustomer!.phone!, style: const TextStyle(fontSize: 12)),
                  if (selectedCustomer!.address != null)
                    Text(selectedCustomer!.address!, style: const TextStyle(fontSize: 12)),
                  Text('Balance: Rs. ${NumberFormat('#,##0').format(selectedCustomer!.currentBalance)}',
                      style: TextStyle(
                          fontSize: 12,
                          color: selectedCustomer!.currentBalance > 0 ? Colors.orange : Colors.green)),
                ])),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() {
                    selectedCustomer = null;
                    _customerSearchCtrl.clear();
                  }),
                ),
              ]),
            ),
          ),
        ],
        const SizedBox(height: 8),
        // Product dropdown
        DropdownButtonFormField<ProductModel>(
          decoration: InputDecoration(
            labelText: AppStrings.getText(lang, 'select_product'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          items: products.map<DropdownMenuItem<ProductModel>>((p) => DropdownMenuItem(
            value: p,
            child: Text('${p.name} • Rs.${fmt.format(p.salePrice)} • Stock:${p.currentStock.toStringAsFixed(0)}'),
          )).toList(),
          onChanged: (p) { if (p != null) _showQtyDialog(p, lang); },
        ),
        const Divider(height: 20),
        // Cart items
        Expanded(
          child: cartItems.isEmpty
              ? Center(child: Text(AppStrings.getText(lang, 'no_sales')))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, i) {
                    final item = cartItems[i];
                    return Card(
                      child: ListTile(
                        title: Text(item['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item['quantity']} x Rs. ${fmt.format(item['rate'])}'),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('Rs. ${fmt.format(item['total'])}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
          // Discount row
          Row(children: [
            const Text('Discount: Rs. '),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                onChanged: (v) => setState(() => discount = double.tryParse(v) ?? 0),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          // Total + payment
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${AppStrings.getText(lang, 'total')}: Rs. ${fmt.format(totalAmount - discount)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        const SizedBox(height: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: selectedCustomer == null || cartItems.isEmpty ? null : _saveAndPrint,
          icon: const Icon(Icons.receipt),
          label: Text(AppStrings.getText(lang, 'save_sale')),
        ),
      ]),
    );
  }

  Widget _buildTodayHistory(List<SaleModel> sales,
      List<CustomerModel> customers, AppLanguage lang, NumberFormat fmt) {
    if (sales.isEmpty) {
      return Center(child: Text(AppStrings.getText(lang, 'no_sales')));
    }
    return ListView.builder(
      itemCount: sales.length,
      itemBuilder: (context, index) {
        final sale = sales[index];
        final customer = customers.any((c) => c.id == sale.customerId)
            ? customers.firstWhere((c) => c.id == sale.customerId)
            : null;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  sale.paymentType == 'Cash' ? Colors.green[100] : Colors.orange[100],
              child: Icon(
                sale.paymentType == 'Cash' ? Icons.payments : Icons.credit_card,
                color: sale.paymentType == 'Cash' ? Colors.green : Colors.orange,
                size: 18,
              ),
            ),
            title: Text(customer?.shopName ?? 'Customer #${sale.customerId}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Rs. ${fmt.format(sale.netAmount)} • ${sale.paymentType}'),
              Text(sale.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ]),
            onTap: () => _showSaleDetailDialog(sale, customer, lang, fmt),
            trailing: PopupMenuButton<String>(
              onSelected: (val) async {
                if (val == 'delete') {
                  _showDeleteConfirmation(sale.id!, lang);
                } else if (val == 'print') {
                  await _generatePDFBill(sale, customer);
                }
              },
              itemBuilder: (c) => [
                const PopupMenuItem(value: 'print',
                    child: Row(children: [
                      Icon(Icons.print, size: 18),
                      SizedBox(width: 8),
                      Text('Re-Print Bill'),
                    ])),
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

  void _showSaleDetailDialog(SaleModel sale, CustomerModel? customer,
      AppLanguage lang, NumberFormat fmt) async {
    // Fetch sale items
    final db = await DatabaseHelper.instance.database;
    final items = await db.rawQuery('''
      SELECT si.*, p.name as product_name 
      FROM sale_items si 
      LEFT JOIN products p ON si.product_id = p.id 
      WHERE si.sale_id = ?
    ''', [sale.id]);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Sale #${sale.id}'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Customer info
            if (customer != null) ...[
              ListTile(
                dense: true,
                leading: const Icon(Icons.person, color: Colors.blue),
                title: Text(customer.shopName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (customer.ownerName != null) Text(customer.ownerName!),
                  if (customer.phone != null) Text(customer.phone!),
                  if (customer.address != null) Text(customer.address!),
                ]),
              ),
              const Divider(),
            ],
            // Items
            ...items.map((item) => ListTile(
              dense: true,
              title: Text(item['product_name']?.toString() ?? ''),
              subtitle: Text('${item['quantity']} x Rs. ${fmt.format(item['rate'])}'),
              trailing: Text('Rs. ${fmt.format(item['total'])}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
            const Divider(),
            ListTile(
              dense: true,
              title: const Text('Net Amount',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('Rs. ${fmt.format(sale.netAmount)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
            ),
            ListTile(
              dense: true,
              title: const Text('Payment'),
              trailing: Text(sale.paymentType),
            ),
            ListTile(
              dense: true,
              title: const Text('Date'),
              trailing: Text(sale.date, style: const TextStyle(fontSize: 12)),
            ),
          ]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getText(lang, 'cancel')),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _generatePDFBill(sale, customer);
            },
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Print Bill'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int saleId, AppLanguage lang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Sale?'),
        content: const Text('This will restore product stock. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getText(lang, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(salesProvider.notifier).deleteSale(saleId);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndPrint() async {
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
    await _generatePDFBill(sale, selectedCustomer);

    if (mounted) {
      setState(() {
        cartItems.clear();
        totalAmount = 0;
        discount = 0;
        selectedCustomer = null;
        _customerSearchCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getText(lang, 'sale_saved')),
            backgroundColor: Colors.green));
    }
  }

  Future<void> _generatePDFBill(SaleModel sale, CustomerModel? customer) async {
    final pdf = pw.Document();
    final fmt = NumberFormat('#,##0');

    pw.MemoryImage? logoImage;
    try {
      final ByteData logoData = await rootBundle.load('assets/images/logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    // Fetch sale items if reprinting
    List<Map<String, dynamic>> billItems = cartItems.isNotEmpty ? cartItems : [];
    if (billItems.isEmpty && sale.id != null) {
      final db = await DatabaseHelper.instance.database;
      final rows = await db.rawQuery('''
        SELECT si.*, p.name as name FROM sale_items si 
        LEFT JOIN products p ON si.product_id = p.id WHERE si.sale_id = ?
      ''', [sale.id]);
      billItems = rows.map((r) => {
        'name': r['name'],
        'quantity': r['quantity'],
        'rate': r['rate'],
        'total': r['total'],
      }).toList();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logoImage != null) pw.Image(logoImage, width: 70),
            pw.SizedBox(height: 4),
            pw.Text('CHAUDHARY TRADERS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
            pw.Text('Mandi Shah Jewna, Jhang',
                style: const pw.TextStyle(fontSize: 9)),
            pw.Divider(),
            if (customer != null) ...[
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                  pw.Text('Customer: ${customer.shopName}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  if (customer.ownerName != null)
                    pw.Text('Owner: ${customer.ownerName}',
                        style: const pw.TextStyle(fontSize: 9)),
                  if (customer.phone != null)
                    pw.Text('Phone: ${customer.phone}',
                        style: const pw.TextStyle(fontSize: 9)),
                  if (customer.address != null)
                    pw.Text('Address: ${customer.address}',
                        style: const pw.TextStyle(fontSize: 9)),
                ]),
              ),
              pw.Divider(),
            ],
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('Date: ${sale.date.split(' ')[0]}',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Time: ${sale.date.contains(' ') ? sale.date.split(' ')[1] : ''}',
                  style: const pw.TextStyle(fontSize: 9)),
            ]),
            pw.Divider(),
            // Items
            ...billItems.map((item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text('${item['name']} x${item['quantity']}',
                        style: const pw.TextStyle(fontSize: 9))),
                  pw.Text('Rs. ${fmt.format(item['total'])}',
                      style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            )),
            pw.Divider(),
            if (sale.discount > 0)
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Discount:', style: const pw.TextStyle(fontSize: 9)),
                pw.Text('Rs. ${fmt.format(sale.discount)}',
                    style: const pw.TextStyle(fontSize: 9)),
              ]),
            pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
              pw.Text('NET AMOUNT:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              pw.Text('Rs. ${fmt.format(sale.netAmount)}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            ]),
            pw.Text('Payment: ${sale.paymentType}',
                style: const pw.TextStyle(fontSize: 9)),
            pw.SizedBox(height: 12),
            pw.Text('Thank you for your business!',
                style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void _showQtyDialog(ProductModel product, AppLanguage lang) {
    final ctrl = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product.name),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Price: Rs. ${NumberFormat('#,##0').format(product.salePrice)}',
              style: const TextStyle(color: Colors.green)),
          Text('Stock: ${product.currentStock.toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppStrings.getText(lang, 'qty'),
              border: const OutlineInputBorder(),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getText(lang, 'cancel')),
          ),
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

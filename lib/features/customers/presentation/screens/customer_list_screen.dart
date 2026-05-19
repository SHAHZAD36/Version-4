import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/customer_provider.dart';
import '../../data/models/customer_model.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('کسٹمرز (Customers)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: customers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('کوئی کسٹمر نہیں ملا (No customers found)'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddCustomerDialog(context, ref),
                    child: const Text('پہلا کسٹمر شامل کریں'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return Card(
                  child: ListTile(
                    title: Text(customer.shopName),
                    subtitle: Text('${customer.ownerName ?? ''} | ${customer.area ?? ''}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. ${customer.currentBalance}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: customer.currentBalance > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                        const Text(
                          'بیلنس',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCustomerDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context, WidgetRef ref) {
    final shopNameController = TextEditingController();
    final ownerNameController = TextEditingController();
    final phoneController = TextEditingController();
    final areaController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نیا کسٹمر شامل کریں'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopNameController,
                decoration: const InputDecoration(labelText: 'دکان کا نام (Shop Name)'),
              ),
              TextField(
                controller: ownerNameController,
                decoration: const InputDecoration(labelText: 'مالک کا نام (Owner Name)'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'فون نمبر (Phone)'),
              ),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(labelText: 'علاقہ / گاؤں (Area/Village)'),
              ),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'افتتاحی بیلنس (Opening Balance)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('کینسل'),
          ),
          ElevatedButton(
            onPressed: () {
              final customer = CustomerModel(
                shopName: shopNameController.text,
                ownerName: ownerNameController.text,
                phone: phoneController.text,
                area: areaController.text,
                openingBalance: double.tryParse(balanceController.text) ?? 0,
                currentBalance: double.tryParse(balanceController.text) ?? 0,
                creditLimit: 50000,
              );
              ref.read(customersProvider.notifier).addCustomer(customer);
              Navigator.pop(context);
            },
            child: const Text('محفوظ کریں'),
          ),
        ],
      ),
    );
  }
}

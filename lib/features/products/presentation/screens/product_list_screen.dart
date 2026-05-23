import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../../data/models/product_model.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('پروڈکٹس (Products)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('کوئی پروڈکٹ نہیں ملی (No products found)'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddProductDialog(context, ref),
                    child: const Text('پہلی پروڈکٹ شامل کریں'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text('${product.brand ?? ''} | اسٹاک: ${product.currentStock}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. ${product.salePrice}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (product.currentStock <= product.minStockLevel)
                          const Text(
                            'کم اسٹاک',
                            style: TextStyle(color: Colors.red, fontSize: 10),
                          ),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final purchasePriceController = TextEditingController();
    final salePriceController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نئی پروڈکٹ شامل کریں'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'نام (Name)'),
              ),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'برانڈ (Brand)'),
              ),
              TextField(
                controller: purchasePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'خرید قیمت (Purchase Price)'),
              ),
              TextField(
                controller: salePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'فروخت قیمت (Sale Price)'),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'موجودہ اسٹاک (Current Stock)'),
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
              final product = ProductModel(
                name: nameController.text,
                brand: brandController.text,
                purchasePrice: double.tryParse(purchasePriceController.text) ?? 0,
                salePrice: double.tryParse(salePriceController.text) ?? 0,
                openingStock: double.tryParse(stockController.text) ?? 0,
                currentStock: double.tryParse(stockController.text) ?? 0,
                minStockLevel: 10,
              );
              ref.read(productsProvider.notifier).addProduct(product);
              Navigator.pop(context);
            },
            child: const Text('محفوظ کریں'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';
import '../../data/models/product_model.dart';
import '../../../../core/providers/language_provider.dart';
import '../../../../core/localization/app_strings.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final lang = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.getText(lang, 'products')),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context, ref, lang),
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(AppStrings.getText(lang, 'no_products')),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddProductDialog(context, ref, lang),
                    child: Text(AppStrings.getText(lang, 'add_first_product')),
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
                    subtitle: Text('${product.brand ?? ''} | ${AppStrings.getText(lang, 'stock')}: ${product.currentStock}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. ${product.salePrice}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (product.currentStock <= product.minStockLevel)
                          Text(
                            AppStrings.getText(lang, 'low_stock'),
                            style: const TextStyle(color: Colors.red, fontSize: 10),
                          ),
                      ],
                    ),
                    onTap: () => _showEditProductDialog(context, ref, product, lang),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context, ref, lang),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref, AppLanguage lang) {
    final searchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getText(lang, 'search')),
        content: TextField(
          controller: searchCtrl,
          decoration: InputDecoration(
            hintText: AppStrings.getText(lang, 'search_products'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getText(lang, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // Search functionality
              Navigator.pop(context);
            },
            child: Text(AppStrings.getText(lang, 'search')),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, WidgetRef ref, AppLanguage lang) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final purchasePriceController = TextEditingController();
    final salePriceController = TextEditingController();
    final stockController = TextEditingController();
    final minStockController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getText(lang, 'add_product')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'product_name')),
              ),
              TextField(
                controller: brandController,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'brand')),
              ),
              TextField(
                controller: purchasePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'purchase_price')),
              ),
              TextField(
                controller: salePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'sale_price')),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'current_stock')),
              ),
              TextField(
                controller: minStockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'min_stock_level')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getText(lang, 'cancel')),
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
                minStockLevel: double.tryParse(minStockController.text) ?? 10,
              );
              ref.read(productsProvider.notifier).addProduct(product);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.getText(lang, 'product_saved'))),
              );
            },
            child: Text(AppStrings.getText(lang, 'save')),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, WidgetRef ref, ProductModel product, AppLanguage lang) {
    final nameController = TextEditingController(text: product.name);
    final brandController = TextEditingController(text: product.brand ?? '');
    final purchasePriceController = TextEditingController(text: product.purchasePrice.toString());
    final salePriceController = TextEditingController(text: product.salePrice.toString());
    final stockController = TextEditingController(text: product.currentStock.toString());
    final minStockController = TextEditingController(text: product.minStockLevel.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getText(lang, 'edit_product')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'product_name')),
              ),
              TextField(
                controller: brandController,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'brand')),
              ),
              TextField(
                controller: purchasePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'purchase_price')),
              ),
              TextField(
                controller: salePriceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'sale_price')),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'current_stock')),
              ),
              TextField(
                controller: minStockController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: AppStrings.getText(lang, 'min_stock_level')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getText(lang, 'cancel')),
          ),
          TextButton(
            onPressed: () {
              ref.read(productsProvider.notifier).deleteProduct(product.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.getText(lang, 'product_deleted'))),
              );
            },
            child: Text(AppStrings.getText(lang, 'delete'), style: const TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedProduct = product.copyWith(
                name: nameController.text,
                brand: brandController.text,
                purchasePrice: double.tryParse(purchasePriceController.text) ?? product.purchasePrice,
                salePrice: double.tryParse(salePriceController.text) ?? product.salePrice,
                currentStock: double.tryParse(stockController.text) ?? product.currentStock,
                minStockLevel: double.tryParse(minStockController.text) ?? product.minStockLevel,
              );
              ref.read(productsProvider.notifier).updateProduct(updatedProduct);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.getText(lang, 'product_updated'))),
              );
            },
            child: Text(AppStrings.getText(lang, 'save')),
          ),
        ],
      ),
    );
  }
}

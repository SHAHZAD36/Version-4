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

  void _showSearchDialog(BuildContext context, WidgetRef ref, AppLanguage lang)

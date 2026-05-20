class ProductModel {
  final int? id;
  final String name;
  final String? brand;
  final String? category;
  final String? unitSize;
  final double purchasePrice;
  final double salePrice;
  final double openingStock;
  final double currentStock;
  final double minStockLevel;
  final String? notes;

  ProductModel({
    this.id,
    required this.name,
    this.brand,
    this.category,
    this.unitSize,
    required this.purchasePrice,
    required this.salePrice,
    required this.openingStock,
    required this.currentStock,
    required this.minStockLevel,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'unit_size': unitSize,
      'purchase_price': purchasePrice,
      'sale_price': salePrice,
      'opening_stock': openingStock,
      'current_stock': currentStock,
      'min_stock_level': minStockLevel,
      'notes': notes,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      category: map['category'],
      unitSize: map['unit_size'],
      purchasePrice: map['purchase_price'],
      salePrice: map['sale_price'],
      openingStock: map['opening_stock'],
      currentStock: map['current_stock'],
      minStockLevel: map['min_stock_level'],
      notes: map['notes'],
    );
  }
}

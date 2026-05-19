class PurchaseModel {
  final int? id;
  final int productId;
  final String? supplierName;
  final String date;
  final double quantity;
  final double costPrice;
  final double totalCost;

  PurchaseModel({
    this.id,
    required this.productId,
    this.supplierName,
    required this.date,
    required this.quantity,
    required this.costPrice,
    required this.totalCost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'supplier_name': supplierName,
      'date': date,
      'quantity': quantity,
      'cost_price': costPrice,
      'total_cost': totalCost,
    };
  }

  factory PurchaseModel.fromMap(Map<String, dynamic> map) {
    return PurchaseModel(
      id: map['id'],
      productId: map['product_id'],
      supplierName: map['supplier_name'],
      date: map['date'],
      quantity: map['quantity'],
      costPrice: map['cost_price'],
      totalCost: map['total_cost'],
    );
  }
}

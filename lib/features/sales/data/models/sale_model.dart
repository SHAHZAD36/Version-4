class SaleModel {
  final int? id;
  final int customerId;
  final String date;
  final double totalAmount;
  final double discount;
  final double netAmount;
  final String paymentType; // 'Cash' or 'Credit'
  final String? notes;

  SaleModel({
    this.id,
    required this.customerId,
    required this.date,
    required this.totalAmount,
    required this.discount,
    required this.netAmount,
    required this.paymentType,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'date': date,
      'total_amount': totalAmount,
      'discount': discount,
      'net_amount': netAmount,
      'payment_type': paymentType,
      'notes': notes,
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map) {
    return SaleModel(
      id: map['id'],
      customerId: map['customer_id'],
      date: map['date'],
      totalAmount: map['total_amount'],
      discount: map['discount'],
      netAmount: map['net_amount'],
      paymentType: map['payment_type'],
      notes: map['notes'],
    );
  }
}

class SaleItemModel {
  final int? id;
  final int saleId;
  final int productId;
  final double quantity;
  final double rate;
  final double total;

  SaleItemModel({
    this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.rate,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'quantity': quantity,
      'rate': rate,
      'total': total,
    };
  }

  factory SaleItemModel.fromMap(Map<String, dynamic> map) {
    return SaleItemModel(
      id: map['id'],
      saleId: map['sale_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      rate: map['rate'],
      total: map['total'],
    );
  }
}

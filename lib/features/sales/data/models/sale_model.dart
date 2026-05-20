class SaleModel {
  final int? id;
  final int customerId;
  final String date;
  final double totalAmount;
  final double discount;
  final double netAmount;
  final String paymentType;

  SaleModel({
    this.id,
    required this.customerId,
    required this.date,
    required this.totalAmount,
    required this.discount,
    required this.netAmount,
    required this.paymentType,
  });

  // Map to Object (for reading from database)
  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
        id: json['id'],
        customerId: json['customer_id'],
        date: json['date'],
        totalAmount: (json['total_amount'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        netAmount: (json['net_amount'] as num).toDouble(),
        paymentType: json['payment_type'],
      );

  // Object to Map (for saving to database)
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'customer_id': customerId,
        'date': date,
        'total_amount': totalAmount,
        'discount': discount,
        'net_amount': netAmount,
        'payment_type': paymentType,
      };
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

  Map<String, dynamic> toJson() => {
        'sale_id': saleId,
        'product_id': productId,
        'quantity': quantity,
        'rate': rate,
        'total': total,
      };
}

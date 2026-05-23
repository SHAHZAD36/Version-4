class CollectionModel {
  final int? id;
  final int customerId;
  final String date;
  final double amount;
  final String paymentMethod;
  final String? notes;

  CollectionModel({
    this.id,
    required this.customerId,
    required this.date,
    required this.amount,
    required this.paymentMethod,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'date': date,
      'amount': amount,
      'payment_method': paymentMethod,
      'notes': notes,
    };
  }

  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      id: map['id'],
      customerId: map['customer_id'],
      date: map['date'],
      amount: map['amount'],
      paymentMethod: map['payment_method'],
      notes: map['notes'],
    );
  }
}

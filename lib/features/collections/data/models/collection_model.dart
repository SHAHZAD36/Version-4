class CollectionModel {
  final int? id;
  final int customerId;
  final String date;
  final double amount;
  final String? notes;

  CollectionModel({
    this.id,
    required this.customerId,
    required this.date,
    required this.amount,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'date': date,
      'amount': amount,
      'notes': notes,
    };
  }

  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      date: map['date'] as String,
      amount: (map['amount'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }
}

class ExpenseModel {
  final int? id;
  final String category;
  final double amount;
  final String date;
  final String? description;

  ExpenseModel({
    this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'date': date,
      'description': description,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
      date: map['date'],
      description: map['description'],
    );
  }
}

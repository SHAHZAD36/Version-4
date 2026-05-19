class CashBookModel {
  final int? id;
  final String date;
  final double openingCash;
  final double cashIn;
  final double cashOut;
  final double closingCash;
  final String? notes;

  CashBookModel({
    this.id,
    required this.date,
    required this.openingCash,
    required this.cashIn,
    required this.cashOut,
    required this.closingCash,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'opening_cash': openingCash,
      'cash_in': cashIn,
      'cash_out': cashOut,
      'closing_cash': closingCash,
      'notes': notes,
    };
  }

  factory CashBookModel.fromMap(Map<String, dynamic> map) {
    return CashBookModel(
      id: map['id'],
      date: map['date'],
      openingCash: map['opening_cash'],
      cashIn: map['cash_in'],
      cashOut: map['cash_out'],
      closingCash: map['closing_cash'],
      notes: map['notes'],
    );
  }
}

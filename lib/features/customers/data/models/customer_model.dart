class CustomerModel {
  final int? id;
  final String shopName;
  final String? ownerName;
  final String? phone;
  final String? area;
  final String? address;
  final double openingBalance;
  final double creditLimit;
  final double currentBalance;
  final String? notes;

  CustomerModel({
    this.id,
    required this.shopName,
    this.ownerName,
    this.phone,
    this.area,
    this.address,
    required this.openingBalance,
    required this.creditLimit,
    required this.currentBalance,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shop_name': shopName,
      'owner_name': ownerName,
      'phone': phone,
      'area': area,
      'address': address,
      'opening_balance': openingBalance,
      'credit_limit': creditLimit,
      'current_balance': currentBalance,
      'notes': notes,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      shopName: map['shop_name'],
      ownerName: map['owner_name'],
      phone: map['phone'],
      area: map['area'],
      address: map['address'],
      openingBalance: map['opening_balance'],
      creditLimit: map['credit_limit'],
      currentBalance: map['current_balance'],
      notes: map['notes'],
    );
  }
}

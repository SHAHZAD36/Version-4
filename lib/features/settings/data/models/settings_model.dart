class SettingsModel {
  final int? id;
  final String businessName;
  final String? ownerName;
  final String currencySymbol;
  final String themeMode;
  final String language;

  SettingsModel({
    this.id,
    required this.businessName,
    this.ownerName,
    required this.currencySymbol,
    required this.themeMode,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_name': businessName,
      'owner_name': ownerName,
      'currency_symbol': currencySymbol,
      'theme_mode': themeMode,
      'language': language,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id'],
      businessName: map['business_name'],
      ownerName: map['owner_name'],
      currencySymbol: map['currency_symbol'],
      themeMode: map['theme_mode'],
      language: map['language'],
    );
  }
}

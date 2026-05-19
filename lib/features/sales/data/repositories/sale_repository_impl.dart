// Fetching only today's sales
Future<List<SaleModel>> getTodaySales() async {
  final db = await databaseHelper.database;
  final String today = DateTime.now().toString().split(' ')[0]; // Gets "2023-10-27"
  
  final List<Map<String, dynamic>> maps = await db.query(
    'sales',
    where: 'date = ?',
    whereArgs: [today],
    orderBy: 'id DESC',
  );
  return maps.map((item) => SaleModel.fromJson(item)).toList();
}

// Delete a sale
Future<void> deleteSale(int id) async {
  final db = await databaseHelper.database;
  await db.delete('sales', where: 'id = ?', whereArgs: [id]);
}

// Edit/Update a sale
Future<void> updateSale(SaleModel sale) async {
  final db = await databaseHelper.database;
  await db.update('sales', sale.toJson(), where: 'id = ?', whereArgs: [sale.id]);
}
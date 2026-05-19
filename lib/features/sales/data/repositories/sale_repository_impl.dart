// Fetching only today's sales
class SaleRepositoryImpl implements SaleRepository {
  // 1. ADD THIS LINE if it is missing
  final DatabaseHelper _dbHelper; 

  // 2. The constructor should look like this
  SaleRepositoryImpl(this._dbHelper);

  Future<List<SaleModel>> getSales() async {
    // 3. Use the _dbHelper here
    final db = await _dbHelper.database; 
    // ... rest of the code ...
  }
}

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

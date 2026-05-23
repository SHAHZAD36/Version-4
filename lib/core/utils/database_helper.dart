import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chaudhary_traders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullableType = 'TEXT';
    const boolType = 'INTEGER NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const doubleType = 'REAL NOT NULL';

    // Users Table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        pin $textType,
        use_fingerprint $boolType
      )
    ''');

    // Products Table
    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        brand $textNullableType,
        category $textNullableType,
        unit_size $textNullableType,
        purchase_price $doubleType,
        sale_price $doubleType,
        opening_stock $doubleType,
        current_stock $doubleType,
        min_stock_level $doubleType,
        notes $textNullableType
      )
    ''');

    // Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id $idType,
        shop_name $textType,
        owner_name $textNullableType,
        phone $textNullableType,
        area $textNullableType,
        address $textNullableType,
        opening_balance $doubleType,
        credit_limit $doubleType,
        current_balance $doubleType,
        notes $textNullableType
      )
    ''');

    // Sales Table
    await db.execute('''
      CREATE TABLE sales (
        id $idType,
        customer_id $integerType,
        date $textType,
        total_amount $doubleType,
        discount $doubleType,
        net_amount $doubleType,
        payment_type $textType,
        notes $textNullableType,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Sale Items Table
    await db.execute('''
      CREATE TABLE sale_items (
        id $idType,
        sale_id $integerType,
        product_id $integerType,
        quantity $doubleType,
        rate $doubleType,
        total $doubleType,
        FOREIGN KEY (sale_id) REFERENCES sales (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Collections Table
    await db.execute('''
      CREATE TABLE collections (
        id $idType,
        customer_id $integerType,
        date $textType,
        amount $doubleType,
        payment_method $textType,
        notes $textNullableType,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Purchases Table
    await db.execute('''
      CREATE TABLE purchases (
        id $idType,
        product_id $integerType,
        supplier_name $textNullableType,
        date $textType,
        quantity $doubleType,
        cost_price $doubleType,
        total_cost $doubleType,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        category $textType,
        amount $doubleType,
        date $textType,
        description $textNullableType
      )
    ''');

    // Cash Book Table
    await db.execute('''
      CREATE TABLE cash_book (
        id $idType,
        date $textType,
        opening_cash $doubleType,
        cash_in $doubleType,
        cash_out $doubleType,
        closing_cash $doubleType,
        notes $textNullableType
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE settings (
        id $idType,
        business_name $textType,
        owner_name $textNullableType,
        currency_symbol $textType,
        theme_mode $textType,
        language $textType
      )
    ''');

    // Backups Table
    await db.execute('''
      CREATE TABLE backups (
        id $idType,
        date $textType,
        file_path $textType,
        type $textType
      )
    ''');
    
    // Seed initial user
    await db.insert('users', {'pin': '1234', 'use_fingerprint': 0});
    
    // Seed initial settings
    await db.insert('settings', {
      'business_name': 'Chaudhary Traders',
      'owner_name': 'Owner',
      'currency_symbol': 'PKR',
      'theme_mode': 'light',
      'language': 'ur'
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
